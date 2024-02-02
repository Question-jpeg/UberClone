//
//  LocationConstants.swift
//  Uber
//
//  Created by Игорь Михайлов on 14.01.2024.
//

import MapKit

struct LocationConstants {
    static func getUberLocation(result: MKLocalSearchCompletion) async throws -> UberLocation? {
        let response = try await searchLocation(by: result)
        if let coordinate = response.mapItems.first?.placemark.coordinate {
            return UberLocation(title: result.title, address: result.subtitle, coordinate: coordinate)
        }
        return nil
    }
    
    private static func searchLocation(by localSearch: MKLocalSearchCompletion) async throws -> MKLocalSearch.Response {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "\(localSearch.title) \(localSearch.subtitle)"
        let search = MKLocalSearch(request: searchRequest)
        
        return try await search.start()
    }
    
    static func getDestinationRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> MKDirections.Response {
        let from = MKPlacemark(coordinate: from)
        let to = MKPlacemark(coordinate: to)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: from)
        request.destination = MKMapItem(placemark: to)
        let directions = MKDirections(request: request)
        
        return try await directions.calculate()
    }
}
