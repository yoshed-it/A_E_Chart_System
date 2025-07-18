import SwiftUI

struct ChartEntryCard: View {
    let entry: ChartEntry
    var onTap: (() -> Void)? = nil
    @State private var showingTagDetail = false
    @State private var selectedTag: Tag? = nil
    @State private var showingChartDetail = false

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Date
                Text(entry.createdAt, style: .date)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)

                // Main details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("RF:")
                        Text(entry.rfLevel.formatted(.number.precision(.fractionLength(1)))) + Text(" MHz")
                        Spacer()
                        Text("DC:")
                        Text(entry.dcLevel.formatted(.number.precision(.fractionLength(1)))) + Text(" mA")
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textPrimary)

                    HStack {
                        Text("Probe:")
                        Spacer()
                        Text(entry.probe)
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textPrimary)

                    if let area = entry.treatmentArea {
                        HStack {
                            Text("Treatment Area:")
                            Spacer()
                            Text(area)
                        }
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                    }

                    if let condition = entry.skinCondition {
                        HStack {
                            Text("Skin Condition:")
                            Spacer()
                            Text(condition)
                        }
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                    }
                }

                // Notes
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textPrimary)
                        .lineLimit(2)
                }

                // Tags
                if !entry.chartTags.isEmpty {
                    TagFlowLayout(tags: entry.chartTags)
                }
            }
            .padding()
            .background(PluckrTheme.card)
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadowMedium, radius: PluckrTheme.shadowRadiusMedium, x: 0, y: PluckrTheme.shadowYMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 