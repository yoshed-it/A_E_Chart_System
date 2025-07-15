import Foundation
import CryptoKit
import UIKit

/// Decrypts chart image blobs using the org-wide AES key from OrgEncryptionKeyManager.
struct ChartImageDecryptor {
    static func decryptImageData(_ data: Data, with key: SymmetricKey) -> UIImage? {
        do {
            let box = try AES.GCM.SealedBox(combined: data)
            let decrypted = try AES.GCM.open(box, using: key)
            return UIImage(data: decrypted)
        } catch {
            PluckrLogger.error("Failed to decrypt chart image: \(error)")
            return nil
        }
    }
} 