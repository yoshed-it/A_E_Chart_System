import FirebaseStorage
import UIKit

struct CameraUploader {
    static func uploadImage(image: UIImage, clientId: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("charts/\(clientId)/\(filename)")
        do {
            let _ = try await ref.putDataAsync(imageData, metadata: nil)
            return try await ref.downloadURL().absoluteString
        } catch {
            print("Upload error: \(error)")
            return nil
        }
    }
}
