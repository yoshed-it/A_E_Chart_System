import SwiftUI

/**
 *Treatment modality selection component*
 
 This component provides a segmented control for selecting the electrolysis
 treatment modality (Thermolysis, Galvanic, or Blend).
 
 ## Usage
 ```swift
 ModalityPickerView(selectedModality: $viewModel.selectedModality)
 ```
 */
struct ModalityPickerView: View {
    @Binding var selectedModality: String

    let modalities = ["Thermolysis", "Galvanic", "Blend"]

    var body: some View {
        VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
            Text("Select Modality")
                .font(.journalCaption)
                .foregroundColor(PluckrTheme.secondaryColor)
                .padding(.horizontal, PluckrTheme.padding)
            
            Picker("Modality", selection: $selectedModality) {
                ForEach(modalities, id: \.self) { modality in
                    Text(modality)
                        .font(.journalBody)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, PluckrTheme.padding)
        }
        .padding(.vertical, PluckrTheme.spacing)
        .background(Color.white)
        .cornerRadius(PluckrTheme.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ModalityPickerView(selectedModality: .constant("Thermolysis"))
        .padding()
        .background(PluckrTheme.backgroundColor)
}
