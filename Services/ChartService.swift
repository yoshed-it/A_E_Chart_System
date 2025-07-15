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
        let chartRef = db.collection("clients").document(clientId).collection("charts")
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
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Upload Single Image
    func uploadImage(_ image: UIImage, clientId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "compression", code: -1, userInfo: nil)))
            return
        }

        let filename = UUID().uuidString + ".jpg"
        let ref = storage.reference().child("charts/\(clientId)/\(filename)")

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(error ?? NSError(domain: "url", code: -2, userInfo: nil)))
                }
            }
        }
    }

    // MARK: - Upload Multiple Images
    func uploadMultipleImages(_ images: [UIImage], clientId: String, completion: @escaping ([String]) -> Void) {
        var uploadedURLs: [String] = []
        let group = DispatchGroup()

        for image in images {
            group.enter()
            uploadImage(image, clientId: clientId) { result in
                if case .success(let url) = result {
                    uploadedURLs.append(url)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }

    // MARK: - Load Single Chart Entry
    /// Loads a single chart entry by chartId for a given clientId
    func loadChartEntry(for clientId: String, chartId: String) async throws -> ChartEntry? {
        let docRef = db.collection("clients").document(clientId).collection("charts").document(chartId)
        let snapshot = try await docRef.getDocument()
        guard let data = snapshot.data() else { return nil }
        return ChartEntry(id: snapshot.documentID, data: data)
    }
}


