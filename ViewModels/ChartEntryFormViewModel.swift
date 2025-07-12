// MARK: - ChartEntryFormViewModel.swift
import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth

@MainActor
final class ChartEntryFormViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedModality: String = ""
    @Published var rfLevel: Double = 0.1
    @Published var dcLevel: Double = 0.1
    @Published var usingOnePiece: Bool = true
    @Published var selectedOnePieceProbe: String = ""
    @Published var selectedTwoPieceProbe: String = ""
    @Published var treatmentArea: String = ""
    @Published var notes: String = ""
    @Published var uploadedImageURLs: [String] = []
    @Published var errorMessage: String? = nil
    @Published var isSaving: Bool = false
    @Published var imageUploadErrorMessage: String? = nil
    
    // MARK: - Init
    init() {}
    
    // MARK: - Upload Selected Images
    func uploadSelectedImages(from selections: [PhotosPickerItem], clientId: String) async {
        isSaving = true
        var uploadedURLs: [String] = []
        
        for item in selections {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let url = await CameraUploader.uploadImage(image: uiImage, clientId: clientId) {
                    uploadedURLs.append(url)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.uploadedImageURLs.append(contentsOf: uploadedURLs)
            self.isSaving = false
        }
    }
    
    // MARK: - Save Chart
    func saveChart(for clientId: String, completion: @escaping (Bool) -> Void) {
        print("📡 Attempting to save chart for clientId: \(clientId)")
        isSaving = true
        
        let chartData = ChartEntryData(
            modality: selectedModality,
            rfLevel: rfLevel,
            dcLevel: dcLevel,
            probe: usingOnePiece ? selectedOnePieceProbe : selectedTwoPieceProbe,
            probeIsOnePiece: usingOnePiece,
            treatmentArea: treatmentArea,
            notes: notes,
            imageURLs: uploadedImageURLs,
            createdAt: Date(),
            lastEditedAt: Date(),
            lastEditedBy: Auth.auth().currentUser?.displayName ?? "Unknown",
            createdBy: Auth.auth().currentUser?.uid ?? "Unknown",
            createdByName: Auth.auth().currentUser?.displayName ?? "Unknown",
            clientChosenName: nil,
            clientLegalName: nil
        )
        
        ChartService.shared.saveChartEntry(for: clientId, chartData: chartData, chartId: nil) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSaving = false
                switch result {
                case .success:
                    print("✅ Chart saved successfully")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Failed to save chart: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}
