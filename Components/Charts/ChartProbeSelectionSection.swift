/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartProbeSelectionSection: View {
    @Binding var usingOnePiece: Bool
    @Binding var selectedOnePieceProbe: String
    @Binding var selectedTwoPieceProbe: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Probe Selection")
                .pluckrSectionHeader()
            ProbePickerView(
                usingOnePiece: $usingOnePiece,
                selectedOnePieceProbe: $selectedOnePieceProbe,
                selectedTwoPieceProbe: $selectedTwoPieceProbe
            )
        }
    }
}

#Preview {
    @State var usingOnePiece = true
    @State var selectedOnePieceProbe = "F3"
    @State var selectedTwoPieceProbe = "K2"
    return ChartProbeSelectionSection(
        usingOnePiece: $usingOnePiece,
        selectedOnePieceProbe: $selectedOnePieceProbe,
        selectedTwoPieceProbe: $selectedTwoPieceProbe
    )
    .padding()
    .background(PluckrTheme.background)
} 