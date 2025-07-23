import SwiftUI

// MARK: - ActiveSheet Enum
/// Used for managing sheet presentation in ClientJournalView and subcomponents.
enum ActiveSheet: Identifiable {
    case newEntry
    case editEntry(ChartEntry)
    case tagPicker
    case viewChart

    var id: Int {
        switch self {
        case .newEntry: return 0
        case .editEntry: return 1
        case .tagPicker: return 2
        case .viewChart: return 3
        }
    }
}

// MARK: - View Extensions for Modifiers
extension View {
    func applyJournalSheets(
        showNewEntry: Binding<Bool>,
        showEditSheet: Binding<Bool>,
        editingChart: Binding<ChartEntry?>,
        editFormViewModel: ChartEntryFormViewModel,
        client: Client,
        viewModel: ClientJournalViewModel,
        clientTags: Binding<[Tag]>,
        availableClientTags: [Tag],
        showingClientTagPicker: Binding<Bool>,
        showingConsentForm: Binding<Bool>
    ) -> some View {
        self
            .sheet(isPresented: showNewEntry) {
                ChartEntryFormView(
                    clientId: client.id,
                    chartId: nil,
                    onSave: {
                        Task {
                            await viewModel.loadEntries()
                        }
                    }
                )
            }
            .sheet(item: editingChart) { chart in
                ChartEntryFormView(
                    clientId: client.id,
                    chartId: chart.id,
                    onSave: {
                        Task {
                            await viewModel.loadEntries()
                        }
                    }
                )
            }
            .sheet(isPresented: showingClientTagPicker) {
                TagPickerModal(
                    selectedTags: clientTags,
                    availableTags: availableClientTags,
                    context: .client,
                    onDone: { newTags in
                        clientTags.wrappedValue = newTags
                    }
                )
            }
            .sheet(isPresented: showingConsentForm) {
                ImageConsentFormView(client: client) { updatedClient in
                    // TODO: Update client in Firestore and local state
                }
            }
    }

    func applyJournalAlerts(
        showDeleteAlert: Binding<Bool>,
        deletingChart: Binding<ChartEntry?>,
        viewModel: ClientJournalViewModel,
        showDeleteClientAlert: Binding<Bool>,
        client: Client
    ) -> some View {
        self
            .alert("Delete Chart?", isPresented: showDeleteAlert, presenting: deletingChart.wrappedValue) { chart in
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteEntry(chartId: chart.id)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { chart in
                Text("Are you sure you want to delete this chart? This action cannot be undone.")
            }
            .alert("Delete Client?", isPresented: showDeleteClientAlert) {
                Button("Delete", role: .destructive) {
                    // Implement deleteClient logic here if needed
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \(client.fullName)? This will permanently delete the client and all their chart entries. This action cannot be undone.")
            }
    }
}

// MARK: - Toolbar Extension
extension View {
    func applyJournalToolbar(showNewEntry: Binding<Bool>, showingConsentForm: Binding<Bool>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Image Consent Form") {
                        showingConsentForm.wrappedValue = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewEntry.wrappedValue = true
                } label: {
                    Text("Add Chart")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }
} 