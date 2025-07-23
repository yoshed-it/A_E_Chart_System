import SwiftUI
import SwipeActions

struct ClientJournalMainContentBody: View {
    let client: Client
    @Binding var clientTags: [Tag]
    @Binding var availableClientTags: [Tag]
    @ObservedObject var viewModel: ClientJournalViewModel
    @Binding var selectedChartId: String?
    @Binding var activeSheet: ActiveSheet?
    @Binding var editingChart: ChartEntry?
    @Binding var showEditSheet: Bool
    @Binding var deletingChart: ChartEntry?
    @Binding var showDeleteAlert: Bool
    @Binding var showNewEntry: Bool
    @Binding var showDeleteClientAlert: Bool
    @Binding var showingClientTagPicker: Bool
    @Binding var showingConsentForm: Bool
    var editFormViewModel: ChartEntryFormViewModel
    @Binding var isActive: Bool
    @Binding var selectedChart: ChartEntry?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ClientJournalHeaderSection(client: client)
                ClientJournalTagsSection(
                    clientTags: clientTags,
                    onShowTagPicker: { showingClientTagPicker = true }
                )
                .padding(.bottom, 16)
                if viewModel.isLoading {
                    LoadingView(message: "Loading chart entries...")
                        .padding(.top, 32)
                } else if viewModel.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text("No chart entries yet.")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                        Text("Tap 'Add Chart' to create a new entry for this client.")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.entries) { entry in
                            chartEntryRow(for: entry)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.bottom, 32)
        }
        .background(PluckrTheme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedChart) { (chart: ChartEntry) in
            ChartDetailView(chart: chart, onEdit: {
                editingChart = chart
                showEditSheet = true
            })
        }
    }

    @ViewBuilder
    private func chartEntryRow(for entry: ChartEntry) -> some View {
        SwipeView {
            ChartEntryCard(entry: entry, onTap: { selectedChart = entry })
        } trailingActions: { _ in
            SwipeAction("Edit", systemImage: "pencil", backgroundColor: .accentColor) {
                editingChart = entry
                showEditSheet = true
            }
            SwipeAction("Delete", systemImage: "trash", backgroundColor: .red) {
                deletingChart = entry
                showDeleteAlert = true
            }
        }
    }
} 