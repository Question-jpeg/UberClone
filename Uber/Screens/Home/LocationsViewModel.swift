//
//  LocationSearchViewModel.swift
//  Uber
//
//  Created by Игорь Михайлов on 09.01.2024.
//

import MapKit

enum SelectedField {
    case start, destination
}

struct SelectedLocations {
    let startLocation: UberLocation?
    let destination: UberLocation
}

enum MapState {
    case noInput, selectingLocations, locationsSelected, trip
}

class LocationsViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var selectedField: SelectedField = .destination
    
    @Published var startLocationText = "" {
        didSet {
            selectedField = .start
            searchCompleter.queryFragment = startLocationText
            
            if startLocationText.isEmpty { selectedStartLocation = nil }
        }
    }
    @Published var destinationText = "" {
        didSet {
            selectedField = .destination
            searchCompleter.queryFragment = destinationText
        }
    }
    
    var selectedStartLocation: MKLocalSearchCompletion? {
        didSet {
            if let selectedStartLocation {
                startLocationText = selectedStartLocation.title
            }
        }
    }
    var selectedDestination: MKLocalSearchCompletion? {
        didSet {
            if let selectedDestination {
                destinationText = selectedDestination.title
            }
        }
    }
    
    var isValid: Bool {
        (selectedStartLocation == nil ? startLocationText.isEmpty : startLocationText == selectedStartLocation!.title) &&
        (selectedDestination == nil ? false : destinationText == selectedDestination!.title)
    }
    //    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    @Published var mapState: MapState = .noInput
    
    @Published var results = [MKLocalSearchCompletion]()
    private let searchCompleter = MKLocalSearchCompleter()
    
    @Published var isLoadingRoute = false
    @Published var routeInfo: RouteInfo?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    @MainActor
    func setSelectedLocations() {
        guard let selectedDestination else { return }
        Task {
            isLoadingRoute = true
            defer { isLoadingRoute = false }
            do {
                guard let destination = try await LocationConstants.getUberLocation(result: selectedDestination) else { return }
                
                
                var start: UberLocation? = nil
                if let selectedStartLocation {
                    start = try await LocationConstants.getUberLocation(result: selectedStartLocation)
                }
                
                routeInfo = await MapManager.shared.setRoute(selectedLocations: SelectedLocations(startLocation: start, destination: destination))
                if routeInfo != nil {
                    mapState = .locationsSelected
                }
            } catch {
                print("DEBUG: Failed to search location due to error: \(error.localizedDescription)")
            }
        }
    }
}
