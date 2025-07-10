import SwiftUI

// MARK: - Machine Settings View
struct MachineSettingsView: View {
    @Binding var rfLevel: Double
    @Binding var dcLevel: Double
    @Binding var showRfPicker: Bool
    @Binding var showDcPicker: Bool

    var body: some View {
        Section(header: Text("Machine Settings")) {
            Button(action: { showRfPicker = true }) {
                HStack {
                    Text("RF Setting")
                    Spacer()
                    Text(String(format: "%.1f", rfLevel))
                        .foregroundColor(.secondary)
                }
            }

            Button(action: { showDcPicker = true }) {
                HStack {
                    Text("DC Setting")
                    Spacer()
                    Text(String(format: "%.1f", dcLevel))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
