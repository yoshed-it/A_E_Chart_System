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
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Modality")
                .pluckrSectionHeader()
            
            Picker("Modality", selection: $selectedModality) {
                ForEach(modalities, id: \.self) { modality in
                    Text(modality)
                        .font(PluckrTheme.bodyFont())
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(PluckrTheme.card)
        .cornerRadius(PluckrTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                .stroke(PluckrTheme.borderColor, lineWidth: 1)
        )
        .shadow(color: PluckrTheme.shadowMedium, radius: PluckrTheme.shadowRadiusMedium, x: 0, y: PluckrTheme.shadowYMedium)
    }
}

#Preview {
    ModalityPickerView(selectedModality: .constant("Thermolysis"))
        .padding()
        .background(PluckrTheme.background)
}
