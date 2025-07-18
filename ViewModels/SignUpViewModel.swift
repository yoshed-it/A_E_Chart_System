import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    private let authService = AuthService.shared
    private let db = Firestore.firestore()
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        return !email.isEmpty && 
               !password.isEmpty && 
               !displayName.isEmpty && 
               password == confirmPassword && 
               password.count >= 6
    }
    
    // MARK: - Sign Up
    
    func signUp() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        await signUpAndCreateOrganization()
        
        isLoading = false
    }
    
    private func signUpAndCreateOrganization() async {
        PluckrLogger.info("Starting sign-up process for: \(email)")
        
        // Create user account
        let success = await authService.createUser(
            email: email,
            password: password,
            displayName: displayName
        )
        
        if success {
            PluckrLogger.info("User account created successfully")
            
            // Initialize organization service for new user
            await OrganizationService.shared.initializeIfAuthenticated()
            
            successMessage = "Account created successfully! Please create your organization."
        } else {
            PluckrLogger.error("Failed to create user account: \(authService.errorMessage ?? "Unknown error")")
            errorMessage = authService.errorMessage ?? "Failed to create account"
        }
    }
    

} 