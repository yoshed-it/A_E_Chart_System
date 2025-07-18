/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartModalitySection: View {
    @Binding var selectedModality: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Treatment Modality")
                .pluckrSectionHeader()
            ModalityPickerView(selectedModality: $selectedModality)
        }
    }
}

#Preview {
    @State var selectedModality = "Thermolysis"
    return ChartModalitySection(selectedModality: $selectedModality)
        .padding()
        .background(PluckrTheme.background)
} 