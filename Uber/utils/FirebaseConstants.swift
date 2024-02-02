//
//  FirebaseConstants.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import Firebase
import FirebaseFirestoreSwift

struct FirebaseConstants {
    private static let firestore = Firestore.firestore()
    private static let auth = Auth.auth()
    private static let encoder = Firestore.Encoder()
    static var currentUser: Firebase.User? {
        auth.currentUser
    }
    static let usersCollection = firestore.collection("users")
    static let tripsCollection = firestore.collection("trips")
    
    private static func encode(_ value: Encodable) throws -> [String: Any] {
        try encoder.encode(value)
    }
}

// AUTH FLOW
extension FirebaseConstants {
    static func registerUser(withEmail email: String, password: String, fullName: String) async throws -> Firebase.User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user
    }
    
    static func signIn(withEmail email: String, password: String) async throws -> Firebase.User {
        let result = try await auth.signIn(withEmail: email, password: password)        
        return result.user
    }
    
    static func logout() throws {
        try auth.signOut()
    }
}

// USERS
extension FirebaseConstants {
    private static func getUserDocRef(_ id: String? = nil) -> DocumentReference {
        if let id {
            return usersCollection.document(id)
        } else {
            return usersCollection.document()
        }
    }
    
    static func createUser(withId id: String, fullName: String, email: String) async throws -> User {
        let userDocRef = getUserDocRef(id)
        
        let user = User(
            id: id,
            fullName: fullName,
            email: email,
            coordinates: GeoPoint(latitude: 0, longitude: 0),
            accountType: .passenger
        )
        let data = try encode(user)
        
        try await userDocRef.setData(data)
        return user
    }
    
    static func fetchUser(id: String) async throws -> User {
        try await getUserDocRef(id).getDocument(as: User.self)
    }
    
    static func updateFavoriteLocation(forId id: String, forType type: LocationType, savedLocation: Location) async throws {
        let userDocRef = getUserDocRef(id)
        let data: [String: Any]
        switch type {
        case .home:
            data = try encode(UserHomeUpdate(homeLocation: savedLocation))
        case .work:
            data = try encode(UserWorkUpdate(workLocation: savedLocation))
        }
        try await userDocRef.updateData(data)
    }
    
    static func fetchDrivers() async throws -> [User] {
        let snapshot = try await usersCollection.whereField("accountType", isEqualTo: AccountType.driver.rawValue)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    static func getDriversQuery() -> Query {
        usersCollection.whereField("accountType", isEqualTo: AccountType.driver.rawValue)
    }
}

// TRIPS
extension FirebaseConstants {
    private static func getTripDocRef(id: String? = nil) -> DocumentReference {
        if let id {
            return tripsCollection.document(id)
        } else {
            return tripsCollection.document()
        }
    }
    
    static func postTrip(_ trip: Trip) async throws {
        let tripDocRef = getTripDocRef(id: trip.id)
        let data = try encode(trip)
        try await tripDocRef.setData(data)
    }
    
    static func fetchTrip() async throws -> Trip? {
        let snapshot = try await tripsCollection.getDocuments()
        return try snapshot.documents.first?.data(as: Trip.self)
    }
    
    static func updateTripState(withId id: String, state: TripState) async throws {
        let data = try encode(UpdateTripState(state: state))
        try await tripsCollection.document(id).updateData(data)
    }
    
    static func getPassengerTripQuery() -> Query? {
        guard let currentUser else { return nil }
        
        return tripsCollection
            .whereField("passenger.id", isEqualTo: currentUser.uid)
    }
    
    static func getDriverTripQuery() -> Query? {
        guard let currentUser else { return nil }
        
        return tripsCollection
            .whereField("driver.id", isEqualTo: currentUser.uid)
    }
    
    static func postDriversLocation(geoPoint: GeoPoint) async throws {
        guard let currentUser else { return }
        
        let data = try encode(UserCoordinatesUpdate(coordinates: geoPoint))
        
        let driverDocRef = getUserDocRef(currentUser.uid)
        try await driverDocRef.updateData(data)
    }
}
