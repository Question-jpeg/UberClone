//
//  LoginView.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            Color.black
                .ignoresSafeArea()
                .overlay {
                    VStack() {
                        UberLogoView()
                            .padding(.vertical, 30)
                        FieldsView(email: $viewModel.email, password: $viewModel.password)
                        
                        Button {
                            
                        } label: {
                            Text("Forgot Password?")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Button {
                            viewModel.signIn()
                        } label: {
                            HStack {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        NavigationLink {
                            RegistrationView()
                                .navigationBarBackButtonHidden()
                        } label: {
                            VStack {
                                Text("Don't have an account? ")
                                +
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                            .font(.footnote)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkGray))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            
                        }
                        
                        SocialSignIn()
                            .padding(.top, 20)
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                }
        }
    }
}

#Preview {
    LoginView()
}

struct UberLogoView: View {
    var body: some View {
        VStack(spacing: -16) {
            Image(.uberAppIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            
            Text("UBER")
                .font(.largeTitle)
        }
    }
}

struct FieldsView: View {
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack(spacing: 30) {
            TextField("name@example.com", text: $email)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .customInputStyle(title: "Email Address")
            
            SecureField("Enter your password", text: $password)
                .customInputStyle(title: "Password")
        }
    }
}

struct SocialSignIn: View {
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(Color(.darkGray))
                    .frame(height: 1)
                
                Text("Sign in with social")
                    .frame(width: 170)
                    .fontWeight(.semibold)
                
                Rectangle()
                    .fill(Color(.darkGray))
                    .frame(height: 1)
            }
            
            HStack(spacing: 24) {
                Button {
                    
                } label: {
                    Image(.facebookSignInIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                }
                
                Button {
                    
                } label: {
                    Image(.googleSignInIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                }
            }
        }
    }
}
