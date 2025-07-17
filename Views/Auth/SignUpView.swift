import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                PluckrTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: PluckrTheme.verticalPadding * 1.5) {
                    // Header
                    VStack(spacing: PluckrTheme.verticalPadding / 2) {
                        Text("Create Account")
                            .font(PluckrTheme.displayFont(size: 32))
                            .foregroundColor(PluckrTheme.textPrimary)
                        Text("Join Pluckr")
                            .font(PluckrTheme.subheadingFont(size: 18))
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .padding(.top, 40)
                    
                    // Sign Up Form
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        TextField("Full Name", text: $displayName)
                            .pluckrTextField()
                            .autocapitalization(.words)
                        
                        TextField("Email", text: $email)
                            .pluckrTextField()
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .pluckrTextField()
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .pluckrTextField()
                        
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(PluckrTheme.captionFont())
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: signUp) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(PluckrTheme.subheadingFont())
                                    .fontWeight(.semibold)
                            }
                        }
                        .pluckrButton()
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity(isFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    
                    Spacer()
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !displayName.isEmpty && 
        password == confirmPassword && 
        password.count >= 6
    }
    
    private func signUp() {
        Task {
            let success = await authService.createUser(
                email: email, 
                password: password, 
                displayName: displayName
            )
            
            if success {
                dismiss()
            }
        }
    }
} 