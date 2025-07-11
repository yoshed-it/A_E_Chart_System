import SwiftUI

struct ClientDetailView: View {
    @Environment(\.dismiss) var dismiss

    private let onUpdated: () -> Void

    @StateObject private var viewModel: ClientDetailViewModel

    init(client: Client, onUpdated: @escaping () -> Void) {
        self.onUpdated = onUpdated
        _viewModel = StateObject(wrappedValue: ClientDetailViewModel(client: client))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Client Info")) {
                    TextField("First Name", text: viewModel.firstNameBinding)
                    TextField("Last Name", text: viewModel.lastNameBinding)
                    TextField("Pronouns", text: viewModel.pronounsBinding)
                    TextField("Phone", text: viewModel.phoneBinding)
                    TextField("Email", text: viewModel.emailBinding)
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }

                Button {
                    viewModel.saveChanges {
                        dismiss()
                        onUpdated()
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.deleteClient {
                            dismiss()
                            onUpdated()
                        }
                    } label: {
                        Label("Archive Client", systemImage: "archivebox")
                    }
                }
            }
            .navigationTitle("Edit Client")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
