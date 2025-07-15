import FirebaseStorage
import UIKit

/**
 *Camera image upload utility*
 
 This utility handles uploading captured images to Firebase Storage
 with proper error handling and logging.
 
 ## Usage
 ```swift
 if let url = await CameraUploader.uploadImage(image: capturedImage, clientId: clientId) {
     // Image uploaded successfully
 }
 ```
 */
struct CameraUploader {
    static func uploadImage(image: UIImage, clientId: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { 
            PluckrLogger.error("Failed to compress image data")
            return nil 
        }
        
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("charts/\(clientId)/\(filename)")
        
        do {
            PluckrLogger.info("Uploading image: \(filename) for client: \(clientId)")
            let _ = try await ref.putDataAsync(imageData, metadata: nil)
            let downloadURL = try await ref.downloadURL().absoluteString
            PluckrLogger.success("Image uploaded successfully: \(downloadURL)")
            return downloadURL
        } catch {
            PluckrLogger.error("Image upload failed: \(error.localizedDescription)")
            return nil
        }
    }
}
