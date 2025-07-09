import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

struct ChartEntryData {
    var modality: String
    var rfLevel: Double
    var dcLevel: Double
    var probe: String
    var probeIsOnePiece: Bool
    var treatmentArea: String
    var notes: String
    var imageURLs: [String]
    var createdAt: Date
    var createdBy: String
    var createdByName: String
    var clientChosenName: String
    var clientLegalName: String
    var lastEditedAt: Date? = nil
    var lastEditedBy: String? = nil

    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "modality": modality,
            "rfLevel": rfLevel,
            "dcLevel": dcLevel,
            "probe": probe,
            "probeIsOnePiece": probeIsOnePiece,
            "treatmentArea": treatmentArea,
            "notes": notes,
            "imageURLs": imageURLs,
            "createdAt": Timestamp(date: createdAt),
            "createdBy": createdBy,
            "createdByName": createdByName,
            "clientChosenName": clientChosenName,
            "clientLegalName": clientLegalName
        ]
        if let lastEditedAt = lastEditedAt {
            dict["lastEditedAt"] = Timestamp(date: lastEditedAt)
        }
        if let lastEditedBy = lastEditedBy {
            dict["lastEditedBy"] = lastEditedBy
        }
        return dict
    }
}

class ChartService {
    static let shared = ChartService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    func saveChartEntry(for clientId: String, chartData: ChartEntryData, chartId: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let chartRef = db.collection("clients").document(clientId).collection("charts")
        let docRef = chartId == nil ? chartRef.document() : chartRef.document(chartId!)

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
}
