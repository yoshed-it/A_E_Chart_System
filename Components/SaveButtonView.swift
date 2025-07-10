import SwiftUI

// MARK: - SaveButtonView
struct SaveButtonView: View {
    let isSaving: Bool
    let treatmentArea: String
    let chartId: String?
    let onSaveTapped: () -> Void

    var body: some View {
        Section {
            Button(chartId == nil ? "Save Chart Entry" : "Update Chart") {
                onSaveTapped()
            }
            .disabled(isSaving || treatmentArea.isEmpty)
        }
    }
}
