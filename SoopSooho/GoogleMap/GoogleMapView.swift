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
        // 경상북도 중심(안동 인근) 기준 카메라
        let camera = GMSCameraPosition.camera(withLatitude: 36.568, longitude: 128.729, zoom: 6)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator

        // 경상북도 카메라 이동 제한(bounds)
        let southWest = CLLocationCoordinate2D(latitude: 35.7, longitude: 128.0)
        let northEast = CLLocationCoordinate2D(latitude: 37.3, longitude: 130.1)
        let gyeongbukBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        mapView.cameraTargetBounds = gyeongbukBounds
        mapView.setMinZoom(8.0, maxZoom: 11.8)
        mapView.moveCamera(GMSCameraUpdate.fit(gyeongbukBounds))

        // 1) Heatmap 레이어 생성
        let heatmap = GMUHeatmapTileLayer()
        heatmap.radius = 300 // 점 퍼짐 정도(픽셀)
        heatmap.opacity = 0.7 // 투명도 (0~1)
        // 2) 그라데이션 커스터마이즈(선택)
        let gradientColors: [UIColor] = [.green, .yellow, .red] // 낮음→높음
        let gradientStartPoints: [NSNumber] = [0.2, 0.6, 1.0]
        heatmap.gradient = GMUGradient(colors: gradientColors,
                                       startPoints: gradientStartPoints,
                                       colorMapSize: 256)

        // 3) JSON에서 위험도 데이터 로드
        let riskPoints = loadRiskPointsFromJSON()
        let weightedItems: [GMUWeightedLatLng] = riskPoints.map { p in
            GMUWeightedLatLng(
                coordinate: CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng),
                intensity: Float(p.risk)
            )
        }
        heatmap.weightedData = weightedItems

        // 4) 맵에 연결
        heatmap.map = mapView
        context.coordinator.heatmap = heatmap
        // 초기 줌에 맞춰 radius 1회 반영
        context.coordinator.applyInitial(mapView: mapView)
        // 데이터 바뀐 경우: heatmap.clearTileCache() 호출하면 타일 재생성

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
        private var lastAppliedLarge: Bool = false

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
