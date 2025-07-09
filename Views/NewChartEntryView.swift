import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NewChartEntryView: View {
    let clientId: String
    var onSave: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedModality: String = "Thermolysis"
    @State private var rfSetting: Int = 50
    @State private var dcSetting: Int = 50
    @State private var selectedOnePieceProbe: String = "F2 Gold"
    @State private var selectedTwoPieceProbe: String = "F2 Gold"
    @State private var usingOnePiece: Bool = true
    @State private var treatmentArea: String = ""
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var showRfPicker = false
    @State private var showDcPicker = false
    
    let modalities = ["Thermolysis", "Galvanic", "Blend"]
    let onePieceProbes = ["F2 Gold", "F3 Gold", "F4 Gold", "F5 Gold", "F2 Insulated", "F3 Insulated", "F4 Insulated", "F5 Insulated"]
    let twoPieceProbes = ["F2 Gold", "F3 Gold", "F4 Gold", "F5 Gold", "F2 Insulated", "F3 Insulated", "F4 Insulated", "F5 Insulated"]
    
    var selectedProbe: String {
        usingOnePiece ? selectedOnePieceProbe : selectedTwoPieceProbe
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
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Save Chart Entry") {
                        saveChart()
                    }
                    .disabled(isSaving || treatmentArea.isEmpty)
                }
            }
            .navigationTitle("New Chart")
            .navigationBarTitleDisplayMode(.inline)
            
            // RF Sheet
            .sheet(isPresented: $showRfPicker) {
                NavigationStack {
                    VStack {
                        Picker("RF", selection: $rfSetting) {
                            ForEach(0...100, id: \.self) { val in
                                Text("\(val)").tag(val)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.wheel)
                    }
                    .navigationTitle("RF Setting")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showRfPicker = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showRfPicker = false }
                        }
                    }
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
            }
            
            // DC Sheet
            .sheet(isPresented: $showDcPicker) {
                NavigationStack {
                    VStack {
                        Picker("DC", selection: $dcSetting) {
                            ForEach(0...100, id: \.self) { val in
                                Text("\(val)").tag(val)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.wheel)
                    }
                    .navigationTitle("DC Setting")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showDcPicker = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showDcPicker = false }
                        }
                    }
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
            }
        }
    }
        
        func saveChart() {
            guard let user = Auth.auth().currentUser else {
                errorMessage = "You must be logged in."
                return
            }
            
            let chartRef = Firestore.firestore()
                .collection("clients")
                .document(clientId)
                .collection("charts")
                .document()
            
            let chartData: [String: Any] = [
                "createdBy": user.uid,
                "createdAt": Timestamp(date: Date()),
                "modality": selectedModality,
                "rfLevel": rfSetting,
                "dcLevel": dcSetting,
                "probe": selectedProbe,
                "treatmentArea": treatmentArea,
                "notes": notes,
                "images": []
            ]
            
            isSaving = true
            chartRef.setData(chartData) { error in
                isSaving = false
                if let error = error {
                    errorMessage = "Failed to save chart: \(error.localizedDescription)"
                } else {
                    onSave()
                    dismiss()
                }
            }
        }
    }

