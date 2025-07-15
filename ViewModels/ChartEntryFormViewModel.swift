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
    @Published var chartId: String? = nil // Track current chartId
    @Published var isLoading: Bool = false
    
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
                errorMessage = "Failed to upload image: \(error.localizedDescription)"
            }
        }
        
        uploadedImageURLs.append(contentsOf: uploadedURLs)
        isSaving = false
    }
    
    // MARK: - Load Chart For Editing
    func loadChart(for clientId: String, chartId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let entry = try await ChartService.shared.loadChartEntry(for: clientId, chartId: chartId) {
                self.selectedModality = entry.modality
                self.rfLevel = entry.rfLevel
                self.dcLevel = entry.dcLevel
                self.usingOnePiece = entry.probeIsOnePiece
                self.selectedOnePieceProbe = entry.probeIsOnePiece ? entry.probe : ""
                self.selectedTwoPieceProbe = entry.probeIsOnePiece ? "" : entry.probe
                self.treatmentArea = entry.treatmentArea ?? ""
                self.notes = entry.notes
                self.uploadedImageURLs = entry.imageURLs
                self.chartId = chartId
            }
        } catch {
            self.errorMessage = "Failed to load chart: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Save Chart
    func saveChart(for clientId: String, chartId: String? = nil, completion: @escaping (Bool) -> Void) {
        PluckrLogger.info("Attempting to save chart for clientId: \(clientId)")
        isSaving = true
        
        if let chartId = chartId {
            print("[ChartEntryFormViewModel] Updating existing chart with ID: \(chartId)")
        } else {
            print("[ChartEntryFormViewModel] Creating new chart entry")
        }
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
        
        ChartService.shared.saveChartEntry(for: clientId, chartData: chartData, chartId: chartId) { [weak self] result in
            Task { @MainActor in
                self?.isSaving = false
                switch result {
                case .success:
                    PluckrLogger.success("Chart saved successfully")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    PluckrLogger.error("Failed to save chart: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}
