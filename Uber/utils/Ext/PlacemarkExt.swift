//
//  PlacemarkExt.swift
//  Uber
//
//  Created by Игорь Михайлов on 18.01.2024.
//

import MapKit

extension CLPlacemark {
    func getAddress() -> String {
        var address = ""
        
        // Street address
        if let street = thoroughfare {
            address += street + ", "
        }
        
        // City
        if let city = locality {
            address += city + ", "
        }
        
        // Zip code
        if let zip = postalCode {
            address += zip + ", "
        }
        
        // Country
        if let country = country {
            address += country
        }
        
        return address
    }
}
