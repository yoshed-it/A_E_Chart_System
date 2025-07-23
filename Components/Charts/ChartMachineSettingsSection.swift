/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartMachineSettingsSection: View {
    @Binding var rfLevel: Double
    @Binding var dcLevel: Double
    @Binding var showRfPicker: Bool
    @Binding var showDcPicker: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Machine Settings")
                .pluckrSectionHeader()
            MachineSettingsView(
                rfLevel: $rfLevel,
                dcLevel: $dcLevel,
                showRfPicker: $showRfPicker,
                showDcPicker: $showDcPicker
            )
        }
    }
}

#Preview {
    @State var rfLevel = 13.5
    @State var dcLevel = 0.8
    @State var showRfPicker = false
    @State var showDcPicker = false
    return ChartMachineSettingsSection(
        rfLevel: $rfLevel,
        dcLevel: $dcLevel,
        showRfPicker: $showRfPicker,
        showDcPicker: $showDcPicker
    )
    .padding()
    .background(PluckrTheme.background)
} 