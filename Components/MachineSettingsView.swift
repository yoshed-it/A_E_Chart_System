import SwiftUI

/**
 *Machine settings configuration component*
 
 This component provides controls for setting RF and DC levels for
 electrolysis treatment machines.
 
 ## Usage
 ```swift
 MachineSettingsView(
     rfLevel: $viewModel.rfLevel,
     dcLevel: $viewModel.dcLevel,
     showRfPicker: $showRfWheel,
     showDcPicker: $showDcWheel
 )
 ```
 */
struct MachineSettingsView: View {
    @Binding var rfLevel: Double
    @Binding var dcLevel: Double
    @Binding var showRfPicker: Bool
    @Binding var showDcPicker: Bool

    var body: some View {
        VStack(spacing: PluckrTheme.spacing) {
            // RF Setting
            Button(action: { showRfPicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RF Level")
                            .font(.journalBody)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Radio Frequency")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f", rfLevel))
                            .font(.journalSubtitle)
                            .fontWeight(.semibold)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Text("MHz")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.secondaryColor)
                }
                .padding(PluckrTheme.padding)
                .background(Color.white)
                .cornerRadius(PluckrTheme.cornerRadius)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())

            // DC Setting
            Button(action: { showDcPicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DC Level")
                            .font(.journalBody)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Direct Current")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f", dcLevel))
                            .font(.journalSubtitle)
                            .fontWeight(.semibold)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Text("mA")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.secondaryColor)
                }
                .padding(PluckrTheme.padding)
                .background(Color.white)
                .cornerRadius(PluckrTheme.cornerRadius)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    MachineSettingsView(
        rfLevel: .constant(15.0),
        dcLevel: .constant(2.5),
        showRfPicker: .constant(false),
        showDcPicker: .constant(false)
    )
    .padding()
    .background(PluckrTheme.backgroundColor)
}
