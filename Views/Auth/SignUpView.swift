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
                PluckrTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: PluckrTheme.spacing * 3) {
                    // Header
                    VStack(spacing: PluckrTheme.spacing) {
                        Text("Create Account")
                            .font(.journalTitle)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Text("Join Pluckr")
                            .font(.journalSubtitle)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    .padding(.top, 40)
                    
                    // Sign Up Form
                    VStack(spacing: PluckrTheme.spacing * 2) {
                        TextField("Full Name", text: $displayName)
                            .textFieldStyle(PluckrTextFieldStyle())
                            .autocapitalization(.words)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(PluckrTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(PluckrTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(PluckrTextFieldStyle())
                        
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.journalCaption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: signUp) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.journalSubtitle)
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(PluckrButtonStyle())
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity(isFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal, PluckrTheme.padding)
                    
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
                    .foregroundColor(PluckrTheme.accentColor)
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