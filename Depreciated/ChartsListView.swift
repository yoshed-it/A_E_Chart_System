// DEPRECATED: This file is no longer used in the current app flow as of [date].
// Retained for reference only. Safe to delete after migration is complete.


//import SwiftUI
//
//struct ChartsListView: View {
//    @StateObject private var viewModel = ChartsListViewModel()
//    let clientId: String
//
//    @State private var selectedChart: ChartEntry? = nil
//    @State private var editingChart: ChartEntry? = nil
//    @State private var showEditSheet = false
//    @State private var showDeleteAlert = false
//    @State private var selectedTags: [Tag] = []
//
//    var body: some View {
//        VStack {
//            if viewModel.isLoading {
//                ProgressView("Loading charts...")
//            } else if let error = viewModel.errorMessage {
//                Text("Error: \(error)")
//            } else {
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(viewModel.charts) { chart in
//                            SwipeableRow(
//                                leadingActions: [
//                                    SwipeAction(label: "Edit", systemImage: "pencil", tint: .accentColor, role: nil, action: {
//                                        editingChart = chart
//                                        showEditSheet = true
//                                    })
//                                ],
//                                trailingActions: [
//                                    SwipeAction(label: "Delete", systemImage: "trash", tint: .red, role: .destructive, action: {
//                                        selectedChart = chart
//                                        showDeleteAlert = true
//                                    })
//                                ]
//                            ) {
//                                ChartEntryCard(entry: chart)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, PluckrTheme.horizontalPadding)
//                    .padding(.vertical, PluckrTheme.verticalPadding)
//                }
//            }
//        }
//        .background(PluckrTheme.backgroundGradient.ignoresSafeArea())
//        .navigationTitle("Charts")
//        .sheet(isPresented: $showEditSheet) {
//            if let chart = editingChart {
//                ChartEntryFormView(
//                    clientId: clientId,
//                    chartId: chart.id,
//                    onSave: {
//                        viewModel.fetchCharts(for: clientId)
//                        showEditSheet = false
//                    }
//                )
//            }
//        }
//        .alert("Delete Chart?", isPresented: $showDeleteAlert, presenting: selectedChart) { chart in
//            Button("Delete", role: .destructive) {
//                handleDelete(chart: chart)
//            }
//            Button("Cancel", role: .cancel) {}
//        } message: { chart in
//            Text("Are you sure you want to delete this chart? This action cannot be undone.")
//        }
//        .sheet(item: $viewModel.activeTagPickerChart) { chart in
//            TagPickerModal(
//                selectedTags: $selectedTags,
//                availableTags: viewModel.availableTags,
//                context: .chart
//            )
//            .onAppear {
//                selectedTags = chart.chartTags
//            }
//            .onDisappear {
//                if let chart = viewModel.activeTagPickerChart {
//                    viewModel.persistTags(selectedTags, for: chart, clientId: clientId)
//                }
//            }
//            .presentationDetents([.medium, .large])
//            .background(
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(PluckrTheme.card)
//                    .shadow(color: PluckrTheme.shadow, radius: 16, x: 0, y: 4)
//            )
//        }
//    }
//
//    private func handleDelete(chart: ChartEntry) {
//        viewModel.deleteChart(for: clientId, chartId: chart.id) { success in
//            // TODO: Show toast on success/failure if desired
//        }
//    }
//}
