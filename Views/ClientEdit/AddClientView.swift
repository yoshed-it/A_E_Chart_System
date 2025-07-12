import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddClientViewModel()

    var onClientAdded: () -> Void
    var providerDisplayName: String

    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Client Info")) {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)

                    Picker("Pronouns", selection: $viewModel.pronouns) {
                        Text("Select").tag("").disabled(true)
                        ForEach(pronounOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }

                    TextField("Phone Number", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: {
                    viewModel.onClientAdded = {
                        dismiss()
                        onClientAdded()
                    }
                    viewModel.saveClient()
                }) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save Client")
                    }
                }
                .disabled(viewModel.isSaving)
            }
            .navigationTitle("Add New Client")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
