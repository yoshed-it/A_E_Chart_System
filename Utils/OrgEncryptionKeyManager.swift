import Foundation
import FirebaseFirestore
import CryptoKit

/// Manages the org-wide AES encryption key for HIPAA-compliant image encryption.
/// Never persists the decrypted key to disk or Keychain.
class OrgEncryptionKeyManager: ObservableObject {
    static let shared = OrgEncryptionKeyManager()
    @Published private(set) var orgKey: SymmetricKey?
    private var orgId: String = "demo-clinic" // TODO: infer from user profile
    private let devFallbackKey = SymmetricKey(data: Data(repeating: 0x42, count: 32))

    /// Fetches the org-wide AES key from Firestore if not already cached.
    /// Uses a dev fallback key in simulator or if fetch fails.
    func fetchKeyIfNeeded() async {
        #if targetEnvironment(simulator)
        self.orgKey = devFallbackKey
        PluckrLogger.info("Using dev fallback AES key (simulator)")
        return
        #endif
        guard orgKey == nil else { return }
        do {
            let doc = try await Firestore.firestore()
                .collection("organizations")
                .document(orgId)
                .collection("encryptionKeys")
                .document("chartImages")
                .getDocument()
            if let keyString = doc.data()? ["key"] as? String,
               let keyData = Data(base64Encoded: keyString) {
                self.orgKey = SymmetricKey(data: keyData)
                PluckrLogger.info("Fetched org-wide AES key for \(orgId)")
            } else {
                PluckrLogger.error("Failed to fetch org-wide AES key for \(orgId): missing or invalid data")
                self.orgKey = devFallbackKey
            }
        } catch {
            PluckrLogger.error("Error fetching org-wide AES key: \(error)")
            self.orgKey = devFallbackKey
        }
    }
} 