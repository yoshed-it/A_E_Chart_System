import SwiftUI
import SwiftUIX // For enhanced text field
import UIKit

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsListViewModel()
    @StateObject private var homeViewModel = ProviderHomeViewModel() // For folio actions
    @State private var selectedClient: Client? = nil
    @State private var clientToDelete: Client? = nil
    @State private var showDeleteAlert = false
    // Snackbar/Undo state
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var lastFolioAction: FolioAction? = nil
    @State private var snackbarTimer: Timer? = nil
    private let folioHaptic = UIImpactFeedbackGenerator(style: .light)

    enum FolioAction {
        case added(Client)
        case removed(Client)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: PluckrTheme.verticalPadding) {
                    // Search Field
                    CocoaTextField("Search clients...", text: $viewModel.searchText)
                        .font(PluckrTheme.bodyFont())
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                        .padding(.vertical, 10)
                        .background(PluckrTheme.card)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                        .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                        .padding(.top, PluckrTheme.verticalPadding)

                    if viewModel.isLoading {
                        ProgressView("Loading clients...")
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(viewModel.filteredClients) { client in
                                    HStack {
                                        Button {
                                            selectedClient = client
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(client.fullName)
                                                        .font(PluckrTheme.subheadingFont())
                                                        .foregroundColor(PluckrTheme.textPrimary)
                                                    if let pronouns = client.pronouns, !pronouns.isEmpty {
                                                        Text(pronouns)
                                                            .font(PluckrTheme.captionFont())
                                                            .foregroundColor(PluckrTheme.textSecondary)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                clientToDelete = client
                                                showDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        // Add to Folio button
                                        if homeViewModel.dailyFolioClients.contains(where: { $0.id == client.id }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(PluckrTheme.accent)
                                                .padding(.trailing, 8)
                                                .accessibilityLabel("In Folio")
                                        } else {
                                            Button(action: {
                                               withAnimation {
                                                   homeViewModel.addClientToFolio(client)
                                               }
                                               folioHaptic.impactOccurred()
                                               snackbarMessage = "Added \(client.fullName) to folio"
                                               lastFolioAction = .added(client)
                                               showSnackbarWithTimer()
                                            }) {
                                                Image(systemName: "plus.circle")
                                                    .foregroundColor(PluckrTheme.accent)
                                                    .font(.title2)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                            .padding(.trailing, 8)
                                            .accessibilityLabel("Add to Folio")
                                        }
                                    }
                                    .background(PluckrTheme.card)
                                    .cornerRadius(PluckrTheme.cardCornerRadius)
                                    .shadow(color: PluckrTheme.shadowSmall.opacity(0.5), radius: 4, x: 0, y: 1)
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                            .padding(.bottom, PluckrTheme.verticalPadding / 2)
                        }
                    }
                }
                .background(PluckrTheme.background.ignoresSafeArea())
                // Snackbar overlay
                if showSnackbar {
                    VStack {
                        Spacer()
                        HStack {
                            Text(snackbarMessage)
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(.white)
                            Spacer()
                            Button("Undo") {
                                undoLastFolioAction()
                            }
                            .font(PluckrTheme.captionFont().bold())
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 32)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showSnackbar)
                }
            }
            .navigationTitle("All Clients")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedClient) { client in
                ClientJournalView(client: client, isActive: Binding(
                    get: { selectedClient != nil },
                    set: { newValue in if (!newValue) { selectedClient = nil } }
                ))
            }
            .onAppear {
                viewModel.fetchClients()
                homeViewModel.loadDailyFolio()
            }
            .alert("Delete Client?", isPresented: $showDeleteAlert, presenting: clientToDelete) { client in
                Button("Delete", role: .destructive) {
                    viewModel.deleteClient(client) { success in
                        if success {
                            PluckrLogger.info("Client \(client.fullName) deleted successfully")
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { client in
                Text("Are you sure you want to delete \(client.fullName)? This cannot be undone.")
            }
        }
    }

    // MARK: - Snackbar/Undo helpers
    private func showSnackbarWithTimer() {
        snackbarTimer?.invalidate()
        showSnackbar = true
        snackbarTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation { showSnackbar = false }
        }
    }

    private func undoLastFolioAction() {
        guard let action = lastFolioAction else { return }
        switch action {
        case .added(let client):
            withAnimation { homeViewModel.removeClientFromFolio(client) }
            snackbarMessage = "Undid add: \(client.fullName)"
        case .removed(let client):
            withAnimation { homeViewModel.addClientToFolio(client) }
            snackbarMessage = "Undid remove: \(client.fullName)"
        }
        lastFolioAction = nil
        showSnackbarWithTimer()
    }
}
