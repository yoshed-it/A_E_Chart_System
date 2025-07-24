import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                            .frame(width: 100, height: 100)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: PluckrTheme.verticalPadding / 2) {
                            Text("Create Account")
                                .font(PluckrTheme.displayFont(size: 32))
                                .foregroundColor(PluckrTheme.textPrimary)
                            Text("Join Pluckr")
                                .font(PluckrTheme.subheadingFont(size: 18))
                                .foregroundColor(PluckrTheme.textSecondary)
                        }
                    }
                    .padding(.top, 30)
                    
                    // Sign Up Form
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        // MARK: - Development: Disabled Auto-Fill
                        TextField("Full Name", text: $viewModel.displayName)
                            .pluckrTextField()
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.words)
                            .keyboardType(.default)
                        
                        TextField("Email", text: $viewModel.email)
                            .pluckrTextField()
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $viewModel.password)
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
                        
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
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
                        
                        // Error Message (future-proof)
                        if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        if let successMessage = viewModel.successMessage {
                            Text(successMessage)
                                .foregroundColor(.green)
                                .font(PluckrTheme.captionFont())
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .onAppear {
                                    // Dismiss immediately since organization is created
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        dismiss()
                                    }
                                }
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.signUp()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(PluckrTheme.subheadingFont())
                                    .fontWeight(.semibold)
                            }
                        }
                        .pluckrButton()
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .opacity(viewModel.isFormValid ? 1.0 : 0.6)
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
    

} 