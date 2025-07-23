import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Provider: Identifiable, Equatable {
    let id: String
    var name: String
    var email: String
    var role: String
    var isActive: Bool
}

struct InviteCode: Identifiable, Equatable {
    let id: String // The code itself
    var createdBy: String
    var createdAt: Date
    var used: Bool
    var expiresAt: Date?
}

@MainActor
class AdminDashboardViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var inviteCodes: [InviteCode] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    var orgId: String? {
        OrganizationService.shared.getCurrentOrganizationId()
    }
    
    func loadProviders() async {
        guard let orgId = orgId else { return }
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("organizations").document(orgId).collection("providers").getDocuments()
            self.providers = snapshot.documents.compactMap { doc in
                let data = doc.data()
                return Provider(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    role: data["role"] as? String ?? "provider",
                    isActive: data["isActive"] as? Bool ?? true
                )
            }
        } catch {
            errorMessage = "Failed to load providers: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func loadInviteCodes() async {
        guard let orgId = orgId else { return }
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("organizations").document(orgId).collection("invites").getDocuments()
            self.inviteCodes = snapshot.documents.compactMap { doc in
                let data = doc.data()
                return InviteCode(
                    id: doc.documentID,
                    createdBy: data["createdBy"] as? String ?? "",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                    used: data["used"] as? Bool ?? false,
                    expiresAt: (data["expiresAt"] as? Timestamp)?.dateValue()
                )
            }
        } catch {
            errorMessage = "Failed to load invite codes: \(error.localizedDescription)"
        }
    }
    
    func generateInviteCode(completion: @escaping (String?) -> Void) {
        guard let orgId = orgId, let userId = Auth.auth().currentUser?.uid else { completion(nil); return }
        InviteCodeManager.shared.storeInviteCode(orgId: orgId, createdBy: userId) { code in
            Task { @MainActor in
                if let code = code {
                    self.successMessage = "Invite code generated: \(code)"
                    await self.loadInviteCodes()
                } else {
                    self.errorMessage = "Failed to generate invite code."
                }
                completion(code)
            }
        }
    }
    
    func updateProviderRole(providerId: String, newRole: String) async {
        guard let orgId = orgId else { return }
        let db = Firestore.firestore()
        do {
            try await db.collection("organizations").document(orgId).collection("providers").document(providerId).updateData(["role": newRole])
            await loadProviders()
        } catch {
            errorMessage = "Failed to update provider role: \(error.localizedDescription)"
        }
    }
    
    func updateProviderStatus(providerId: String, isActive: Bool) async {
        guard let orgId = orgId else { return }
        let db = Firestore.firestore()
        do {
            try await db.collection("organizations").document(orgId).collection("providers").document(providerId).updateData(["isActive": isActive])
            await loadProviders()
        } catch {
            errorMessage = "Failed to update provider status: \(error.localizedDescription)"
        }
    }
} 