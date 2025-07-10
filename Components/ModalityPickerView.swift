import SwiftUI

struct ModalityPickerView: View {
    @Binding var selectedModality: String

    let modalities = ["Thermolysis", "Galvanic", "Blend"]

    var body: some View {
        Section(header: Text("Modality")) {
            Picker("Modality", selection: $selectedModality) {
                ForEach(modalities, id: \.self) { modality in
                    Text(modality)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
