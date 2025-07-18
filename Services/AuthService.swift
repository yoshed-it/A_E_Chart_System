import Foundation
import FirebaseAuth
import FirebaseFirestore

/**
 *Manages authentication state and user operations*
 
 This service handles all authentication-related functionality including
 sign in, sign up, sign out, and user state management. It integrates
 with Firebase Auth and maintains the current user state.
 
 ## Features
 - User authentication (sign in/sign up)
 - Authentication state monitoring
 - User profile management
 - Provider document creation
 
 ## Usage
 ```swift
 @StateObject private var authService = AuthService()
 
 // Sign in
 let success = await authService.signIn(email: "user@example.com", password: "password")
 
 // Check authentication state
 if authService.isAuthenticated {
     // User is signed in
 }
 ```
 
 ## Published Properties
 - `currentUser`: The currently authenticated Firebase user
 - `isAuthenticated`: Boolean indicating if user is signed in
 - `isLoading`: Boolean indicating if an auth operation is in progress
 - `errorMessage`: String containing any authentication errors
 */
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if user != nil {
                    PluckrLogger.success("User authenticated: \(user?.email ?? "Unknown")")
                    // Initialize organization service for authenticated user
                    await OrganizationService.shared.initializeIfAuthenticated()
                } else {
                    PluckrLogger.info("User signed out")
                }
            }
        }
    }
    
    /**
     *Signs in a user with email and password*
     
     - Parameter email: User's email address
     - Parameter password: User's password
     - Returns: True if sign in was successful, false otherwise
     - Note: Sets `errorMessage` if sign in fails
     - Note: Sets `isLoading` to true during the operation
     */
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            PluckrLogger.success("User signed in successfully: \(result.user.email ?? "Unknown")")
            
            // Initialize organization service for signed in user
            await OrganizationService.shared.initializeIfAuthenticated()
            
            isLoading = false
            return true
        } catch {
            PluckrLogger.error("Sign in failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /**
     *Signs out the current user*
     
     - Note: Clears the current user state
     - Note: Sets `errorMessage` if sign out fails
     */
    func signOut() {
        do {
            try Auth.auth().signOut()
            PluckrLogger.info("User signed out successfully")
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            PluckrLogger.error("Sign out failed: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    /**
     *Deletes the current user account*
     
     This method permanently deletes the user's Firebase Auth account
     and clears all associated data. This action cannot be undone.
     
     - Returns: True if deletion was successful, false otherwise
     - Note: Sets `errorMessage` if deletion fails
     - Note: Sets `isLoading` to true during the operation
     - Warning: This action is irreversible
     */
    func deleteAccount() async -> Bool {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user is currently signed in"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete user profile document if it exists
            try await db.collection("users").document(user.uid).delete()
            PluckrLogger.info("User profile document deleted")
            
            // Delete the Firebase Auth account
            try await user.delete()
            PluckrLogger.success("User account deleted successfully")
            
            // Clear local state
            self.currentUser = nil
            self.isAuthenticated = false
            isLoading = false
            return true
        } catch {
            PluckrLogger.error("Account deletion failed: \(error.localizedDescription)")
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /**
     *Creates a new user account*
     
     - Parameter email: User's email address
     - Parameter password: User's password (minimum 6 characters)
     - Parameter displayName: User's display name
     - Returns: True if user creation was successful, false otherwise
     - Note: Creates a provider document in Firestore
     - Note: Sets `errorMessage` if creation fails
     - Note: Sets `isLoading` to true during the operation
     */
    func createUser(email: String, password: String, displayName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Create user profile document
            let userProfile: [String: Any] = [
                "displayName": displayName,
                "email": result.user.email ?? "",
                "createdAt": Timestamp(date: Date())
            ]
            try await db.collection("users").document(result.user.uid).setData(userProfile)
            PluckrLogger.success("User profile created for user: \(result.user.uid)")
            
            // Create provider document (will be skipped if no organization context)
            try await createProviderDocument(userId: result.user.uid, displayName: displayName)
            
            PluckrLogger.success("User created successfully: \(result.user.email ?? "Unknown")")
            isLoading = false
            return true
        } catch {
            PluckrLogger.error("User creation failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    private func createProviderDocument(userId: String, displayName: String) async throws {
        // Check if user has an organization - if not, skip provider document creation
        // Provider document will be created when they join/create an organization
        guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
            PluckrLogger.info("No organization context for user \(userId) - provider document will be created when they join an organization")
            return
        }
        
        let providerData: [String: Any] = [
            "name": displayName,
            "email": currentUser?.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "isActive": true
        ]
        
        try await db.collection("organizations")
            .document(orgId)
            .collection("providers")
            .document(userId)
            .setData(providerData)
        PluckrLogger.success("Provider document created for user: \(userId) in org \(orgId)")
    }
    
    // Create provider doc for a user joining an org as a provider
    func createProviderDocForInviteJoin(orgId: String, userId: String, displayName: String, email: String, completion: @escaping (Bool) -> Void) {
        let providerData: [String: Any] = [
            "name": displayName,
            "email": email,
            "createdAt": Timestamp(date: Date()),
            "isActive": true,
            "role": "provider"
        ]
        db.collection("organizations")
            .document(orgId)
            .collection("providers")
            .document(userId)
            .setData(providerData) { error in
                if let error = error {
                    PluckrLogger.error("Failed to create provider doc for invite join: \(error.localizedDescription)")
                    completion(false)
                } else {
                    PluckrLogger.success("Provider doc created for user: \(userId) in org \(orgId)")
                    completion(true)
                }
            }
    }
}

