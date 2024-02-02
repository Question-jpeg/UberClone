//
//  SavedLocation.swift
//  Uber
//
//  Created by Игорь Михайлов on 16.01.2024.
//

import Firebase

struct Location: Codable, Equatable {
    let title: String
    let address: String
    let coordinates: GeoPoint
    
    static func from(uberLocation: UberLocation) -> Location {
        Location(
            title: uberLocation.title,
            address: uberLocation.address,
            coordinates: GeoPoint(
                latitude: uberLocation.coordinate.latitude,
                longitude: uberLocation.coordinate.longitude
            )
        )
    }
}
