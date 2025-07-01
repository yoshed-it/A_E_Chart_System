import SwiftUI
import FirebaseFirestore

struct ClientDetailView: View {
    var client: Client
    var onUpdated: () -> Void

    @State private var showEditClient = false
    @State private var chartCount: Int = 0
    @State private var showNewChart = false

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

                Section(header: Text("📋 Charts")) {
                    NavigationLink(destination: ChartsListView(clientId: client.id)) {
                        Label("View All Charts (\(chartCount))", systemImage: "doc.plaintext")
                    }

                    Button {
                        showNewChart = true
                    } label: {
                        Label("Add New Chart", systemImage: "plus")
                            .foregroundColor(.blue)
                    }
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
            .sheet(isPresented: $showNewChart) {
                NewChartEntryView(clientId: client.id) {
                    fetchChartCount()
                }
            }
            .onAppear {
                fetchChartCount()
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
    
    func fetchChartCount() {
        let db = Firestore.firestore()
        db.collection("clients").document(client.id).collection("charts").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                chartCount = snapshot.documents.count
            }
        }
    }

}

