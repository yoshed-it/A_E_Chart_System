// MARK: - ClientJournalView.swift

import SwiftUI

struct ClientJournalView: View {
    let client: Client
    @State private var showNewEntry = false
    @State private var entries: [ChartEntry] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(client.fullName)
                        .font(.system(size: 34, weight: .bold, design: .serif))

                    if let lastSeen = client.lastSeenAt {
                        Text("Last Seen: \(formattedDate(from: lastSeen))")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding(.top)

                // Tags (Placeholder for future implementation)
                HStack(spacing: 8) {
                    TagView(text: "Coarse Hair")
                    TagView(text: "Dry Skin")
                    TagView(text: "New Client")
                }

                // Chart Entries
                ForEach(entries) { entry in
                    ChartEntryCard(entry: entry)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewEntry = true
                } label: {
                    Text("New Entry")
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(isPresented: $showNewEntry) {
            ChartEntryFormView(
                viewModel: ChartEntryFormViewModel(),
                clientId: client.id ?? "",
                chartId: nil,
                onSave: {
                    Task {
                        entries = await ChartEntryService.loadEntries(for: client.id ?? "")
                    }
                }
            )
        }
        .onAppear {
            Task {
                entries = await ChartEntryService.loadEntries(for: client.id ?? "")
            }
        }
    }

    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
