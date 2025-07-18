import Foundation
import FirebaseAuth

@MainActor
class OrganizationSelectionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToMainApp = false
    
    private let organizationService = OrganizationService.shared
    
    func loadOrganizations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await organizationService.fetchUserOrganizations()
            
            // If user has no organizations, automatically create one
            if organizationService.userOrganizations.isEmpty {
                await createDefaultOrganization()
            } else {
                // User has organizations, should go to main app
                shouldNavigateToMainApp = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func createDefaultOrganization() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No authenticated user found"
            return
        }
        
        do {
            PluckrLogger.info("User has no organizations, auto-creating one")
            let organization = try await organizationService.createOrganization(
                name: "\(user.displayName ?? "User")'s Practice",
                description: "Your medical practice"
            )
            PluckrLogger.info("Auto-created organization: \(organization.name)")
            
            // Refresh organizations and navigate to main app
            try await organizationService.fetchUserOrganizations()
            shouldNavigateToMainApp = true
        } catch {
            errorMessage = "Failed to create organization: \(error.localizedDescription)"
        }
    }
    
    func createOrganization(name: String, description: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let organization = try await organizationService.createOrganization(
                name: name,
                description: description
            )
            PluckrLogger.info("Created organization: \(organization.name)")
            shouldNavigateToMainApp = true
        } catch {
            errorMessage = "Failed to create organization: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 