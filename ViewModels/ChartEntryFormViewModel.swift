import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import PhotosUI

@MainActor
class ChartEntryFormViewModel: ObservableObject {
    // MARK: - Input Properties
    @Published var selectedModality: String = "Thermolysis"
    @Published var rfLevel: Double = 4.0    // Range: 0–8 W
    @Published var dcLevel: Double = 1.5    // Range: 0–3 mA
    @Published var usingOnePiece: Bool = true
    @Published var selectedOnePieceProbe: String = ProbeOptions.onePieceProbes.first ?? ""
    @Published var selectedTwoPieceProbe: String = ProbeOptions.twoPieceProbes.first ?? ""
    @Published var treatmentArea: String = ""
    @Published var notes: String = ""
    @Published var uploadedImageURLs: [String] = []

    // MARK: - State & UI
    @Published var isSaving: Bool = false
    @Published var errorMessage: String = ""
    @Published var showRfPicker = false
    @Published var showDcPicker = false
    @Published var showCamera = false
    @Published var probeIsOnePiece: Bool

    // MARK: - Constants
    let modalities = ["Thermolysis", "Galvanic", "Blend"]
    let onePieceProbes = ProbeOptions.onePieceProbes
    let twoPieceProbes = ProbeOptions.twoPieceProbes

    // MARK: - Internal State
    private var clientId: String
    private var existingChart: ChartEntry?
    private var onSave: () -> Void

    var chartId: String? { existingChart?.id }

    // MARK: - Init
    init(clientId: String, chart: ChartEntry? = nil, onSave: @escaping () -> Void) {
        self.clientId = clientId
        self.existingChart = chart
        self.onSave = onSave

        if let chart = chart {
            selectedModality = chart.modality
            rfLevel = chart.rfLevel
            dcLevel = chart.dcLevel
            treatmentArea = chart.treatmentArea
            notes = chart.notes
            uploadedImageURLs = chart.imageURLs
            usingOnePiece = chart.probeIsOnePiece
            if chart.probeIsOnePiece {
                selectedOnePieceProbe = chart.probe
            } else {
                selectedTwoPieceProbe = chart.probe
            }
        }
    }

    // MARK: - Public Methods
    func uploadCameraImage(_ image: UIImage) async {
        guard let url = await CameraUploader.uploadImage(image: image, clientId: clientId) else {
            errorMessage = "Failed to upload image."
            return
        }
        uploadedImageURLs.append(url)
    }

    func uploadImagesThenSave() {
        saveChart(for: clientId) { success in
            if success {
                self.onSave()
            }
        }
    }

    func takePhoto() {
        showCamera = true
    }

    func saveChart(for clientId: String, onComplete: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in."
            onComplete(false)
            return
        }

        isSaving = true

        let chartData: [String: Any] = [
            "modality": selectedModality,
            "rfLevel": rfLevel,
            "dcLevel": dcLevel,
            "probe": usingOnePiece ? selectedOnePieceProbe : selectedTwoPieceProbe,
            "probeIsOnePiece": usingOnePiece,
            "treatmentArea": treatmentArea,
            "notes": notes,
            "imageURLs": uploadedImageURLs,
            "createdBy": user.uid,
            "createdAt": existingChart?.createdAt ?? FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let db = Firestore.firestore()
        let chartRef = db.collection("clients").document(clientId).collection("charts")

        if let existingId = existingChart?.id {
            chartRef.document(existingId).updateData(chartData) { error in
                self.isSaving = false
                if let error = error {
                    self.errorMessage = "Update failed: \(error.localizedDescription)"
                    onComplete(false)
                } else {
                    onComplete(true)
                }
            }
        } else {
            chartRef.addDocument(data: chartData) { error in
                self.isSaving = false
                if let error = error {
                    self.errorMessage = "Save failed: \(error.localizedDescription)"
                    onComplete(false)
                } else {
                    onComplete(true)
                }
            }
        }
    }
}
