import SwiftUI

struct ChartRowView: View {
    let chart: ChartEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(chart.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .bold()

                Spacer()

                Text(chart.modality)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            Text("Probe: \(chart.probe)")
                .font(.caption)

            Text("RF: \(chart.rfLevel), DC: \(chart.dcLevel)")
                .font(.caption)
                .foregroundColor(.secondary)

            if let area = chart.treatmentArea, !area.isEmpty {
                Text("Area: \(area)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            if !chart.notes.isEmpty {
                Text(chart.notes)
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(.primary)
            }

            if !chart.imageURLs.isEmpty {
                HStack(spacing: 4) {
                    ForEach(chart.imageURLs.prefix(2), id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    if chart.imageURLs.count > 2 {
                        Text("+\(chart.imageURLs.count - 2) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if chart.lastEditedAt != chart.createdAt {
                Label("Edited", systemImage: "pencil")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    }
}
