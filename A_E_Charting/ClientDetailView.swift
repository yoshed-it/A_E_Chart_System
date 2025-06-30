import SwiftUI

struct ClientDetailView: View {
    var client: Client
    var onUpdated: () -> Void

    @State private var showEditClient = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Client Info")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(client.name)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Pronouns")
                        Spacer()
                        Text(client.pronouns)
                            .foregroundColor(.secondary)
                    }

                    if let created = client.createdAt {
                        HStack {
                            Text("Created")
                            Spacer()
                            Text(created.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.secondary)
                        }
                    }

                    if let lastSeen = client.lastSeenAt {
                        HStack {
                            Text("Last Seen")
                            Spacer()
                            Text(lastSeen.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text("Added By")
                        Spacer()
                        Text(client.createdByName)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Client Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Edit") {
                    showEditClient = true
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
}
