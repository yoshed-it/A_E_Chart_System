// MARK: - ChartEntryFormView.swift

import SwiftUI
import PhotosUI

struct ChartEntryFormView: View {
    // MARK: - Properties
    @StateObject var viewModel: ChartEntryFormViewModel
    let clientId: String
    let chartId: String?
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var imageSelections: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showRfPicker = false
    @State private var showDcPicker = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            formContent()
                .navigationTitle(chartId == nil ? "New Chart" : "Edit Chart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                handleImageCapture(image)
            }
        }
        .sheet(isPresented: $showRfPicker) {
            RFLevelPicker(value: $viewModel.rfLevel)
        }
        .sheet(isPresented: $showDcPicker) {
            DCLevelPicker(value: $viewModel.dcLevel)
        }
        .onChange(of: imageSelections) {
            handleImageUpload($0)
        }
    }

    // MARK: - Form Content
    private func formContent() -> some View {
        Form {
            ModalityPickerView(selectedModality: $viewModel.selectedModality)

            MachineSettingsView(
                rfLevel: $viewModel.rfLevel,
                dcLevel: $viewModel.dcLevel,
                showRfPicker: $showRfPicker,
                showDcPicker: $showDcPicker
            )

            ProbePickerView(
                usingOnePiece: $viewModel.usingOnePiece,
                selectedOnePieceProbe: $viewModel.selectedOnePieceProbe,
                selectedTwoPieceProbe: $viewModel.selectedTwoPieceProbe
            )

            TreatmentAreaField(treatmentArea: $viewModel.treatmentArea)
            NotesFieldView(notes: $viewModel.notes)

            ImageUploadView(
                uploadedImageURLs: $viewModel.uploadedImageURLs,
                showCamera: $showCamera,
                errorMessage: $viewModel.imageUploadErrorMessage
            )

            ErrorView(error: viewModel.imageUploadErrorMessage)

            SaveButtonView(
                isSaving: viewModel.isSaving,
                treatmentArea: viewModel.treatmentArea,
                chartId: chartId
            ) {
                viewModel.saveChart(for: clientId) { success in
                    if success {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func handleImageUpload(_ selections: [PhotosPickerItem]) {
        Task {
            await viewModel.uploadSelectedImages(from: selections, clientId: clientId)
        }
    }

    private func handleImageCapture(_ image: UIImage) {
        Task {
            if let url = await CameraUploader.uploadImage(image: image, clientId: clientId) {
                await MainActor.run {
                    viewModel.uploadedImageURLs.append(url)
                }
            } else {
                await MainActor.run {
                    viewModel.imageUploadErrorMessage = "Upload failed."
                }
            }
        }
    }
}
