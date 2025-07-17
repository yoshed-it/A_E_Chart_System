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
    
    @StateObject private var probeService = ProbeService.shared
    @State private var showCustomProbeSheet = false
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            // Probe Type Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Probe Type")
                    .pluckrSectionHeader()
                
                Picker("Probe Style", selection: $usingOnePiece) {
                    Text("One-Piece").tag(true)
                    Text("Two-Piece").tag(false)
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
            
            // Probe Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(usingOnePiece ? "One-Piece Probe" : "Two-Piece Probe")
                        .pluckrSectionHeader()
                    
                    Spacer()
                    
                    Button(action: { showCustomProbeSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(PluckrTheme.accent)
                            .font(PluckrTheme.subheadingFont(size: 22))
                    }
                }
                
                if probeService.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading probes...")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(PluckrTheme.background)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(PluckrTheme.borderColor, lineWidth: 1)
                    )
                } else {
                    let currentType: Probe.ProbeType = usingOnePiece ? .onePiece : .twoPiece
                    let availableProbes = probeService.getProbes(for: currentType)
                    
                    if availableProbes.isEmpty {
                        VStack(spacing: 8) {
                            Text("No probes available")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Button("Add Custom Probe") {
                                showCustomProbeSheet = true
                            }
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(PluckrTheme.background)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PluckrTheme.borderColor, lineWidth: 1)
                        )
                    } else {
                        Picker("Probe Selection", selection: usingOnePiece ? $selectedOnePieceProbe : $selectedTwoPieceProbe) {
                            ForEach(availableProbes) { probe in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(probe.name)
                                        .font(PluckrTheme.bodyFont())
                                    if probe.isCustom {
                                        Text(probe.specifications)
                                            .font(PluckrTheme.captionFont())
                                            .foregroundColor(PluckrTheme.textSecondary)
                                    }
                                }
                                .tag(probe.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(PluckrTheme.background)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PluckrTheme.borderColor, lineWidth: 1)
                        )
                    }
                }
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
        .sheet(isPresented: $showCustomProbeSheet) {
            CustomProbeSheet(
                isPresented: $showCustomProbeSheet,
                onProbeCreated: { _ in
                    // The probe service will automatically refresh
                }
            )
        }
        .onAppear {
            if probeService.probes.isEmpty {
                probeService.fetchProbes()
            }
        }
    }
}

#Preview {
    ProbePickerView(
        usingOnePiece: .constant(true),
        selectedOnePieceProbe: .constant("F2 Gold"),
        selectedTwoPieceProbe: .constant("F2 Gold")
    )
    .padding()
    .background(PluckrTheme.background)
}
