import SwiftUI

struct ClientJournalChartEntriesSection: View {
    let entries: [ChartEntry]
    let onEntryTap: (ChartEntry) -> Void
    let onEdit: (ChartEntry) -> Void
    let onDelete: (ChartEntry) -> Void

    var body: some View {
        VStack(spacing: 16) {
            ForEach(entries) { entry in
                SwipeableRow(
                    leadingActions: [
                        SwipeAction(label: "Edit", systemImage: "pencil", tint: .accentColor, role: nil, action: { onEdit(entry) })
                    ],
                    trailingActions: [
                        SwipeAction(label: "Delete", systemImage: "trash", tint: .red, role: .destructive, action: { onDelete(entry) })
                    ]
                ) {
                    ChartEntryCard(entry: entry, onTap: { onEntryTap(entry) })
                }
            }
        }
    }
} 