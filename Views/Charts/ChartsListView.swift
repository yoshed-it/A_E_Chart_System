import SwiftUI

struct ChartsListView: View {
    @StateObject private var viewModel = ChartsListViewModel()
    let clientId: String

    @State private var selectedChart: ChartEntry? = nil
    @State private var editingChart: ChartEntry? = nil
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var selectedTags: [Tag] = []

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
                        chartRowContent(for: chart)
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
        .background(PluckrTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Charts")
        .sheet(isPresented: $showEditSheet) {
            if let chart = editingChart {
                ChartEntryFormView(
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
                handleDelete(chart: chart)
            }
            Button("Cancel", role: .cancel) {}
        } message: { chart in
            Text("Are you sure you want to delete this chart? This action cannot be undone.")
        }
        .sheet(item: $viewModel.activeTagPickerChart) { chart in
            TagPickerModal(
                selectedTags: $selectedTags,
                availableTags: viewModel.availableTags,
                context: .chart
            )
            .onAppear {
                selectedTags = chart.chartTags
            }
            .onDisappear {
                if let chart = viewModel.activeTagPickerChart {
                    viewModel.persistTags(selectedTags, for: chart, clientId: clientId)
                }
            }
            .presentationDetents([.medium, .large])
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(PluckrTheme.card)
                    .shadow(color: PluckrTheme.shadow, radius: 16, x: 0, y: 4)
            )
        }
    }
    
    @ViewBuilder
    private func chartRowContent(for chart: ChartEntry) -> some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(chart.chartTags, id: \ .self) { tag in
                        TagView(tag: tag, size: .normal)
                    }
                }
            }
            Spacer()
            Button(action: { viewModel.showTagPicker(for: chart) }) {
                Image(systemName: "tag")
                    .padding(8)
                    .background(PluckrTheme.card)
                    .clipShape(Circle())
                    .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
            }
        }
    }

    private func handleDelete(chart: ChartEntry) {
        viewModel.deleteChart(for: clientId, chartId: chart.id) { success in
            // TODO: Show toast on success/failure if desired
        }
    }
}
