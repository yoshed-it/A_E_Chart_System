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
            
            // If user has organizations, should go to main app
            if !organizationService.userOrganizations.isEmpty {
                shouldNavigateToMainApp = true
            }
            // If no organizations, stay on this view to let user create one
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    

    
    func createOrganization(name: String, description: String?) async {
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