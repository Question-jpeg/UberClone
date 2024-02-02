//
//  SettingsView.swift
//  Uber
//
//  Created by Игорь Михайлов on 14.01.2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authModel: AuthViewModel
    @StateObject var viewModel: SettingsViewModel
    @State private var showingLogOut = false
    
    init(authModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(authModel: authModel))
    }
    
    var body: some View {
        List {
            Section {
                if let currentUser = authModel.currentUser {
                    UserInfoView(user: currentUser)
                }
            }
            
            Section("Favorites") {
                NavigationLink {
                    AddLocationView(viewModel: viewModel, locationType: .home)
                } label: {
                    ListItem(
                        systemImage: "house.circle.fill",
                        title: "Home",
                        description: authModel.currentUser?.homeLocation?.title ?? "Add Home",
                        color: .blue
                    )
                }
                NavigationLink {
                    AddLocationView(viewModel: viewModel, locationType: .work)
                } label: {
                    ListItem(
                        systemImage: "archivebox.circle.fill",
                        title: "Work",
                        description: authModel.currentUser?.workLocation?.title ?? "Add Work",
                        color: .blue
                    )
                }
            }
            
            Section("Settings") {
                ListItem(systemImage: "bell.circle.fill", title: "Notifications", color: .purple)
                ListItem(systemImage: "creditcard.circle.fill", title: "Payment Methods", color: .blue)
            }
            
            Section("Account") {
                ListItem(systemImage: "dollarsign.circle.fill", title: "Become a driver", color: .green)
                Button {
                    showingLogOut = true
                } label: {
                    ListItem(systemImage: "arrow.left.circle.fill", title: "Log Out", color: .red)
                }
            }
        }
        .alert("Log Out?", isPresented: $showingLogOut) {
            Button(role: .destructive) {
                authModel.logout()
            } label: {
                Text("Log Out")
            }
        }
        .tint(.primary)
        .navigationTitle("Settings")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
                .tint(.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        let authModel = AuthViewModel()
        SettingsView(authModel: authModel)
            .environmentObject(authModel)
    }
}

struct ListItem: View {
    
    let systemImage: String
    let title: String
    var description: String?
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundStyle(color)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(minHeight: 40)
    }
}
