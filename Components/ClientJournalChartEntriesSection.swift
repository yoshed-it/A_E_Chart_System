/// Used in: ClientJournalView (Views/Clients/ClientJournalView.swift)
import SwiftUI

struct ClientJournalChartEntriesSection: View {
    let entries: [ChartEntry]
    let onEntryTap: (ChartEntry) -> Void
    var body: some View {
        List {
            ForEach(entries) { entry in
                Button(action: { onEntryTap(entry) }) {
                    ChartEntryCard(entry: entry)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    ClientJournalChartEntriesSection(entries: [], onEntryTap: { _ in })
} 