//
//  RegistrationView.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Color.black
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                VStack(alignment: .leading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .padding([.vertical, .trailing])
                    }
                    
                    Text("Create new\naccount")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    VStack(spacing: 30) {
                        TextField("Enter your name", text: $viewModel.fullName)
                            .customInputStyle(title: "Full Name")
                        FieldsView(email: $viewModel.email, password: $viewModel.password)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.registerUser()
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.horizontal)
            }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
