//
//  Trip.swift
//  Uber
//
//  Created by Игорь Михайлов on 17.01.2024.
//

import Firebase

enum TripState: Int, Codable {
    case requested, rejected, accepted, cancelled, archived
}

struct TripUser: Identifiable, Codable, Equatable {
    let id: String
    let name: String
}

struct UpdateTripState: Codable {
    let state: TripState
}

struct Trip: Identifiable, Codable, Equatable {
    let id: String
    let driver: TripUser
    let passenger: TripUser
    let driverCoordinates: GeoPoint
    let pickupLocation: Location
    let dropOffLocation: Location
    let cost: Double
    let deliveryTime: Int
    let deliveryDistance: Double
    var state: TripState
 }
