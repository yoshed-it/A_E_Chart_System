/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartNotesSection: View {
    @Binding var notes: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clinical Notes")
                .pluckrSectionHeader()
            NotesCard(mode: .edit($notes))
        }
    }
}

#Preview {
    @State var notes = "Patient tolerated treatment well."
    return ChartNotesSection(notes: $notes)
        .padding()
        .background(PluckrTheme.background)
} 