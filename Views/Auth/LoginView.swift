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
                PluckrTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: PluckrTheme.verticalPadding * 1.5) {
                    // Header
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        // Logo
                        Image("PluckrLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: PluckrTheme.verticalPadding / 2) {
                            Text("Pluckr")
                                .font(PluckrTheme.displayFont(size: 38))
                                .foregroundColor(PluckrTheme.textPrimary)
                            Text("Clinical Journal")
                                .font(PluckrTheme.subheadingFont(size: 20))
                                .foregroundColor(PluckrTheme.textSecondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Login Form
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        // MARK: - Development: Disabled Auto-Fill
                        TextField("Email", text: $email)
                            .pluckrTextField()
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .pluckrTextField()
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.default)
                            .allowsHitTesting(true)
                            .onTapGesture {
                                // Force keyboard to show without auto-fill
                            }
                        
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: signIn) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(PluckrTheme.subheadingFont())
                                    .fontWeight(.semibold)
                            }
                        }
                        .pluckrButton()
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                        
                        Button("Create Account") {
                            showSignUp = true
                        }
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.accent)
                        .padding(.top, PluckrTheme.verticalPadding)
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    
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
