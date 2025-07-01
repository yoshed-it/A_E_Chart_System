import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

let onePieceProbes = ["F2 Gold", "F3 Gold", "F4 Gold", "F5 Gold", "F2 Insulated", "F3 Insulated", "F4 Insulated", "F5 Insulated"]
let twoPieceProbes = ["F2 Gold", "F3 Gold", "F4 Gold", "F5 Gold", "F2 Insulated", "F3 Insulated", "F4 Insulated", "F5 Insulated"]

struct ChartEntryFormView: View {
    let clientId: String
    var existingChart: ChartEntry? = nil
    var onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selectedModality: String
    @State private var rfSetting: Int
    @State private var dcSetting: Int
    @State private var selectedOnePieceProbe: String
    @State private var selectedTwoPieceProbe: String
    @State private var usingOnePiece: Bool
    @State private var treatmentArea: String
    @State private var notes: String
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var showRfPicker = false
    @State private var showDcPicker = false
    @State private var imageSelections: [PhotosPickerItem] = []
    @State private var uploadedImageURLs: [String] = []

    let modalities = ["Thermolysis", "Galvanic", "Blend"]

    var chartId: String? { existingChart?.id }

    var selectedProbe: String {
        usingOnePiece ? selectedOnePieceProbe : selectedTwoPieceProbe
    }

    init(existingChart: ChartEntry? = nil, onSave: @escaping () -> Void, clientId: String) {
        self.existingChart = existingChart
        self.onSave = onSave
        self.clientId = clientId

        let chart = existingChart

        _selectedModality = State(initialValue: chart?.modality ?? "Thermolysis")
        _rfSetting = State(initialValue: chart?.rfLevel ?? 50)
        _dcSetting = State(initialValue: chart?.dcLevel ?? 50)
        _selectedOnePieceProbe = State(initialValue: chart?.probe ?? "F2 Gold")
        _selectedTwoPieceProbe = State(initialValue: chart?.probe ?? "F2 Gold")
        _usingOnePiece = State(initialValue: {
            guard let probe = chart?.probe else { return true }
            return onePieceProbes.contains(probe)
        }())
        _treatmentArea = State(initialValue: chart?.treatmentArea ?? "")
        _notes = State(initialValue: chart?.notes ?? "")
        _uploadedImageURLs = State(initialValue: chart?.images ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Modality")) {
                    Picker("Modality", selection: $selectedModality) {
                        ForEach(modalities, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Machine Settings")) {
                    Button(action: { showRfPicker = true }) {
                        HStack {
                            Text("RF Setting")
                            Spacer()
                            Text("\(rfSetting)").foregroundColor(.secondary)
                        }
                    }
                    Button(action: { showDcPicker = true }) {
                        HStack {
                            Text("DC Setting")
                            Spacer()
                            Text("\(dcSetting)").foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Probe Type")) {
                    Picker("Probe Style", selection: $usingOnePiece) {
                        Text("1 Piece").tag(true)
                        Text("2 Piece").tag(false)
                    }
                    .pickerStyle(.segmented)

                    if usingOnePiece {
                        Picker("1 Piece Probe", selection: $selectedOnePieceProbe) {
                            ForEach(onePieceProbes, id: \.self) { Text($0) }
                        }
                    } else {
                        Picker("2 Piece Probe", selection: $selectedTwoPieceProbe) {
                            ForEach(twoPieceProbes, id: \.self) { Text($0) }
                        }
                    }
                }

                Section(header: Text("Treatment Area")) {
                    TextField("e.g. Chin, Upper Lip", text: $treatmentArea)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                Section(header: Text("Images")) {
                    PhotosPicker("Select Images", selection: $imageSelections, maxSelectionCount: 5, matching: .images)
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

                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button(chartId == nil ? "Save Chart Entry" : "Update Chart") {
                        uploadImagesThenSave()
                    }
                    .disabled(isSaving || treatmentArea.isEmpty)
                }
            }
            .navigationTitle(chartId == nil ? "New Chart" : "Edit Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(perform: populateFromExistingChart)
        .sheet(isPresented: $showRfPicker) {
            wheelPickerSheet(title: "RF Setting", selection: $rfSetting) {
                showRfPicker = false
            }
        }
        .sheet(isPresented: $showDcPicker) {
            wheelPickerSheet(title: "DC Setting", selection: $dcSetting) {
                showDcPicker = false
            }
        }
        .onChange(of: imageSelections) { _, _ in
            Task { await uploadSelectedImages() }
        }
        .onChange(of: existingChart?.id) { _, _ in
            populateFromExistingChart()
        }
    }

    func populateFromExistingChart() {
        guard let chart = existingChart else { return }
        selectedModality = chart.modality
        rfSetting = chart.rfLevel
        dcSetting = chart.dcLevel
        treatmentArea = chart.treatmentArea
        notes = chart.notes
        uploadedImageURLs = chart.images
        if onePieceProbes.contains(chart.probe) {
            usingOnePiece = true
            selectedOnePieceProbe = chart.probe
        } else {
            usingOnePiece = false
            selectedTwoPieceProbe = chart.probe
        }
    }

    func uploadImagesThenSave() {
        saveOrUpdateChart()
    }

    func uploadSelectedImages() async {
        guard Auth.auth().currentUser != nil else { return }
        let storage = Storage.storage()
        var urls: [String] = uploadedImageURLs

        for item in imageSelections {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let filename = UUID().uuidString + ".jpg"
                let ref = storage.reference().child("charts/\(clientId)/\(filename)")
                do {
                    _ = try await ref.putDataAsync(data, metadata: nil)
                    let url = try await ref.downloadURL()
                    urls.append(url.absoluteString)
                } catch {
                    print("❌ Upload error: \(error.localizedDescription)")
                }
            }
        }
        uploadedImageURLs = urls
    }

    func saveOrUpdateChart() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in."
            return
        }

        let baseRef = Firestore.firestore().collection("clients").document(clientId).collection("charts")
        let chartRef = chartId == nil ? baseRef.document() : baseRef.document(chartId!)

        let now = Timestamp(date: Date())
        var chartData: [String: Any] = [
            "modality": selectedModality,
            "rfLevel": rfSetting,
            "dcLevel": dcSetting,
            "probe": selectedProbe,
            "treatmentArea": treatmentArea,
            "notes": notes,
            "images": uploadedImageURLs
        ]

        if chartId == nil {
            chartData["createdBy"] = user.uid
            chartData["createdAt"] = now
        } else {
            chartData["lastEditedBy"] = user.uid
            chartData["lastEditedAt"] = now
        }

        print("Saving chart with ID: \(chartRef.documentID), chartId is: \(chartId ?? "nil")") // WHICH CHARTS ARE SAVING?!

        
        isSaving = true
        chartRef.setData(chartData, merge: true) { error in
            isSaving = false
            if let error = error {
                errorMessage = "Failed to save chart: \(error.localizedDescription)"
            } else {
                onSave()
                dismiss()
            }
        }
    }

    func wheelPickerSheet(title: String, selection: Binding<Int>, onDone: @escaping () -> Void) -> some View {
        NavigationStack {
            VStack {
                Picker(title, selection: selection) {
                    ForEach(0...100, id: \.self) { val in
                        Text("\(val)").tag(val)
                    }
                }
                .labelsHidden()
                .pickerStyle(.wheel)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDone() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onDone() }
                }
            }
        }
        .presentationDetents([.fraction(0.25)])
        .presentationDragIndicator(.visible)
    }
}
