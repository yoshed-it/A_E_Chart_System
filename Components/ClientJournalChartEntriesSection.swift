import SwiftUI

struct ClientJournalChartEntriesSection: View {
    let entries: [ChartEntry]
    let onEntryTap: (ChartEntry) -> Void
    let onEdit: (ChartEntry) -> Void
    let onDelete: (ChartEntry) -> Void

    var body: some View {
        VStack(spacing: 16) {
            ForEach(entries) { entry in
                SwipeToDeleteView(
                    onDelete: { onDelete(entry) },
                    onEdit: { onEdit(entry) }
                ) {
                    ChartEntryCard(entry: entry, onTap: { onEntryTap(entry) })
                }
            }
        }
    }
} 