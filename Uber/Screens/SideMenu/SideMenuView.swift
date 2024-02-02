//
//  SideMenuView.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import SwiftUI

enum SideMenuOption {
    case driver, trips, wallet, settings, messages
    
    static let passengerOptions: [Self] = [.trips, .wallet, .settings, .messages]
    
    var title: String {
        switch self {
        case .driver:
            return "Become a driver"
        case .trips:
            return "Your trips"
        case .wallet:
            return "Wallet"
        case .settings:
            return "Settings"
        case .messages:
            return "Messages"
        }
    }
    
    var systemImage: String {
        switch self {
        case .driver:
            return "dollarsign.square"
        case .trips:
            return "list.bullet.rectangle"
        case .wallet:
            return "creditcard"
        case .settings:
            return "gear"
        case .messages:
            return "bubble.left"
        }
    }
}

struct SideMenuView: View {
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 30) {
                if let currentUser = authModel.currentUser {
                    UserInfoView(user: currentUser)
                }
                
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
                
                VStack(spacing: 30) {
                    ForEach(SideMenuOption.passengerOptions, id: \.self) { option in
                        NavigationLink(value: option) {
                            SideMenuOptionView(option: option)
                        }
                        .tint(.primary)
                    }
                }
                .navigationDestination(for: SideMenuOption.self) { option in
                    switch option {
                    case .settings:
                        SettingsView(authModel: authModel)
                    case .driver:
                        Text("driver")
                    case .trips:
                        Text("trips")
                    case .wallet:
                        Text("wallet")
                    case .messages:
                        Text("messages")
                    }
                }
                
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Do more with your account")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    
                    SideMenuOptionView(option: .driver)
                }
                
                Spacer()
            }
            .padding()
            .padding(.top)
            .frame(width: 280)
            .background(Color(.systemGray6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SideMenuView()
}

struct UserInfoView: View {
    
    let user: User
    
    var body: some View {
        HStack {
            Image(.maleProfilePhoto2)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.fullName)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
    }
}

struct SideMenuOptionView: View {
    
    let option: SideMenuOption
    
    var body: some View {
        
        HStack {
            Image(systemName: option.systemImage)
                .font(.title2)
                .padding(.trailing, 10)
            
            Text(option.title)
                .font(.callout)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
}
