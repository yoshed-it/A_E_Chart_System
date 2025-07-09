import SwiftUI
import FirebaseStorage
import PhotosUI
//import ProbeOptions

struct ChartEntryFormView: View {
    @StateObject var viewModel: ChartEntryFormViewModel
    let clientId: String
    let chartId: String?
    let onSave: () -> Void
    let rfValues = Array(stride(from: 0.0, through: 10.0, by: 0.1))

    
    @Environment(\.dismiss) var dismiss
    @State private var showRfPicker = false
    @State private var showDcPicker = false
    @State private var imageSelections: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Modality")) {
                    Picker("Modality", selection: $viewModel.selectedModality) {
                        ForEach(["Thermolysis", "Galvanic", "Blend"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Machine Settings")) {
                    Button(action: { showRfPicker = true }) {
                        HStack {
                            Text("RF Setting")
                            Spacer()
                            Text("\(Int(viewModel.rfSetting))").foregroundColor(.secondary)
                        }
                    }
                    Button(action: { showDcPicker = true }) {
                        HStack {
                            Text("DC Setting")
                            Spacer()
                            Text("\(Int(viewModel.dcSetting))").foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Probe Type")) {
                    Picker("Probe Style", selection: $viewModel.usingOnePiece) {
                        Text("1 Piece").tag(true)
                        Text("2 Piece").tag(false)
                    }
                    .pickerStyle(.segmented)

                    if viewModel.usingOnePiece {
                        Picker("1 Piece Probe", selection: $viewModel.selectedOnePieceProbe) {
                            ForEach(ProbeOptions.onePieceProbes, id: \.self) { Text($0) }
                        }
                    } else {
                        Picker("2 Piece Probe", selection: $viewModel.selectedTwoPieceProbe) {
                            ForEach(ProbeOptions.twoPieceProbes, id: \.self) { Text($0) }
                        }
                    }
                }

                Section(header: Text("Treatment Area")) {
                    TextField("e.g. Chin, Upper Lip", text: $viewModel.treatmentArea)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $viewModel.notes)
                        .frame(height: 100)
                }

                Section(header: Text("Images")) {
                    Button("Take Photo") {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        } else {
                            viewModel.errorMessage = "Camera not available on this device."
                        }
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.uploadedImageURLs, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image.resizable().scaledToFit().frame(height: 100).cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundColor(.red)
                    }
                }

                Section {
                    Button(chartId == nil ? "Save Chart Entry" : "Update Chart") {
                        viewModel.saveChart(for: clientId) { success in
                            if success { onSave(); dismiss() }
                        }
                    }
                    .disabled(viewModel.isSaving || viewModel.treatmentArea.isEmpty)
                }
            }
            .navigationTitle(chartId == nil ? "New Chart" : "Edit Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(image: Binding(
                get: { nil },
                set: { newImage in
                    Task {
                        if let newImage = newImage {
                            if let url = await CameraUploader.uploadImage(image: newImage, clientId: clientId) {
                                viewModel.uploadedImageURLs.append(url)
                            }
                        }
                    }
                })
            )
        }
        .sheet(isPresented: $showRfPicker) {
            wheelPickerSheet(title: "RF Setting", selection: $viewModel.rfSetting) { showRfPicker = false }
        }
        .sheet(isPresented: $showDcPicker) {
            wheelPickerSheet(title: "DC Setting", selection: $viewModel.dcSetting) { showDcPicker = false }
        }
        .onChange(of: imageSelections) { _, _ in
            Task { await viewModel.uploadSelectedImages(from: imageSelections, clientId: clientId) }
        }
        .onAppear {
            if let chartId = chartId {
                // Optionally pre-load existing chart if not already loaded
            }
        }
    }

    func wheelPickerSheet(title: String, selection: Binding<Double>, onDone: @escaping () -> Void) -> some View {
        NavigationStack {
            VStack {
                Picker(title, selection: selection) {
                    ForEach(rfValues, id: \.self) { val in
                        Text(String(format: "%.1f", val)).tag(val)
                    }
                }
                .labelsHidden()
                .pickerStyle(.wheel)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { onDone() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { onDone() } }
            }
        }
        .presentationDetents([.fraction(0.25)])
        .presentationDragIndicator(.visible)
    }
}

