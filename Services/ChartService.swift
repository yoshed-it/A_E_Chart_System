import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

// MARK: - Chart Service Errors
enum ChartServiceError: LocalizedError {
    case invalidImageData
    case downloadURLFailed
    case invalidURL
    case organizationNotFound
    case clientNotFound
    case chartNotFound
    case saveFailed
    case loadFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data"
        case .downloadURLFailed:
            return "Failed to get download URL"
        case .invalidURL:
            return "Invalid URL"
        case .organizationNotFound:
            return "Organization not found"
        case .clientNotFound:
            return "Client not found"
        case .chartNotFound:
            return "Chart not found"
        case .saveFailed:
            return "Failed to save chart"
        case .loadFailed:
            return "Failed to load chart"
        case .deleteFailed:
            return "Failed to delete chart"
        }
    }
}

@MainActor
class ChartService: ObservableObject {
    static let shared = ChartService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}
    
    // MARK: - CRUD Operations
    
    /// Save or update a chart entry
    func saveChartEntry(for clientId: String, chartData: ChartEntryData, chartId: String? = nil) async throws {
        guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
            throw ChartServiceError.organizationNotFound
        }
        
        let chartRef = db.collection("organizations")
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
        
        do {
            try await docRef.setData(data, merge: true)
            PluckrLogger.success("Chart saved successfully in org \(orgId)")
        } catch {
            PluckrLogger.error("Failed to save chart in org \(orgId): \(error.localizedDescription)")
            throw ChartServiceError.saveFailed
        }
    }
    
    /// Load a single chart entry
    func loadChartEntry(for clientId: String, chartId: String) async throws -> ChartEntry {
        guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
            throw ChartServiceError.organizationNotFound
        }
        
        do {
            let doc = try await db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .document(chartId)
                .getDocument()
            
            guard let data = doc.data() else {
                throw ChartServiceError.chartNotFound
            }
            
            return ChartEntry(id: doc.documentID, data: data)
        } catch {
            PluckrLogger.error("Failed to load chart entry: \(error.localizedDescription)")
            throw ChartServiceError.loadFailed
        }
    }
    
    /// Load all chart entries for a client
    func loadChartEntries(for clientId: String) async throws -> [ChartEntry] {
        guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
            throw ChartServiceError.organizationNotFound
        }
        
        do {
            let snapshot = try await db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let entries = snapshot.documents.compactMap { doc in
                ChartEntry(id: doc.documentID, data: doc.data())
            }
            
            PluckrLogger.success("Loaded \(entries.count) chart entries for client \(clientId)")
            return entries
        } catch {
            PluckrLogger.error("Failed to load chart entries: \(error.localizedDescription)")
            throw ChartServiceError.loadFailed
        }
    }
    
    /// Delete a chart entry
    func deleteChartEntry(for clientId: String, chartId: String) async throws {
        guard let orgId = await OrganizationService.shared.getCurrentOrganizationId() else {
            throw ChartServiceError.organizationNotFound
        }
        
        do {
            try await db.collection("organizations")
                .document(orgId)
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .document(chartId)
                .delete()
            
            PluckrLogger.success("Chart entry deleted successfully")
        } catch {
            PluckrLogger.error("Failed to delete chart entry: \(error.localizedDescription)")
            throw ChartServiceError.deleteFailed
        }
    }

    // MARK: - Image Management
    
    /// Upload a single image
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ChartServiceError.invalidImageData
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let imageRef = storage.reference().child("chart-images/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            PluckrLogger.success("Image uploaded successfully")
            return downloadURL.absoluteString
        } catch {
            PluckrLogger.error("Failed to upload image: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Delete an image
    func deleteImage(url: String) async throws {
        guard let imageURL = URL(string: url) else {
            throw ChartServiceError.invalidURL
        }
        
        do {
            let imageRef = storage.reference(forURL: imageURL.absoluteString)
            try await imageRef.delete()
            PluckrLogger.success("Image deleted successfully")
        } catch {
            PluckrLogger.error("Failed to delete image: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    /// Legacy method for backward compatibility
    func saveChartEntry(for clientId: String, chartData: ChartEntryData, chartId: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await saveChartEntry(for: clientId, chartData: chartData, chartId: chartId)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Legacy method for backward compatibility
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let url = try await uploadImage(image)
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Legacy method for backward compatibility
    func deleteImage(url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await deleteImage(url: url)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}


