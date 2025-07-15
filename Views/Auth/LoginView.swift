//
//  LoginView.swift
//  A_E_Charting
//
//  Created by Yoah Nebe on 6/27/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                PluckrTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: PluckrTheme.spacing * 3) {
                    // Header
                    VStack(spacing: PluckrTheme.spacing) {
                        Text("Pluckr")
                            .font(.journalTitle)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Text("Clinical Journal")
                            .font(.journalSubtitle)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    .padding(.top, 60)
                    
                    // Login Form
                    VStack(spacing: PluckrTheme.spacing * 2) {
                        TextField("Email", text: $email)
                            .textFieldStyle(PluckrTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(PluckrTextFieldStyle())
                        
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.journalCaption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: signIn) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(.journalSubtitle)
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(PluckrButtonStyle())
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                        
                        Button("Create Account") {
                            showSignUp = true
                        }
                        .font(.journalCaption)
                        .foregroundColor(PluckrTheme.accentColor)
                        .padding(.top, PluckrTheme.spacing)
                    }
                    .padding(.horizontal, PluckrTheme.padding)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
    
    private func signIn() {
        Task {
            await authService.signIn(email: email, password: password)
        }
    }
}
