import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

@MainActor
class NewChartEntryViewModel: ObservableObject {
    @Published var modality: String = "Thermolysis"
    @Published var probe: String = ""
    @Published var rfLevel: Double = 4.0         // 0–8 W
    @Published var dcLevel: Double = 1.5         // 0–3 mA
    @Published var treatmentArea: String = ""
    @Published var notes: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    func saveChart(for clientId: String, onComplete: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in."
            onComplete(false)
            return
        }
        isSaving = true

        let chartRef = Firestore.firestore()
            .collection("clients")
            .document(clientId)
            .collection("charts")
            .document()

        let data: [String: Any] = [
            "createdBy": user.uid,
            "createdAt": Timestamp(date: Date()),
            "modality": modality,
            "probe": probe,
            "rfLevel": String(format: "%.1f", rfLevel),
            "dcLevel": String(format: "%.2f", dcLevel),
            "treatmentArea": treatmentArea,
            "notes": notes,
            "imageURLs": []
        ]

        chartRef.setData(data) { [weak self] error in
            Task { @MainActor in
                self?.isSaving = false
                if let error = error {
                    self?.errorMessage = "Failed to save chart: \(error.localizedDescription)"
                    onComplete(false)
                } else {
                    onComplete(true)
                }
            }
        }
    }
}

extension NewChartEntryViewModel {
    func uploadImage(_ image: UIImage, clientId: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("❌ Failed to compress image")
            return nil
        }

        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("charts/\(clientId)/\(filename)")

        do {
            let _ = try await storageRef.putDataAsync(imageData, metadata: nil)
            let downloadURL = try await storageRef.downloadURL()
            print("✅ Uploaded image to: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString
        } catch {
            print("❌ Firebase upload failed: \(error.localizedDescription)")
            return nil
        }
    }
}
