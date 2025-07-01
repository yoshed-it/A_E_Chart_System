import SwiftUI
import FirebaseFirestore

struct ChartsListView: View {
    let clientId: String

    @State private var charts: [ChartEntry] = []
    @State private var isLoading = true
    @State private var selectedChart: ChartEntry? = nil
    @State private var editingChart: ChartEntry? = nil
    @State private var showForm = false
    @State private var showDetail = false
    @State private var chartToDelete: ChartEntry? = nil
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading Charts...")
            } else if charts.isEmpty {
                Text("No chart entries yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(charts) { chart in
                    ChartRowView(chart: chart)
                        .onTapGesture {
                            selectedChart = chart
                            showDetail = true
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                chartToDelete = chart
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("📋 Chart History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingChart = nil
                    showForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear(perform: fetchCharts)
        .sheet(isPresented: $showForm) {
            ChartEntryFormView(
                existingChart: editingChart,
                onSave: {
                    showForm = false
                    fetchCharts()
                },
                clientId: clientId
            )
        }
        .sheet(isPresented: $showDetail) {
            if let selectedChart = selectedChart {
                NavigationStack {
                    ChartDetailView(
                        chart: selectedChart,
                        onEdit: {
                            editingChart = selectedChart
                            showDetail = false
                            showForm = true
                        }
                    )
                }
            }
        }
        .alert("Delete Chart?", isPresented: $showDeleteConfirmation, presenting: chartToDelete) { chart in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteChart(chart)
            }
        } message: { _ in
            Text("Are you sure you want to delete this chart entry? This cannot be undone.")
        }
    }

    func fetchCharts() {
        let db = Firestore.firestore()
        db.collection("clients").document(clientId).collection("charts")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                if let error = error {
                    print("❌ Error fetching charts: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.charts = documents.compactMap { doc in
                    ChartEntry(id: doc.documentID, data: doc.data())
                }
            }
    }

    func deleteChart(_ chart: ChartEntry) {
        guard let chartId = chart.id else {
            print("❌ Chart ID missing, cannot delete.")
            return
        }
        let db = Firestore.firestore()
        db.collection("clients").document(clientId).collection("charts").document(chartId).delete { error in
            if let error = error {
                print("❌ Failed to delete chart: \(error.localizedDescription)")
            } else {
                fetchCharts()
            }
        }
    }
}
