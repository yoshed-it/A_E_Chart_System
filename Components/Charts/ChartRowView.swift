import SwiftUI

struct ChartRowView: View {
    let chart: ChartEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(chart.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(PluckrTheme.bodyFont(size: 15))
                    .foregroundColor(PluckrTheme.textPrimary)
                Spacer()
                Text(chart.modality)
                    .font(PluckrTheme.bodyFont(size: 15))
                    .foregroundColor(PluckrTheme.accent)
            }
            Text("Probe: \(chart.probe)")
                .font(PluckrTheme.captionFont())
                .foregroundColor(PluckrTheme.textPrimary)
            Text("RF: \(chart.rfLevel), DC: \(chart.dcLevel)")
                .font(PluckrTheme.captionFont())
                .foregroundColor(PluckrTheme.textSecondary)
            if let area = chart.treatmentArea, !area.isEmpty {
                Text("Area: \(area)")
                    .font(PluckrTheme.captionFont(size: 12))
                    .foregroundColor(PluckrTheme.textSecondary)
            }
            if !chart.notes.isEmpty {
                Text(chart.notes)
                    .lineLimit(1)
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textPrimary)
            }
            if !chart.imageURLs.isEmpty {
                HStack(spacing: 4) {
                    ForEach(chart.imageURLs.prefix(2), id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().aspectRatio(contentMode: .fill).pluckrImage()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                    }
                    if chart.imageURLs.count > 2 {
                        Text("+\(chart.imageURLs.count - 2) more")
                            .font(PluckrTheme.captionFont(size: 12))
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                }
            }
            if chart.lastEditedAt != chart.createdAt {
                Label("Edited", systemImage: "pencil")
                    .font(PluckrTheme.captionFont(size: 12))
                    .foregroundColor(.orange)
            }
        }
        .padding(PluckrTheme.verticalPadding)
        .pluckrCard()
    }
}
