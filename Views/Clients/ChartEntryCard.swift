import SwiftUI

struct ChartEntryCard: View {
    let entry: ChartEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("RF")
                    Spacer()
                    Text("\(entry.rfLevel)")
                    Text("|")
                    Text("\(entry.dcLevel)")
                }
                
                HStack {
                    Text("Probe")
                    Spacer()
                    Text(entry.probe)
                }
                
                if let area = entry.treatmentArea {
                    Text("Treatment Area: \(area)")
                }
                
                if let condition = entry.skinCondition {
                    Text("Skin Condition: \(condition)")
                }
                
                if !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Notes: \(entry.notes)")
                }
            }
            .font(.subheadline)

            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
