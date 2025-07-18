import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class JoinOrganizationViewModel: ObservableObject {
    @Published var inviteCode: String = ""
    @Published var orgId: String = ""
    @Published var isJoining: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    var onJoinSuccess: ((String, String) -> Void)? = nil
    
    func joinOrg() {
        isJoining = true
        errorMessage = nil
        successMessage = nil
        let trimmedCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let trimmedOrgId = orgId.trimmingCharacters(in: .whitespacesAndNewlines)
        InviteCodeManager.shared.validateInviteCode(orgId: trimmedOrgId, code: trimmedCode) { [weak self] isValid in
            Task { @MainActor in
                guard let self = self else { return }
                if isValid {
                    // Fetch org name for personalized message
                    let db = Firestore.firestore()
                    db.collection("organizations").document(trimmedOrgId).getDocument { snapshot, error in
                        let orgName = (snapshot?.data()? ["name"] as? String) ?? "your organization"
                        let possessive: String
                        if let last = orgName.last, last == "s" || last == "S" {
                            possessive = "\(orgName)' Journal"
                        } else {
                            possessive = "\(orgName)’s Journal"
                        }
                        // Create provider doc for this user
                        if let user = Auth.auth().currentUser {
                            let displayName = user.displayName ?? ""
                            let email = user.email ?? ""
                            AuthService.shared.createProviderDocForInviteJoin(orgId: trimmedOrgId, userId: user.uid, displayName: displayName, email: email) { success in
                                Task { @MainActor in
                                    self.isJoining = false
                                    if success {
                                        self.successMessage = "Welcome to \"\(possessive)\"!"
                                        InviteCodeManager.shared.markInviteCodeUsed(orgId: trimmedOrgId, code: trimmedCode)
                                        self.onJoinSuccess?(trimmedOrgId, trimmedCode)
                                    } else {
                                        self.errorMessage = "Failed to create provider account. Please try again."
                                    }
                                }
                            }
                        } else {
                            self.isJoining = false
                            self.errorMessage = "No authenticated user. Please log in again."
                        }
                    }
                } else {
                    self.isJoining = false
                    self.errorMessage = "Invalid or expired invite code. Please check and try again."
                }
            }
        }
    }
} 