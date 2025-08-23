//
//  GoogleMapView.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/23/25.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI
import Foundation

struct RiskPoint: Codable {
    let lat: Double
    let lng: Double
    let risk: Double
}

struct GoogleMapView: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> GMSMapView {
        print("[GoogleMap] makeUIView 호출됨")
        
        // 명시적 프레임 설정
        let frame = CGRect(x: 0, y: 0, width: 600, height: 400)
        let camera = GMSCameraPosition.camera(withLatitude: 36.568, longitude: 128.729, zoom: 6)
        let mapView = GMSMapView(frame: frame, camera: camera)
        mapView.delegate = context.coordinator
        
        // 맵 스타일 설정
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        
        print("[GoogleMap] 맵뷰 생성 완료, 카메라 위치: \(camera.target)")

        // 경상북도 카메라 이동 제한(bounds)
        let southWest = CLLocationCoordinate2D(latitude: 35.7, longitude: 128.0)
        let northEast = CLLocationCoordinate2D(latitude: 37.3, longitude: 130.1)
        let gyeongbukBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        mapView.cameraTargetBounds = gyeongbukBounds
        mapView.setMinZoom(8.0, maxZoom: 11.8)
        mapView.moveCamera(GMSCameraUpdate.fit(gyeongbukBounds))

        // 히트맵 설정
        let heatmap = GMUHeatmapTileLayer()
        heatmap.radius = 300
        heatmap.opacity = 0.7
        
        // 그라데이션 설정
        let gradientColors: [UIColor] = [.green, .yellow, .red]
        let gradientStartPoints: [NSNumber] = [0.2, 0.6, 1.0]
        heatmap.gradient = GMUGradient(colors: gradientColors,
                                       startPoints: gradientStartPoints,
                                       colorMapSize: 256)

        // JSON에서 위험도 데이터 로드
        let riskPoints = loadRiskPointsFromJSON()
        let weightedItems: [GMUWeightedLatLng] = riskPoints.map { p in
            GMUWeightedLatLng(
                coordinate: CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng),
                intensity: Float(p.risk)
            )
        }
        heatmap.weightedData = weightedItems

        // 맵에 연결
        heatmap.map = mapView
        context.coordinator.heatmap = heatmap
        
        // 초기 줌에 맞춰 radius 반영
        context.coordinator.applyInitial(mapView: mapView)
        
        print("[GoogleMap] 히트맵 설정 완료, 데이터 포인트: \(riskPoints.count)개")

        return mapView
    }

    private func loadRiskPointsFromJSON() -> [RiskPoint] {
        guard let url = Bundle.main.url(forResource: "gyeongbuk_risk", withExtension: "json") else {
            print("[Risk] JSON 파일을 찾을 수 없습니다.")
            return defaultRiskPoints()
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([RiskPoint].self, from: data)
            return decoded
        } catch {
            print("[Risk] JSON 파싱 실패: \(error)")
            return defaultRiskPoints()
        }
    }

    private func defaultRiskPoints() -> [RiskPoint] {
        return [
            RiskPoint(lat: 36.568, lng: 128.729, risk: 82),
            RiskPoint(lat: 36.413, lng: 129.057, risk: 65),
            RiskPoint(lat: 36.993, lng: 129.409, risk: 24),
            RiskPoint(lat: 36.352, lng: 128.697, risk: 55),
            RiskPoint(lat: 36.436, lng: 129.057, risk: 73)
        ]
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {}

    class Coordinator: NSObject, GMSMapViewDelegate {
        var heatmap: GMUHeatmapTileLayer?
        private let viewModel = FireRiskViewModel()
        private var lastAppliedLarge: Bool = false
        
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            print("[GoogleMap] 맵 터치: \(coordinate)")
            
            // 터치한 좌표와 가장 가까운 위험 지역 찾기
            if let nearestArea = findNearestRiskArea(to: coordinate) {
                print("[GoogleMap] 가장 가까운 지역: \(nearestArea.name)")
                
                // Notification으로 ContentView에 전달
                DispatchQueue.main.async {
                    print("[GoogleMap] Notification 발송: \(nearestArea.name)")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowFireRiskPopup"),
                        object: nearestArea
                    )
                }
            }
        }
        
        private func findNearestRiskArea(to coordinate: CLLocationCoordinate2D) -> FireRiskArea? {
            let riskAreas = viewModel.topRiskAreas
            var nearestArea: FireRiskArea?
            var minDistance: Double = Double.infinity
            
            // 히트맵 데이터 포인트들과 비교
            let heatmapPoints = [
                (lat: 36.993, lng: 129.409, name: "울진군 북면"),
                (lat: 36.568, lng: 128.729, name: "안동시 임하면"),
                (lat: 36.885, lng: 128.915, name: "봉화군 춘양면"),
                (lat: 36.416, lng: 129.365, name: "영덕군 영해면"),
                (lat: 36.436, lng: 129.057, name: "청송군 진보면")
            ]
            
            for point in heatmapPoints {
                let distance = calculateDistance(
                    from: coordinate,
                    to: CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)
                )
                
                // 히트맵 반경 내에 있고 가장 가까운 지역 찾기
                if distance < 0.1 && distance < minDistance { // 0.1도 = 약 11km
                    minDistance = distance
                    nearestArea = riskAreas.first { $0.name == point.name }
                }
            }
            
            return nearestArea
        }
        
        private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
            let lat1 = from.latitude * .pi / 180
            let lon1 = from.longitude * .pi / 180
            let lat2 = to.latitude * .pi / 180
            let lon2 = to.longitude * .pi / 180
            
            let dLat = lat2 - lat1
            let dLon = lon2 - lon1
            
            let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
            let c = 2 * atan2(sqrt(a), sqrt(1-a))
            
            return c * 180 / .pi // 도 단위로 반환
        }

        func applyInitial(mapView: GMSMapView) {
            updateHeatmapRadius(for: mapView.camera.zoom)
        }

        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            print("[Map] didChange zoom=\(position.zoom), center=(\(position.target.latitude), \(position.target.longitude))")
            updateHeatmapRadius(for: position.zoom)
        }

        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            print("[Map] idle    zoom=\(position.zoom), center=(\(position.target.latitude), \(position.target.longitude))")
            updateHeatmapRadius(for: position.zoom)
        }

        private func updateHeatmapRadius(for zoom: Float) {
            guard let heatmap = heatmap else { return }
            let useLarge = zoom > 9.5
            if useLarge != lastAppliedLarge {
                heatmap.radius = useLarge ? 900 : 300
                heatmap.clearTileCache()
                lastAppliedLarge = useLarge
                print("[Heatmap] radius=\(heatmap.radius) (zoom=\(zoom))")
            }
        }
    }
}

#Preview {
    GoogleMapView()
}
