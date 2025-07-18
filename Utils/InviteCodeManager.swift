import Foundation
import FirebaseFirestore

class InviteCodeManager {
    static let shared = InviteCodeManager()
    private let db = Firestore.firestore()
    private init() {}

    // Generate a random invite code
    func generateInviteCode(length: Int = 8) -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<length).map { _ in chars.randomElement()! })
    }

    // Store invite code in Firestore under the org
    func storeInviteCode(orgId: String, createdBy: String, expiresAt: Date? = nil, completion: @escaping (String?) -> Void) {
        let code = generateInviteCode()
        var data: [String: Any] = [
            "createdBy": createdBy,
            "createdAt": Timestamp(date: Date()),
            "used": false
        ]
        if let expiresAt = expiresAt {
            data["expiresAt"] = Timestamp(date: expiresAt)
        }
        db.collection("organizations").document(orgId).collection("invites").document(code).setData(data) { error in
            if let error = error {
                print("Failed to store invite code: \(error)")
                completion(nil)
            } else {
                completion(code)
            }
        }
    }

    // Validate invite code (returns orgId if valid, else nil)
    func validateInviteCode(orgId: String, code: String, completion: @escaping (Bool) -> Void) {
        let ref = db.collection("organizations").document(orgId).collection("invites").document(code)
        ref.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let used = data["used"] as? Bool, !used {
                // Optionally check for expiration
                if let expiresAt = data["expiresAt"] as? Timestamp, expiresAt.dateValue() < Date() {
                    completion(false)
                } else {
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }

    // Mark invite code as used
    func markInviteCodeUsed(orgId: String, code: String) {
        let ref = db.collection("organizations").document(orgId).collection("invites").document(code)
        ref.updateData(["used": true])
    }
} 