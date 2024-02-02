//
//  AuthViewModel.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import Firebase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    @Published var userSession: Firebase.User?
    @Published var currentUser: User?
    
    var isDriver: Bool {
        currentUser?.accountType == .driver
    }
    
    init() {
        fetchUser()
    }
    
    func fetchUser() {
        userSession = FirebaseConstants.currentUser
        if let userSession {
            Task {
                do {
                    currentUser = try await FirebaseConstants.fetchUser(id: userSession.uid)
                } catch {
                    print("DEBUG: Failed to fetch current user due to error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func signIn() {
        Task {
            do {
                userSession = try await FirebaseConstants.signIn(withEmail: email, password: password)
                if let userSession {
                    currentUser = try await FirebaseConstants.fetchUser(id: userSession.uid)
                }
            } catch {
                print("DEBUG: Failed to sign in due to error: \(error.localizedDescription)")
            }
        }
    }
        
    func registerUser() {
        Task {
            do {
                userSession = try await FirebaseConstants.registerUser(withEmail: email, password: password, fullName: fullName)
                if let userSession {
                    currentUser = try await FirebaseConstants.createUser(withId: userSession.uid, fullName: fullName, email: email)
                }
            } catch {
                print("DEBUG: failed register a user due to error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateFavoriteLocation(forType type: LocationType, savedLocation: Location) {
        guard let userSession else { return }
        Task {
            do {
                try await FirebaseConstants.updateFavoriteLocation(
                    forId: userSession.uid,
                    forType: type,
                    savedLocation: savedLocation
                )
                switch type {
                case .home:
                    currentUser?.homeLocation = savedLocation
                case .work:
                    currentUser?.workLocation = savedLocation
                }
            } catch {
                print("DEBUG: failed to update favorite location due to error: \(error.localizedDescription)")
            }
        }
    }
    
    func logout() {
        try? FirebaseConstants.logout()
        userSession = nil
        currentUser = nil
        email = ""
        password = ""
        fullName = ""
    }
}
