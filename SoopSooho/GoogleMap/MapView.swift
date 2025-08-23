//
//  MapView.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/23/25.
//

import SwiftUI
import CoreLocation
import GoogleMaps

struct MapView: View {
    let center: CLLocationCoordinate2D
    let zoom: Float
    let isGestureEnabled: Bool
    let simulate: Bool

    init(
        center: CLLocationCoordinate2D,
        zoom: Float = 11,
        isGestureEnabled: Bool = false,
        simulate: Bool = true
    ) {
        self.center = center
        self.zoom = zoom
        self.isGestureEnabled = isGestureEnabled
        self.simulate = simulate
    }

    var body: some View {
        GooglePopupMap(
            center: center,
            zoom: zoom,
            isGestureEnabled: isGestureEnabled,
            simulate: simulate
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct GooglePopupMap: UIViewRepresentable {
    let center: CLLocationCoordinate2D
    let zoom: Float
    let isGestureEnabled: Bool
    let simulate: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withTarget: center, zoom: zoom)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator

        mapView.mapType = .normal
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        mapView.settings.zoomGestures = isGestureEnabled
        mapView.settings.scrollGestures = isGestureEnabled
        mapView.settings.rotateGestures = isGestureEnabled
        mapView.settings.tiltGestures = isGestureEnabled

        context.coordinator.lastCenter = center
        context.coordinator.lastZoom = zoom

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // 제스처 업데이트
        uiView.settings.zoomGestures = isGestureEnabled
        uiView.settings.scrollGestures = isGestureEnabled
        uiView.settings.rotateGestures = isGestureEnabled
        uiView.settings.tiltGestures = isGestureEnabled

        // 카메라 업데이트 (변경 시에만)
        if context.coordinator.lastCenter?.latitude != center.latitude ||
            context.coordinator.lastCenter?.longitude != center.longitude {
            uiView.animate(toLocation: center)
            context.coordinator.lastCenter = center
        }
        if context.coordinator.lastZoom != zoom {
            uiView.animate(toZoom: zoom)
            context.coordinator.lastZoom = zoom
        }
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var lastCenter: CLLocationCoordinate2D?
        var lastZoom: Float?
    }
}

#Preview {
    MapView(center: CLLocationCoordinate2D(latitude: 36.568, longitude: 128.729))
        .frame(width: 320, height: 240)
}
