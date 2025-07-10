import SwiftUI

// MARK: - ProbePickerView
struct ProbePickerView: View {
    @Binding var usingOnePiece: Bool
    @Binding var selectedOnePieceProbe: String
    @Binding var selectedTwoPieceProbe: String

    var body: some View {
        Section(header: Text("Probe Type")) {
            Picker("Probe Style", selection: $usingOnePiece) {
                Text("1 Piece").tag(true)
                Text("2 Piece").tag(false)
            }
            .pickerStyle(.segmented)

            if usingOnePiece {
                Picker("1 Piece Probe", selection: $selectedOnePieceProbe) {
                    ForEach(ProbeOptions.onePieceProbes, id: \.self) { Text($0) }
                }
            } else {
                Picker("2 Piece Probe", selection: $selectedTwoPieceProbe) {
                    ForEach(ProbeOptions.twoPieceProbes, id: \.self) { Text($0) }
                }
            }
        }
    }
}
