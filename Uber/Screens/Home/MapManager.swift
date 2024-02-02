//
//  MapManager.swift
//  Uber
//
//  Created by Игорь Михайлов on 09.01.2024.
//

import MapKit
import Firebase

class MapManager {
    
    static let shared = MapManager()
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var userCoordinate: CLLocationCoordinate2D?
    
    var driversListener: ListenerRegistration?
    var drivers = [User]()
    
    var isPostingLocation = false
    var lastTime = Date()
    
    @MainActor
    func setRoute(selectedLocations: SelectedLocations) async -> RouteInfo? {
        return await configurePolyline(from: selectedLocations.startLocation, destination: selectedLocations.destination)
    }
    
    func clearMap() {
        removeDrawings()
    }
    
    func center() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func postLocation(location: CLLocation) {
        guard isPostingLocation else { return }
        
        lastTime = Date()
        
        Task {
            do {
                try await FirebaseConstants.postDriversLocation(
                    geoPoint: GeoPoint(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                )
            } catch {
                print("DEBUG: Failed to post driver's location due to error: \(error.localizedDescription)")
            }
        }
    }
}


extension MapManager {
    func addDrivers() {
        driversListener = FirebaseConstants.getDriversQuery()
            .addSnapshotListener { [self] snapshot, _ in
                guard let changes = snapshot?.documentChanges else { return }
                let drivers = changes.compactMap { try? $0.document.data(as: User.self) }
                let pins = drivers.map { DriverPin(driver: $0) }
                eraseDrivers()
                mapView.addAnnotations(pins)
                self.drivers = drivers
            }
    }
    
    private func eraseDrivers() {
        mapView.removeAnnotations(mapView.annotations.filter { ($0 as? DriverPin) != nil })
    }
    
    func removeDrivers() {
        driversListener?.remove()
        eraseDrivers()
    }
    
    private func removeDrawings() {
        mapView.removeAnnotations(mapView.annotations.filter { ($0 as? DriverPin) == nil })
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func addPin(withCoordinate coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        
        return pin
    }
    
    private func addAndSelectPin(withCoordinate coordinate: CLLocationCoordinate2D) {
        let pin = addPin(withCoordinate: coordinate)
        mapView.selectAnnotation(pin, animated: true)
    }
    
    @MainActor
    private func configurePolyline(from: UberLocation?, destination: UberLocation) async -> RouteInfo? {
        guard let userCoordinate else { return nil }
        
        do {
            var start: UberLocation
            if let from { start = from } else {
                guard let placeMark = (try await CLGeocoder().reverseGeocodeLocation(CLLocation(
                    latitude: userCoordinate.latitude,
                    longitude: userCoordinate.longitude
                ))).first else { return nil }
                
                let address = placeMark.getAddress()
                start = UberLocation(title: placeMark.name ?? address, address: address, coordinate: userCoordinate, isCurrent: true)
            }
            
            guard let route = try await addPolyline(from: start.coordinate, to: destination.coordinate) else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            
            return RouteInfo(
                start: start,
                destination: destination,
                distanceInMeters: route.distance,
                pickUpTime: formatter.string(from: Date()),
                dropOffTime: formatter.string(from: Date() + route.expectedTravelTime)
            )
        } catch {
            print("DEBUG: Failed to calculate route due to error: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func addPolyline(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> MKRoute? {
        removeDrawings()
        
        let response = try await LocationConstants.getDestinationRoute(from: from, to: to)
        guard let route = response.routes.first else { return nil }
        mapView.addOverlay(route.polyline)
        
        
        let rect = mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 100, left: 32, bottom: 500, right: 32))
        mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        
        let _ = addPin(withCoordinate: from)
        addAndSelectPin(withCoordinate: to)
        
        return route
    }
}
