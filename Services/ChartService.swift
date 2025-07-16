import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

class ChartService {
    static let shared = ChartService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}
    
    // MARK: - Save Chart Entry
    func saveChartEntry(for clientId: String, chartData: ChartEntryData, chartId: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        // Try organization-based structure first
        Task {
            if let orgId = await OrganizationService.shared.getCurrentOrganizationId() {
                let chartRef = self.db.collection("organizations")
                    .document(orgId)
                    .collection("clients")
                    .document(clientId)
                    .collection("charts")
                let docRef: DocumentReference
                
                if let chartId = chartId {
                    docRef = chartRef.document(chartId)
                } else {
                    docRef = chartRef.document()
                }

                var data = chartData.asDictionary

                if chartId != nil {
                    data["lastEditedAt"] = Timestamp(date: Date())
                    if let user = Auth.auth().currentUser {
                        data["lastEditedBy"] = user.displayName ?? user.uid
                    }
                }

                docRef.setData(data, merge: true) { error in
                    if let error = error {
                        PluckrLogger.error("Failed to save chart in org \(orgId): \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        PluckrLogger.success("Chart saved successfully in org \(orgId)")
                        completion(.success(()))
                    }
                }
            } else {
                // Fallback to root-level structure
                let chartRef = self.db.collection("clients").document(clientId).collection("charts")
                let docRef: DocumentReference
                
                if let chartId = chartId {
                    docRef = chartRef.document(chartId)
                } else {
                    docRef = chartRef.document()
                }

                var data = chartData.asDictionary

                if chartId != nil {
                    data["lastEditedAt"] = Timestamp(date: Date())
                    if let user = Auth.auth().currentUser {
                        data["lastEditedBy"] = user.displayName ?? user.uid
                    }
                }

                docRef.setData(data, merge: true) { error in
                    if let error = error {
                        PluckrLogger.error("Failed to save chart at root level: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        PluckrLogger.success("Chart saved successfully at root level")
                        completion(.success(()))
                    }
                }
            }
        }
    }

    // MARK: - Upload Single Image
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(ChartServiceError.invalidImageData))
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let imageRef = storage.reference().child("chart-images/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                } else {
                    completion(.failure(ChartServiceError.downloadURLFailed))
                }
            }
        }
    }
    
    // MARK: - Delete Image
    func deleteImage(url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(.failure(ChartServiceError.invalidURL))
            return
        }
        
        let imageRef = storage.reference(forURL: imageURL.absoluteString)
        imageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Load Single Chart Entry
    func loadChartEntry(for clientId: String, chartId: String) async throws -> ChartEntry? {
        if let orgId = await OrganizationService.shared.getCurrentOrganizationId() {
            let doc = try await db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .document(chartId)
                .getDocument()
            guard let data = doc.data() else { return nil }
            return ChartEntry(id: doc.documentID, data: data)
        } else {
            let doc = try await db.collection("clients")
                .document(clientId)
                .collection("charts")
                .document(chartId)
                .getDocument()
            guard let data = doc.data() else { return nil }
            return ChartEntry(id: doc.documentID, data: data)
        }
    }
}

// MARK: - Chart Service Errors
enum ChartServiceError: LocalizedError {
    case invalidImageData
    case downloadURLFailed
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data"
        case .downloadURLFailed:
            return "Failed to get download URL"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}


