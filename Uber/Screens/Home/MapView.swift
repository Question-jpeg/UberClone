//
//  MapView.swift
//  Uber
//
//  Created by Игорь Михайлов on 09.01.2024.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        MapManager.shared.locationManager.requestWhenInUseAuthorization()
        
        MapManager.shared.mapView.delegate = context.coordinator
        MapManager.shared.mapView.showsUserLocation = true
        MapManager.shared.mapView.userTrackingMode = .follow
        
        return MapManager.shared.mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            MapManager.shared.userCoordinate = userLocation.coordinate
            
            if let location = userLocation.location {
                if (MapManager.shared.lastTime.distance(to: Date()) > 1) {
                    MapManager.shared.postLocation(location: location)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let pin = annotation as? DriverPin else { return nil }
            
            let view = MKAnnotationView(annotation: pin, reuseIdentifier: "driver")
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
