import SwiftUI

struct NewChartEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NewChartEntryViewModel()
    
    @State private var showCamera = false
    @State private var uploadedImageURLs: [String] = []
    
    let clientId: String
    var onSave: (() -> Void)? = nil
    
    var modalities = ["Thermolysis", "Galvanic", "Blend"]
    var probeOptions = ["F2 Gold", "F3 Gold", "F4 Gold", "F5 Gold", "F2 Insulated", "F3 Insulated", "F4 Insulated", "F5 Insulated"]

    var body: some View {
        Form {
            Section(header: Text("Modality")) {
                Picker("Modality", selection: $viewModel.modality) {
                    ForEach(modalities, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Machine Settings")) {
                RFLevelPicker(value: $viewModel.rfLevel)
                DCLevelPicker(value: $viewModel.dcLevel)
            }

            Section(header: Text("Probe")) {
                Picker("Probe", selection: $viewModel.probe) {
                    ForEach(probeOptions, id: \.self) { Text($0) }
                }
            }

            Section(header: Text("Treatment Area")) {
                TextField("e.g. Chin, Lip", text: $viewModel.treatmentArea)
            }

            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.notes).frame(height: 120)
            }

            Section {
                if viewModel.isSaving {
                    ProgressView("Saving...")
                } else {
                    Button("Save Chart") {
                        viewModel.saveChart(for: clientId) { success in
                            if success {
                                onSave?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.treatmentArea.isEmpty)
                }

                if let error = viewModel.errorMessage {
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                }
            }
            Section(header: Text("Photos")) {
                Button("Take Photo") {
                    showCamera = true
                }
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(uploadedImageURLs, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable().scaledToFit().frame(height: 100).cornerRadius(8)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("New Chart Entry")
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                Task {
                    if let url = await viewModel.uploadImage(image, clientId: clientId) {
                        uploadedImageURLs.append(url)
                    }
                }
            }
        }
    }
}
