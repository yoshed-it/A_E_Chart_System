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
        VStack(spacing: 16) {
            // RF Setting
            Button(action: { showRfPicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RF Level")
                            .font(PluckrTheme.bodyFont())
                            .fontWeight(.medium)
                            .foregroundColor(PluckrTheme.textPrimary)
                        
                        Text("Radio Frequency")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f", rfLevel))
                            .font(PluckrTheme.subheadingFont())
                            .fontWeight(.semibold)
                            .foregroundColor(PluckrTheme.textPrimary)
                        
                        Text("MHz")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.textSecondary)
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
            .buttonStyle(PlainButtonStyle())

            // DC Setting
            Button(action: { showDcPicker = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DC Level")
                            .font(PluckrTheme.bodyFont())
                            .fontWeight(.medium)
                            .foregroundColor(PluckrTheme.textPrimary)
                        
                        Text("Direct Current")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f", dcLevel))
                            .font(PluckrTheme.subheadingFont())
                            .fontWeight(.semibold)
                            .foregroundColor(PluckrTheme.textPrimary)
                        
                        Text("mA")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PluckrTheme.textSecondary)
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
    .background(PluckrTheme.background)
}
