// MARK: - ChartEntryFormView.swift

import SwiftUI
import PhotosUI

/**
 *Chart entry form for creating and editing treatment records*
 
 This view provides a comprehensive form for electrolysis providers to record
 treatment details including machine settings, probe information, treatment areas,
 notes, and image uploads.
 
 ## Features
 - Machine settings (RF/DC levels)
 - Probe selection (one-piece or two-piece)
 - Treatment area specification
 - Clinical notes
 - Image capture and upload
 - Real-time validation
 */
struct ChartEntryFormView: View {
    // MARK: - Properties
    @StateObject var viewModel: ChartEntryFormViewModel
    let clientId: String
    let chartId: String?
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var imageSelections: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showRfWheel = false
    @State private var showDcWheel = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingChartTagPicker = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle(chartId == nil ? "New Chart" : "Edit Chart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .alert("Success", isPresented: $showSuccessAlert) { Button("OK") { showSuccessAlert = false } } message: { Text(chartId == nil ? "Chart entry created successfully." : "Chart entry updated successfully.") }
                .alert("Error", isPresented: $showErrorAlert) { Button("OK") { showErrorAlert = false } } message: { Text(viewModel.errorMessage ?? "An error occurred.") }
                .alert("Validation Error", isPresented: $showValidationAlert) { Button("OK") { showValidationAlert = false } } message: { Text(validationMessage) }
                .onChange(of: viewModel.errorMessage) { _, newValue in if let newValue = newValue, !newValue.isEmpty { showErrorAlert = true } }
                .overlay { overlays }
        }
        .sheet(isPresented: $showCamera) { cameraSheet }
        .sheet(isPresented: $showingChartTagPicker) { tagPickerSheet }
        .onChange(of: imageSelections) { _, newValue in handleImageUpload(newValue) }
        .onAppear { onAppearLogic() }
    }

    // MARK: - Toolbar
    private var toolbarContent: some ToolbarContent {
        Group{
            
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(PluckrTheme.accent)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { validateAndSave() }
                    .foregroundColor(PluckrTheme.accent)
                    .font(PluckrTheme.bodyFont())
                    .disabled(viewModel.isSaving)
            }
        }
    }

    // MARK: - Overlays
    private var overlays: some View {
        Group {
            if showRfWheel {
                BottomPickerDrawer(
                    title: "RF Level",
                    isPresented: $showRfWheel,
                    value: $viewModel.rfLevel,
                    range: 0.1...300.0,
                    unit: "MHz"
                ).zIndex(2)
            }
            if showDcWheel {
                BottomPickerDrawer(
                    title: "DC Level",
                    isPresented: $showDcWheel,
                    value: $viewModel.dcLevel,
                    range: 0.1...300.0,
                    unit: "mA"
                ).zIndex(2)
            }
        }
    }

    // MARK: - Sheets
    private var cameraSheet: some View {
        CameraCaptureView { image in handleImageCapture(image) }
    }
    private var tagPickerSheet: some View {
        TagPickerModal(
            selectedTags: $viewModel.chartTags,
            availableTags: [],
            context: .chart
        )
    }

    // MARK: - Main Content
    private var mainContent: some View {
        return ZStack {
            PluckrTheme.background.ignoresSafeArea()
            if viewModel.isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        headerSection
                        formContent
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    .padding(.bottom, PluckrTheme.verticalPadding)
                }
            }
            if viewModel.isSaving {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView("Saving...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    .shadow(radius: 10)
                    .zIndex(3)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        return VStack(spacing: 4) {
            Text(chartId == nil ? "New Chart Entry" : "Edit Chart Entry")
                .font(PluckrTheme.headingFont(size: 28))
                .foregroundColor(PluckrTheme.textPrimary)
            Text("Record treatment details")
                .font(PluckrTheme.captionFont())
                .foregroundColor(PluckrTheme.textSecondary)
        }
        .padding(.top, PluckrTheme.verticalPadding)
        .padding(.bottom, 8)
    }

    // MARK: - Form Content
    private var formContent: some View {
        return VStack(spacing: PluckrTheme.verticalPadding) {
            ChartModalitySection(selectedModality: $viewModel.selectedModality)
            ChartMachineSettingsSection(
                rfLevel: $viewModel.rfLevel,
                dcLevel: $viewModel.dcLevel,
                showRfPicker: $showRfWheel,
                showDcPicker: $showDcWheel
            )
            ChartProbeSelectionSection(
                usingOnePiece: $viewModel.usingOnePiece,
                selectedOnePieceProbe: $viewModel.selectedOnePieceProbe,
                selectedTwoPieceProbe: $viewModel.selectedTwoPieceProbe
            )
            ChartTreatmentAreaSection(treatmentArea: $viewModel.treatmentArea)
            ChartNotesSection(notes: $viewModel.notes)
            ChartImageUploadSection(
                uploadedImageURLs: $viewModel.uploadedImageURLs,
                showCamera: $showCamera,
                errorMessage: Binding(
                    get: { viewModel.imageUploadErrorMessage },
                    set: { viewModel.imageUploadErrorMessage = $0 ?? "" }
                )
            )
            ChartTagsSection(
                chartTags: viewModel.chartTags,
                onShowTagPicker: { showingChartTagPicker = true }
            )
        }
    }

    // MARK: - Logic
    private func onAppearLogic() {
        if let chartId = chartId, chartId != viewModel.chartId {
            PluckrLogger.info("Loading chart for editing: \(chartId)")
            Task {
                await viewModel.loadChart(for: clientId, chartId: chartId)
            }
        }
    }

    // MARK: - Actions
    private func saveChart() {
        PluckrLogger.info("Saving chart (chartId: \(chartId ?? "new"))")
        viewModel.saveChart(for: clientId, chartId: chartId) { success in
            if success {
                PluckrLogger.info("Chart saved successfully (chartId: \(chartId ?? "new"))")
                showSuccessAlert = true
                onSave()
                dismiss()
            } else {
                PluckrLogger.info("Chart save failed (chartId: \(chartId ?? "new"))")
                showErrorAlert = true
            }
        }
    }
    
    // MARK: - Helpers
    private func handleImageUpload(_ selections: [PhotosPickerItem]) {
        // Use async/await properly with @MainActor
        Task { @MainActor in
            await viewModel.uploadSelectedImages(from: selections, clientId: clientId)
        }
    }

    private func handleImageCapture(_ image: UIImage) {
        // Use async/await properly with @MainActor
        Task { @MainActor in
            if let url = await CameraUploader.uploadImage(image: image, clientId: clientId) {
                viewModel.uploadedImageURLs.append(url)
            } else {
                viewModel.imageUploadErrorMessage = "Upload failed."
            }
        }
    }

    private func validateAndSave() {
        var missingFields: [String] = []
        
        // Check required fields
        if viewModel.selectedModality.isEmpty {
            missingFields.append("Treatment Modality")
        }
        
        if viewModel.usingOnePiece && viewModel.selectedOnePieceProbe.isEmpty {
            missingFields.append("One-Piece Probe")
        } else if !viewModel.usingOnePiece && viewModel.selectedTwoPieceProbe.isEmpty {
            missingFields.append("Two-Piece Probe")
        }
        
        if viewModel.treatmentArea.isEmpty {
            missingFields.append("Treatment Area")
        }
        
        if !missingFields.isEmpty {
            validationMessage = "Please complete the following required fields:\n\n• " + missingFields.joined(separator: "\n• ")
            showValidationAlert = true
        } else {
            saveChart()
        }
    }
}
