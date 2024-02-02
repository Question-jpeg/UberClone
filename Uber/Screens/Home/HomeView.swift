//
//  ContentView.swift
//  Uber
//
//  Created by Игорь Михайлов on 09.01.2024.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject var locationViewModel: LocationsViewModel
    @EnvironmentObject var authModel: AuthViewModel
    
    @State private var bottomSheetOffset = 0.0
    @State private var showingSideMenu = false
    
    @State private var trip: Trip?
    @State private var listener: ListenerRegistration?
    
    @State private var isShowingAlert = false
    
    @ViewBuilder var tripView: some View {
        if locationViewModel.mapState == .trip, let trip {
            if trip.state == .requested || trip.state == .rejected {
                if authModel.isDriver && trip.state == .requested {
                    BottomSheetView(
                        backgroundColor: Color(.systemGray6),
                        offsets: [0, 0.8],
                        currentOffset: $bottomSheetOffset) {
                            AcceptTripView(trip: trip, updateTripState: updateTripState)
                        }
                } else if !authModel.isDriver {
                    BottomSheetView(
                        backgroundColor: Color(.systemGray6),
                        offsets: [0, 0.8],
                        currentOffset: $bottomSheetOffset) {
                            TripLoadingView()
                        }
                }
            } else if trip.state == .accepted {
                if !authModel.isDriver {
                    BottomSheetView(
                        backgroundColor: Color(.systemGray6),
                        offsets: [0, 0.8],
                        currentOffset: $bottomSheetOffset) {
                            TripAcceptedView(trip: trip, cancel: { updateTripState(state: .cancelled) })
                        }
                } else {
                    BottomSheetView(
                        backgroundColor: Color(.systemGray6),
                        offsets: [0, 0.8],
                        currentOffset: $bottomSheetOffset) {
                            PickupPassengerView(trip: trip, cancel: { updateTripState(state: .cancelled) })
                        }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            MapView()
                .overlay(alignment: .bottom) {
                    if locationViewModel.mapState == .locationsSelected {
                        BottomSheetView(
                            backgroundColor: Color(.systemGray6),
                            offsets: [0, 0.8],
                            currentOffset: $bottomSheetOffset) {
                                RideRequestView(
                                    routeInfo: locationViewModel.routeInfo!,
                                    requestTrip: { requestTrip(forRideType: $0) }
                                )
                            }
                    }
                }
                .overlay(alignment: .bottom) {
                    tripView
                }
                .ignoresSafeArea()
                .overlay(alignment: (
                    locationViewModel.mapState == .locationsSelected ||
                    locationViewModel.mapState == .trip
                ) ? .topTrailing : .bottomTrailing) {
                    UserLocationButton(onCenter: {
                        bottomSheetOffset = 0.8
                    })
                }
                .overlay(alignment: .top) {
                    if locationViewModel.mapState == .noInput && !showingSideMenu && !authModel.isDriver {
                        SearchButton()
                    }
                }
                .overlay {
                    if locationViewModel.mapState == .selectingLocations {
                        LocationSearchView()
                            .padding(.top, 72)
                            .background(Color(.systemGray6))
                    }
                }
                .overlay(alignment: .topLeading) {
                    MenuButton(showingSideMenu: $showingSideMenu)
                }
                .offset(x: showingSideMenu ? 280 : 0)
                .background { SideMenuView().opacity(showingSideMenu ? 1 : 0) }
                .animation(.snappy, value: locationViewModel.mapState)
                .animation(.snappy, value: showingSideMenu)
                .animation(.snappy, value: trip)
        }
        .onChange(of: authModel.currentUser?.accountType) { oldValue, newValue in
            listener?.remove()
            
            if newValue == AccountType.driver {
                addTripObserverForDriver()
                MapManager.shared.removeDrivers()
                MapManager.shared.isPostingLocation = true
            } else if newValue == AccountType.passenger {
                addTripObserverForPassenger()
                MapManager.shared.addDrivers()
                MapManager.shared.isPostingLocation = false
            }
        }
        .onChange(of: trip?.state) { old, new in
            if let new {
                switch new {
                case .requested:
                    locationViewModel.mapState = .trip
                    if !authModel.isDriver && old == nil {
                        addPassengerPolyline()
                    }
                case .accepted:
                    locationViewModel.mapState = .trip
                    if authModel.isDriver {
                        addDriverPolyline()
                    } else if old == nil {
                        addPassengerPolyline()
                    }
                case .rejected:
                    if authModel.isDriver {
                        locationViewModel.mapState = .noInput
                    }
                case .cancelled:
                    locationViewModel.mapState = .noInput
                    isShowingAlert = true
                    trip = nil
                    MapManager.shared.clearMap()
                default:
                    break
                }
            }
        }
        .alert("Trip was cancelled", isPresented: $isShowingAlert) {
            Text("Ok")
        }
    }
}

extension HomeView {
    func updateTripState(state: TripState) {
        guard let trip else { return }
        
        Task {
            do {
                try await FirebaseConstants.updateTripState(withId: trip.id, state: state)
                if state == .cancelled {
                    try await FirebaseConstants.updateTripState(withId: trip.id, state: .archived)
                }
            } catch {
                print("DEBUG: Failed to reject a trip due to error: \(error.localizedDescription)")
            }
        }
    }
}

extension HomeView {
    
    @MainActor
    func addPassengerPolyline() {
        guard let trip else { return }
        
        Task {
            do {
                let _ = try await MapManager.shared.addPolyline(
                    from: trip.pickupLocation.coordinates.toCoordinate2D(),
                    to: trip.dropOffLocation.coordinates.toCoordinate2D()
                )
            } catch {
                print("DEBUG: Failed to add polyline due to error: \(error.localizedDescription)")
            }
        }
    }
    
    func addTripObserverForPassenger() {
        guard authModel.currentUser?.accountType == .passenger else { return }
        guard let query = FirebaseConstants.getPassengerTripQuery() else { return }
        
        listener = query.addSnapshotListener { snapshot, _ in
            guard let trips = snapshot?.documentChanges.compactMap({ try? $0.document.data(as: Trip.self) }) else { return }
            guard let trip = trips.first(where: { $0.state != .archived }) else { return }
            
            self.trip = trip
        }
    }
    
    @MainActor
    func requestTrip(forRideType rideType: RideType) {
        guard let driver = MapManager.shared.drivers.first else { return }
        guard let currentUser = authModel.currentUser else { return }
        guard let routeInfo = locationViewModel.routeInfo else { return }
        
        Task {
            do {
                guard let route = try await LocationConstants.getDestinationRoute(
                    from: driver.coordinates.toCoordinate2D(),
                    to: routeInfo.start.coordinate
                ).routes.first else { return }
                
                let trip = Trip(
                    id: UUID().uuidString,
                    driver: TripUser(id: driver.id, name: driver.fullName),
                    passenger: TripUser(id: currentUser.id, name: currentUser.fullName),
                    driverCoordinates: driver.coordinates,
                    pickupLocation: Location.from(uberLocation: routeInfo.start),
                    dropOffLocation: Location.from(uberLocation: routeInfo.destination),
                    cost: rideType.computePrice(forDistanceInMeters: routeInfo.distanceInMeters),
                    deliveryTime: max(1, Int(route.expectedTravelTime/60)),
                    deliveryDistance: route.distance/1600,
                    state: .requested
                )
                
                try await FirebaseConstants.postTrip(trip)
            } catch {
                print("DEBUG: Failed to request a trip due to error: \(error.localizedDescription)")
            }
        }
    }
}

extension HomeView {
    
    func addTripObserverForDriver() {
        guard authModel.currentUser?.accountType == .driver else { return }
        guard let query = FirebaseConstants.getDriverTripQuery() else { return }
        
        listener = query.addSnapshotListener { snapshot, _ in
            guard let trips = snapshot?.documentChanges.compactMap({ try? $0.document.data(as: Trip.self) }) else { return }
            guard let trip = trips.first(where: { $0.state != .archived }) else { return }
            
            self.trip = trip
        }
    }
    
    @MainActor
    func fetchTrip() {
        guard let currentUser = authModel.currentUser else { return }
        guard currentUser.accountType == .driver else { return }
        
        Task {
            do {
                trip = try await FirebaseConstants.fetchTrip()
            } catch {
                print("DEBUG: Failed to fetch trip due to error: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func addDriverPolyline() {
        guard let userCoordinate = MapManager.shared.userCoordinate else { return }
        guard let trip else { return }
        
        Task {
            do {
                let _ = try await MapManager.shared.addPolyline(
                    from: userCoordinate,
                    to: trip.pickupLocation.coordinates.toCoordinate2D()
                )
            } catch {
                print("DEBUG: Failed to add polyline due to error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationsViewModel())
        .environmentObject(AuthViewModel())
}

struct LocationSearchInputView: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(.black)
                .frame(width: 8, height: 8)
                .padding(.horizontal)
            
            Text("Where to?")
                .foregroundStyle(Color(.darkGray))
            
            Spacer()
        }
        .frame(height: 50)
        .background(
            Rectangle()
                .fill(.white)
                .shadow(color: .black, radius: 6)
        )
        .padding(.horizontal, 32)
    }
}

struct ActionButton: View {
    
    let systemImage: String
    
    var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .foregroundStyle(.black)
            .padding(15)
            .background(.white)
            .clipShape(Circle())
            .shadow(color: .black, radius: 6)
            .padding(.horizontal)
    }
}

struct UserLocationButton: View {
    
    let onCenter: () -> Void
    
    var body: some View {
        Button {
            MapManager.shared.center()
            onCenter()
        } label: {
            ActionButton(systemImage: "paperplane")
        }
    }
}

struct SearchButton: View {
    @EnvironmentObject var locationViewModel: LocationsViewModel
    
    var body: some View {
        Button {
            locationViewModel.mapState = .selectingLocations
        } label: {
            LocationSearchInputView()
        }
        .padding(.top, 72)
        .transition(.move(edge: .trailing))
    }
}

struct MenuButton: View {
    @EnvironmentObject var locationViewModel: LocationsViewModel
    @Binding var showingSideMenu: Bool
    
    var body: some View {
        Button {
            if locationViewModel.mapState == .selectingLocations {
                locationViewModel.mapState = .noInput
            } else if locationViewModel.mapState == .locationsSelected {
                locationViewModel.mapState = .noInput
                MapManager.shared.clearMap()
            } else {
                showingSideMenu.toggle()
            }
        } label: {
            ActionButton(systemImage: (locationViewModel.mapState == .selectingLocations || locationViewModel.mapState == .locationsSelected || showingSideMenu) ? "arrow.left" : "line.3.horizontal")
        }
    }
}
