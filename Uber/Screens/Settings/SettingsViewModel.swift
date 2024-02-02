//
//  SelectLocationViewModel.swift
//  Uber
//
//  Created by Игорь Михайлов on 14.01.2024.
//

import MapKit
import Firebase

enum LocationType {
    case home, work
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .work:
            return "Work"
        }
    }
}

class SettingsViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var locationText = "" {
        didSet {
            searchCompleter.queryFragment = locationText
        }
    }
    
    @Published var results = [MKLocalSearchCompletion]()
    private let searchCompleter = MKLocalSearchCompleter()
    
    private let authModel: AuthViewModel
    
    init(authModel: AuthViewModel) {
        self.authModel = authModel
        super.init()
        searchCompleter.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    @MainActor
    func setLocation(result: MKLocalSearchCompletion, forType type: LocationType) {
        Task {
            do {
                guard let location = try await LocationConstants.getUberLocation(result: result) else { return }
                let savedLocation = Location(
                    title: result.title,
                    address: result.subtitle,
                    coordinates: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                )
                authModel.updateFavoriteLocation(forType: type, savedLocation: savedLocation)
            } catch {
                print("DEBUG: Failed to search location due to error: \(error.localizedDescription)")
            }
        }
    }
}
