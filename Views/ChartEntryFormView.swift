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

    // MARK: - Camera Binding
    private var cameraBinding: Binding<UIImage?> {
        Binding<UIImage?>(
            get: { nil },
            set: { newImage in
                guard let newImage else { return }
                Task {
                    if let url = await CameraUploader.uploadImage(image: newImage, clientId: clientId) {
                        viewModel.uploadedImageURLs.append(url)
                    } else {
                        viewModel.imageUploadErrorMessage = "Upload failed."
                    }
                }
            }
        )
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            formContent()
                .navigationTitle(chartId == nil ? "New Chart" : "Edit Chart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(image: cameraBinding)
        }
        .sheet(isPresented: $showRfPicker) {
            RFLevelPicker(title: "RF Level", level: $viewModel.rfLevel) {
                showRfPicker = false
            }
        }
        .sheet(isPresented: $showDcPicker) {
            DCLevelPicker(title: "DC Level", level: $viewModel.dcLevel) {
                showDcPicker = false
            }
        }
        .onChange(of: imageSelections) { newSelections in
            Task(priority: .userInitiated) {
                await viewModel.uploadSelectedImages(from: newSelections, clientId: clientId)
            }
        }
    }

    // MARK: - Form Content (as method to avoid scope issues)
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
}
