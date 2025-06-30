import SwiftUI
import FirebaseFirestore

struct Chart: Identifiable {
    var id: String
    var date: Date
    var rfType: String
    var probeType: String
    var treatmentArea: String
    var notes: String
    var imageUrls: [String] // Will store Firebase Storage URLs
}

struct ChartsListView: View {
    var clientId: String

    @State private var charts: [Chart] = []
    @State private var isLoading = true
    @State private var showAddChart = false

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading Charts...")
            } else if charts.isEmpty {
                Text("No charts yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(charts) { chart in
                    VStack(alignment: .leading) {
                        Text(chart.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)
                        Text(chart.treatmentArea)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(chart.notes)
                            .font(.body)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Charts")
        .toolbar {
            Button(action: {
                showAddChart = true
            }) {
                Image(systemName: "plus")
            }
        }
        .onAppear(perform: loadCharts)
        .sheet(isPresented: $showAddChart) {
            // Placeholder for now
            Text("New Chart View Here")
        }
    }

    func loadCharts() {
        let db = Firestore.firestore()
        db.collection("clients").document(clientId).collection("charts")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.charts = docs.map { doc in
                        let data = doc.data()
                        return Chart(
                            id: doc.documentID,
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            rfType: data["rfType"] as? String ?? "",
                            probeType: data["probeType"] as? String ?? "",
                            treatmentArea: data["treatmentArea"] as? String ?? "",
                            notes: data["notes"] as? String ?? "",
                            imageUrls: data["imageUrls"] as? [String] ?? []
                        )
                    }
                }
                isLoading = false
            }
    }
}
