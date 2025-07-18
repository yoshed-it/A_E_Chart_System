import SwiftUI

struct AllClientsFolioPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var selectedClientIds: Set<String> = []
    @StateObject private var homeViewModel = ProviderHomeViewModel() // For folio status
    let onClientsScribed: ([Client]) -> Void
    
    var body: some View {
        ZStack {
            PluckrTheme.backgroundGradient
                .ignoresSafeArea()
            NavigationStack {
                VStack(spacing: 0) {
                    // Search Bar
                    TextField("Search clients...", text: $viewModel.searchText)
                        .pluckrTextField()
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    
                    // Client List
                    List(viewModel.filteredClients) { client in
                        let inFolio = homeViewModel.dailyFolioClients.contains(where: { $0.id == client.id })
                        MultipleSelectionRow(
                            client: client,
                            isSelected: selectedClientIds.contains(client.id),
                            isDisabled: inFolio,
                            inFolio: inFolio
                            
                        ) {
                            if !inFolio {
                                if selectedClientIds.contains(client.id) {
                                    selectedClientIds.remove(client.id)
                                } else {
                                    selectedClientIds.insert(client.id)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                    // Scribe Button
                    VStack(spacing: 8) {
                        if !selectedClientIds.isEmpty {
                            Text("\(selectedClientIds.count) selected")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(.secondary)
                        }
                        Button(action: {
                            let selectedClients = viewModel.filteredClients.filter { selectedClientIds.contains($0.id) }
                            onClientsScribed(selectedClients)
                            dismiss()
                        }) {
                            Text("Scribe to Folio")
                                .font(PluckrTheme.subheadingFont())
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedClientIds.isEmpty ? Color.gray.opacity(0.3) : PluckrTheme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(PluckrTheme.buttonCornerRadius)
                        }
                        .disabled(selectedClientIds.isEmpty)
                        .padding([.horizontal, .bottom])
                    }
                }
                .navigationTitle("Add to Daily Folio")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.fetchClients()
                    homeViewModel.loadDailyFolio()
                }
            }
        }
    }
}
