import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CreateOrganizationViewModel: ObservableObject {
    @Published var orgName: String = ""
    @Published var orgDescription: String = ""
    @Published var isCreating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    var onOrgCreated: ((String) -> Void)? = nil
    
    func createOrganization() async {
        isCreating = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // Use the OrganizationService to create the organization properly
            let organization = try await OrganizationService.shared.createOrganization(
                name: orgName,
                description: orgDescription.isEmpty ? nil : orgDescription
            )
            
            successMessage = "Organization created successfully!"
            onOrgCreated?(organization.id)
        } catch {
            errorMessage = "Failed to create organization: \(error.localizedDescription)"
        }
        
        isCreating = false
    }
} 