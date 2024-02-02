//
//  GeoExt.swift
//  Uber
//
//  Created by Игорь Михайлов on 18.01.2024.
//

import Firebase
import MapKit

extension GeoPoint {
    func toCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

