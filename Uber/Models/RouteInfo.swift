//
//  RouteInfo.swift
//  Uber
//
//  Created by Игорь Михайлов on 11.01.2024.
//

import CoreLocation

struct UberLocation {
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    var isCurrent = false
}

struct RouteInfo {
    let start: UberLocation
    let destination: UberLocation
    let distanceInMeters: Double
    let pickUpTime: String
    let dropOffTime: String
}
