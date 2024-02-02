//
//  DriverPin.swift
//  Uber
//
//  Created by Игорь Михайлов on 16.01.2024.
//

import MapKit
import Firebase

class DriverPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let id: String
    
    init(driver: User) {
        self.id = driver.id
        self.coordinate = CLLocationCoordinate2D(
            latitude: driver.coordinates.latitude,
            longitude: driver.coordinates.longitude
        )
    }
}
