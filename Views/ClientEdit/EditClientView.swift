import SwiftUI

struct EditClientView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.appEnvironment) private var env
    @StateObject private var viewModel: EditClientViewModel
    let onSave: (Client) -> Void

    @State private var showingTagPicker = false
    @State private var showDeleteAlert = false

    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]

    init(client: Client, onSave: @escaping (Client) -> Void) {
        let vm = EditClientViewModel(
            client: client,
            repository: AppEnvironment.live.clientRepository,
            tagService: AppEnvironment.live.tagService
        )
        _viewModel = StateObject(wrappedValue: vm)
        self.onSave = onSave
    }

    // MARK: - Computed Properties for Sections
    private var clientInfoSection: some View {
        Section(header: Text("Edit Client")) {
            firstNameField
            lastNameField
            emailField
            pronounsPicker
            phoneField
        }
    }
    
    private var firstNameField: some View {
        TextField("First Name", text: $viewModel.firstName)
    }
    
    private var lastNameField: some View {
        TextField("Last Name", text: $viewModel.lastName)
    }
    
    private var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .keyboardType(.emailAddress)
    }
    
    private var pronounsPicker: some View {
        Picker("Pronouns", selection: $viewModel.pronouns) {
            ForEach(pronounOptions, id: \.self) { option in
                Text(option).tag(option)
            }
        }
    }
    
    private var phoneField: some View {
        TextField("Phone Number", text: $viewModel.phone)
            .keyboardType(.phonePad)
            .phoneNumberFormatting(text: $viewModel.phone)
    }

    /// Error message section displayed below the form
    private var errorMessageView: some View {
        Group {
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Computed Properties
    private var isSaveDisabled: Bool {
        viewModel.isSaving || viewModel.firstName.isEmpty || viewModel.lastName.isEmpty || viewModel.pronouns.isEmpty
    }
    
    private var saveButtonContent: some View {
        Group {
            if viewModel.isSaving {
                ProgressView()
            } else {
                Text("Save")
            }
        }
    }
    
    private var saveButton: some View {
        Button {
            viewModel.saveChanges()
        } label: {
            saveButtonContent
        }
        .disabled(isSaveDisabled)
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    // MARK: - Computed Properties for Alert
    private var deleteClientAlertButtons: some View {
        Group {
            Button("Delete", role: .destructive) {
                viewModel.deleteClient {
                    dismiss()
                    // Optionally notify parent view here
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Methods
    private func handleSaveStateChange(_ isSaving: Bool) {
        if !isSaving && viewModel.errorMessage.isEmpty {
            // Save successful, fetch updated client from backend
            let repo = AppEnvironment.live.clientRepository
            repo.fetchClient(by: viewModel.clientId) { updatedClient in
                if let updatedClient = updatedClient {
                    onSave(updatedClient)
                }
                dismiss()
            }
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    Form {
                        clientInfoSection
                    }
                    errorMessageView
                }
            }
            .navigationTitle("Edit Client")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                }
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                // Optionally handle error changes (e.g., show alert)
            }
            .onChange(of: viewModel.isSaving) { _, newValue in
                handleSaveStateChange(newValue)
            }
            DestructiveAlertView(
                title: "Delete Client?",
                message: "Are you sure you want to delete this client? This action cannot be undone.",
                isPresented: $showDeleteAlert,
                destructiveAction: {
                    viewModel.deleteClient {
                        dismiss()
                        // Optionally notify parent view here
                    }
                },
                destructiveLabel: "Delete",
                cancelLabel: "Cancel"
            )
        }
    }
}
