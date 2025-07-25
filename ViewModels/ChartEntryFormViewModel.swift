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
    @Published var chartTags: [Tag] = []
    @Published var validationMessage: String? = nil
    @Published var showValidationAlert: Bool = false

    // MARK: - Dependencies
    private let chartService: ChartService
    private let tagService: TagService
    
    // MARK: - Init
    init(chartService: ChartService = AppEnvironment.live.chartService, tagService: TagService = AppEnvironment.live.tagService) {
        self.chartService = chartService
        self.tagService = tagService
    }
    
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
            let entry = try await chartService.loadChartEntry(for: clientId, chartId: chartId)
            self.selectedModality = entry.modality
            self.rfLevel = entry.rfLevel
            self.dcLevel = entry.dcLevel
            self.usingOnePiece = entry.probeIsOnePiece
            self.selectedOnePieceProbe = entry.probeIsOnePiece ? entry.probe : ""
            self.selectedTwoPieceProbe = entry.probeIsOnePiece ? "" : entry.probe
            self.treatmentArea = entry.treatmentArea ?? ""
            self.notes = entry.notes
            self.uploadedImageURLs = entry.imageURLs
            self.chartTags = entry.chartTags
            self.chartId = chartId
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
            clientLegalName: nil,
            chartTags: chartTags
        )
        
        chartService.saveChartEntry(for: clientId, chartData: chartData, chartId: chartId) { [weak self] result in
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
    
    // MARK: - Validation and Save
    func validateAndSaveChart(for clientId: String, chartId: String? = nil, onSuccess: @escaping () -> Void) {
        var missingFields: [String] = []
        if selectedModality.isEmpty {
            missingFields.append("Treatment Modality")
        }
        if usingOnePiece && selectedOnePieceProbe.isEmpty {
            missingFields.append("One-Piece Probe")
        } else if !usingOnePiece && selectedTwoPieceProbe.isEmpty {
            missingFields.append("Two-Piece Probe")
        }
        if treatmentArea.isEmpty {
            missingFields.append("Treatment Area")
        }
        if !missingFields.isEmpty {
            validationMessage = "Please complete the following required fields:\n\n• " + missingFields.joined(separator: "\n• ")
            showValidationAlert = true
            return
        }
        saveChart(for: clientId, chartId: chartId) { success in
            if success {
                onSuccess()
            }
        }
    }
}
