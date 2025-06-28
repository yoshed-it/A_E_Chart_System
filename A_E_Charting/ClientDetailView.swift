import SwiftUI
import FirebaseFirestore

struct ClientDetailView: View {
    let client: Client

    var body: some View {
        Form {
            Section(header: Text("Client Info")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(client.name).foregroundColor(.secondary)
                }
                HStack {
                    Text("Pronouns")
                    Spacer()
                    Text(client.pronouns).foregroundColor(.secondary)
                }
                HStack {
                    Text("Created By")
                    Spacer()
                    Text(client.createdByName).foregroundColor(.secondary)
                }
                HStack {
                    Text("Created At")
                    Spacer()
                    Text(client.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "–")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Last Seen")
                    Spacer()
                    Text(client.lastSeenAt?.formatted(date: .abbreviated, time: .shortened) ?? "–")
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Actions")) {
                NavigationLink(destination: Text("📝 Chart History Coming Soon")) {
                    Label("View Chart History", systemImage: "doc.plaintext")
                }
                NavigationLink(destination: Text("📷 Images Coming Soon")) {
                    Label("View Images", systemImage: "photo")
                }
                NavigationLink(destination: Text("✏️ Edit Client Coming Soon")) {
                    Label("Edit Client Info", systemImage: "pencil")
                }
            }
        }
        .navigationTitle(client.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct ClientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientDetailView(client: Client(
                id: "123",
                name: "Jordan Smith",
                pronouns: "They/Them",
                createdAt: Date(),
                createdByName: "provider@example.com",
                lastSeenAt: Date()
            ))
        }
    }
}
