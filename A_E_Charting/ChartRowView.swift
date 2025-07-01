import SwiftUI

struct ChartRowView: View {
    let chart: ChartEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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

            if !chart.treatmentArea.isEmpty {
                Text("Area: \(chart.treatmentArea)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if chart.lastEditedAt != chart.createdAt {
                Label("Edited", systemImage: "pencil")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        .animation(.easeInOut(duration: 0.3), value: chart.id)
    }
}
