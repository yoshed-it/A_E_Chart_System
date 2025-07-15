import SwiftUI

/**
 *Probe configuration selection component*
 
 This component allows selection between one-piece and two-piece probe
 configurations, with appropriate probe options for each type.
 
 ## Usage
 ```swift
 ProbePickerView(
     usingOnePiece: $viewModel.usingOnePiece,
     selectedOnePieceProbe: $viewModel.selectedOnePieceProbe,
     selectedTwoPieceProbe: $viewModel.selectedTwoPieceProbe
 )
 ```
 */
struct ProbePickerView: View {
    @Binding var usingOnePiece: Bool
    @Binding var selectedOnePieceProbe: String
    @Binding var selectedTwoPieceProbe: String

    var body: some View {
        VStack(spacing: PluckrTheme.spacing) {
            // Probe Type Selection
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text("Probe Configuration")
                    .font(.journalCaption)
                    .foregroundColor(PluckrTheme.secondaryColor)
                    .padding(.horizontal, PluckrTheme.padding)
                
                Picker("Probe Style", selection: $usingOnePiece) {
                    Text("One-Piece").tag(true)
                    Text("Two-Piece").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, PluckrTheme.padding)
            }
            .padding(.vertical, PluckrTheme.spacing)
            .background(Color.white)
            .cornerRadius(PluckrTheme.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Probe Selection
            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                Text(usingOnePiece ? "One-Piece Probe" : "Two-Piece Probe")
                    .font(.journalCaption)
                    .foregroundColor(PluckrTheme.secondaryColor)
                    .padding(.horizontal, PluckrTheme.padding)
                
                if usingOnePiece {
                    Picker("1 Piece Probe", selection: $selectedOnePieceProbe) {
                        ForEach(ProbeOptions.onePieceProbes, id: \.self) { probe in
                            Text(probe)
                                .font(.journalBody)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, PluckrTheme.padding)
                } else {
                    Picker("2 Piece Probe", selection: $selectedTwoPieceProbe) {
                        ForEach(ProbeOptions.twoPieceProbes, id: \.self) { probe in
                            Text(probe)
                                .font(.journalBody)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, PluckrTheme.padding)
                }
            }
            .padding(.vertical, PluckrTheme.spacing)
            .background(Color.white)
            .cornerRadius(PluckrTheme.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    ProbePickerView(
        usingOnePiece: .constant(true),
        selectedOnePieceProbe: .constant("0.1mm"),
        selectedTwoPieceProbe: .constant("0.1mm")
    )
    .padding()
    .background(PluckrTheme.backgroundColor)
}
