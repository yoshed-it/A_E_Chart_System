/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartTreatmentAreaSection: View {
    @Binding var treatmentArea: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Treatment Area")
                .pluckrSectionHeader()
            TreatmentAreaField(treatmentArea: $treatmentArea)
        }
    }
}

#Preview {
    @State var treatmentArea = "Upper Lip"
    return ChartTreatmentAreaSection(treatmentArea: $treatmentArea)
        .padding()
        .background(PluckrTheme.background)
} 