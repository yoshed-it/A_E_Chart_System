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
        } catch {
            PluckrLogger.error("Sign out failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
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
            
            // Create provider document
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
        let providerData: [String: Any] = [
            "name": displayName,
            "email": currentUser?.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "isActive": true
        ]
        
        try await db.collection("providers").document(userId).setData(providerData)
        PluckrLogger.success("Provider document created for user: \(userId)")
    }
}

