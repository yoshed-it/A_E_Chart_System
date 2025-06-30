import SwiftUI

struct ClientDetailView: View {
    var client: Client
    var onUpdated: () -> Void

    @State private var showEditClient = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Client Info")) {
                    LabeledRow(label: "Name", value: client.name)
                    LabeledRow(label: "Pronouns", value: client.pronouns)

                    if let created = client.createdAt {
                        LabeledRow(label: "Created", value: created.formatted(date: .abbreviated, time: .shortened))
                    }

                    if let lastSeen = client.lastSeenAt {
                        LabeledRow(label: "Last Seen", value: lastSeen.formatted(date: .abbreviated, time: .shortened))
                    }

                    LabeledRow(label: "Added By", value: client.createdByName)
                }
            }
            .navigationTitle("Client Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showEditClient = true
                    }
                }
            }
            .sheet(isPresented: $showEditClient) {
                EditClientView(client: client) {
                    onUpdated()
                    showEditClient = false
                }
            }
        }
    }

    @ViewBuilder
    func LabeledRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
