//
//  ContentView.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        if authModel.userSession != nil {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(LocationsViewModel())
}
