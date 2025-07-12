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
    @State private var showRfWheel = false
    @State private var showDcWheel = false

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
                showRfPicker: $showRfWheel,
                showDcPicker: $showDcWheel
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
