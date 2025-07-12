import SwiftUI

struct ChartEntryCard: View {
    let entry: ChartEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date
            Text(entry.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)

            // Main details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("RF:")
                    Text(entry.rfLevel.formatted(.number.precision(.fractionLength(1)))) + Text(" MHz")
                    
                    Spacer()
                    
                    Text("DC:")
                    Text(entry.dcLevel.formatted(.number.precision(.fractionLength(1)))) + Text(" mA")
                }

                HStack {
                    Text("Probe:")
                    Spacer()
                    Text(entry.probe)
                }

                if let area = entry.treatmentArea {
                    HStack {
                        Text("Treatment Area:")
                        Spacer()
                        Text(area)
                    }
                }

                if let condition = entry.skinCondition {
                    HStack {
                        Text("Skin Condition:")
                        Spacer()
                        Text(condition)
                    }
                }

                if !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes:")
                            .fontWeight(.semibold)
                        Text(entry.notes)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .font(.subheadline)

            // Image
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
