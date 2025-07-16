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
    @State private var showingChartTagPicker = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                PluckrTheme.backgroundColor
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: PluckrTheme.spacing * 2) {
                            // Header
                            VStack(spacing: PluckrTheme.spacing) {
                                Text(chartId == nil ? "New Chart Entry" : "Edit Chart Entry")
                                    .font(.journalTitle)
                                    .foregroundColor(PluckrTheme.primaryColor)
                                
                                Text("Record treatment details")
                                    .font(.journalCaption)
                                    .foregroundColor(PluckrTheme.secondaryColor)
                            }
                            .padding(.top, PluckrTheme.padding)
                            
                            // Form Content
                            formContent()
                        }
                        .padding(.horizontal, PluckrTheme.padding)
                    }
                }

                // Saving overlay
                if viewModel.isSaving {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView("Saving...")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                        .shadow(radius: 10)
                }
            }
            .navigationTitle(chartId == nil ? "New Chart" : "Edit Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PluckrTheme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChart()
                    }
                    .font(.journalSubtitle)
                    .fontWeight(.semibold)
                    .foregroundColor(PluckrTheme.primaryColor)
                    .disabled(viewModel.isSaving || viewModel.treatmentArea.isEmpty)
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    showSuccessAlert = false
                }
            } message: {
                Text(chartId == nil ? "Chart entry created successfully." : "Chart entry updated successfully.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") {
                    showErrorAlert = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred.")
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                if let newValue = newValue, !newValue.isEmpty {
                    showErrorAlert = true
                }
            }
            .overlay {
                Group {
                    if showRfWheel {
                        BottomPickerDrawer(
                            title: "RF Level",
                            isPresented: $showRfWheel,
                            value: $viewModel.rfLevel,
                            range: 0.1...300.0,
                            unit: "MHz"
                        )
                    }

                    if showDcWheel {
                        BottomPickerDrawer(
                            title: "DC Level",
                            isPresented: $showDcWheel,
                            value: $viewModel.dcLevel,
                            range: 0.1...300.0,
                            unit: "mA"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                handleImageCapture(image)
            }
        }
        .sheet(isPresented: $showingChartTagPicker) {
            TagPickerModal(
                selectedTags: $viewModel.chartTags,
                availableTags: [], // This will be loaded dynamically by TagPickerModal
                context: .chart
            )
        }
        .onChange(of: imageSelections) { _, newValue in
            handleImageUpload(newValue)
        }
        .onAppear {
            if let chartId = chartId, chartId != viewModel.chartId {
                PluckrLogger.info("Loading chart for editing: \(chartId)")
                Task {
                    await viewModel.loadChart(for: clientId, chartId: chartId)
                }
            }
        }
    }

    // MARK: - Form Content
    private func formContent() -> some View {
        VStack(spacing: PluckrTheme.spacing * 2) {
            // Modality Selection
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Treatment Modality")
                    .font(.journalSubtitle)
                    .foregroundColor(PluckrTheme.primaryColor)
                
                ModalityPickerView(selectedModality: $viewModel.selectedModality)
            }
            
            // Machine Settings
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Machine Settings")
                    .font(.journalSubtitle)
                    .foregroundColor(PluckrTheme.primaryColor)
                
                MachineSettingsView(
                    rfLevel: $viewModel.rfLevel,
                    dcLevel: $viewModel.dcLevel,
                    showRfPicker: $showRfWheel,
                    showDcPicker: $showDcWheel
                )
            }
            
            // Probe Selection
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Probe Configuration")
                    .font(.journalSubtitle)
                    .foregroundColor(PluckrTheme.primaryColor)
                
                ProbePickerView(
                    usingOnePiece: $viewModel.usingOnePiece,
                    selectedOnePieceProbe: $viewModel.selectedOnePieceProbe,
                    selectedTwoPieceProbe: $viewModel.selectedTwoPieceProbe
                )
            }
            
            // Treatment Area
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Treatment Area")
                    .font(.journalSubtitle)
                    .foregroundColor(PluckrTheme.primaryColor)
                
                TreatmentAreaField(treatmentArea: $viewModel.treatmentArea)
            }
            
            // Clinical Notes
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Clinical Notes")
                    .font(.journalSubtitle)
                    .foregroundColor(PluckrTheme.primaryColor)
                
                NotesFieldView(notes: $viewModel.notes)
            }
            
            // Chart Tags
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                HStack {
                    Text("Chart Tags")
                        .font(.journalSubtitle)
                        .foregroundColor(PluckrTheme.primaryColor)
                    
                    Spacer()
                    
                    Button {
                        showingChartTagPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(PluckrTheme.accentColor)
                            .font(.title3)
                    }
                }
                
                if viewModel.chartTags.isEmpty {
                    Text("No tags added yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(viewModel.chartTags) { tag in
                            TagView(tag: tag)
                        }
                    }
                }
            }
            
            // Image Upload
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Treatment Images")
                    .font(.journalSubtitle)
                    .foregroundColor(PluckrTheme.primaryColor)
                
                ImageUploadView(
                    uploadedImageURLs: $viewModel.uploadedImageURLs,
                    showCamera: $showCamera,
                    errorMessage: $viewModel.imageUploadErrorMessage
                )
            }
            
            // Error Display
            if let errorMessage = viewModel.imageUploadErrorMessage {
                ErrorView(error: errorMessage)
            }
            
            Spacer(minLength: 100)
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
}
