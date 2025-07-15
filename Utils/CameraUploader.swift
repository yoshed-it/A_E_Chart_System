import FirebaseStorage
import UIKit
import CryptoKit
import Security

/**
 *Camera image upload utility*
 * HIPAA-SAFE: This uploader encrypts images before upload and never saves to Photos.
 * All image data is handled in-memory only.
 * Uses org-wide AES key from OrgEncryptionKeyManager.
 */
struct CameraUploader {
    static func uploadImage(image: UIImage, clientId: String) async -> String? {
        // 1. Convert to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            PluckrLogger.error("Failed to compress image data")
            return nil
        }

        // 2. Encrypt data with org-wide AES-GCM key
        guard let key = OrgEncryptionKeyManager.shared.orgKey else {
            PluckrLogger.error("No org-wide AES key available for encryption (HIPAA)")
            return nil
        }
        guard let encryptedData = AESHelper.encrypt(data: imageData, key: key) else {
            PluckrLogger.error("Image encryption failed")
            return nil
        }
        PluckrLogger.info("Image encrypted with org-wide key for HIPAA compliance")

        // 3. Upload encrypted data
        let filename = UUID().uuidString + ".enc"
        let ref = Storage.storage().reference().child("charts/\(clientId)/\(filename)")
        do {
            PluckrLogger.info("Uploading encrypted image: \(filename) for client: \(clientId)")
            let _ = try await ref.putDataAsync(encryptedData, metadata: nil)
            let downloadURL = try await ref.downloadURL().absoluteString
            PluckrLogger.success("Encrypted image uploaded successfully: \(downloadURL)")
            return downloadURL
        } catch {
            PluckrLogger.error("Encrypted image upload failed: \(error.localizedDescription)")
            return nil
        }
    }
}

/// Helper for AES encryption (no longer manages key storage)
enum AESHelper {
    static func encrypt(data: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            PluckrLogger.error("AES encryption error: \(error.localizedDescription)")
            return nil
        }
    }
}
