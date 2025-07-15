import SwiftUI

struct ChartsListView: View {
    @StateObject private var viewModel = ChartsListViewModel()
    let clientId: String

    @State private var selectedChart: ChartEntry? = nil
    @State private var editingChart: ChartEntry? = nil
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading charts...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
            } else {
                List(viewModel.charts) { chart in
                    NavigationLink(destination: ChartDetailView(chart: chart, onEdit: {
                        editingChart = chart
                        showEditSheet = true
                    })) {
                        ChartRowView(chart: chart)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            editingChart = chart
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }.tint(.blue)
                        Button(role: .destructive) {
                            selectedChart = chart
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchCharts(for: clientId)
        }
        .navigationTitle("Charts")
        .sheet(isPresented: $showEditSheet) {
            if let chart = editingChart {
                ChartEntryFormView(
                    viewModel: ChartEntryFormViewModel(),
                    clientId: clientId,
                    chartId: chart.id,
                    onSave: {
                        viewModel.fetchCharts(for: clientId)
                        showEditSheet = false
                    }
                )
            }
        }
        .alert("Delete Chart?", isPresented: $showDeleteAlert, presenting: selectedChart) { chart in
            Button("Delete", role: .destructive) {
                viewModel.deleteChart(for: clientId, chartId: chart.id) { _ in }
            }
            Button("Cancel", role: .cancel) {}
        } message: { chart in
            Text("Are you sure you want to delete this chart? This action cannot be undone.")
        }
    }
}
