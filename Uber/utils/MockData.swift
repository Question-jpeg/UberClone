//
//  MockData.swift
//  Uber
//
//  Created by Игорь Михайлов on 11.01.2024.
//

import MapKit
import Firebase

struct MockData {
    static let routeInfo = RouteInfo(
        start: UberLocation(title: "Current Location", address: "asd", coordinate: CLLocationCoordinate2D(latitude: -55, longitude: 110)),
        destination: UberLocation(title: "Coffee Place", address: "asd", coordinate: CLLocationCoordinate2D(latitude: -54.5, longitude: 109.5)),
        distanceInMeters: 500,
        pickUpTime: "1:30 PM",
        dropOffTime: "1:45 PM"
    )
    
    static let trip = Trip(
        id: "asd",
        driver: TripUser(id: "asd", name: "Aboba"),
        passenger: TripUser(id: "fgf", name: "Passas"),
        driverCoordinates: GeoPoint(latitude: 0, longitude: 0),
        pickupLocation: Location(title: "pickup Location", address: "Some address", coordinates: GeoPoint(latitude: 0, longitude: 0)),
        dropOffLocation: Location(title: "drop off Location", address: "Some chica", coordinates: GeoPoint(latitude: 0, longitude: 0)),
        cost: 12.33,
        deliveryTime: 5,
        deliveryDistance: 2.4,
        state: .requested
    )
}
