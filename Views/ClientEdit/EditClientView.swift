import SwiftUI

struct EditClientView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.appEnvironment) private var env
    @StateObject private var viewModel: EditClientViewModel
    let onSave: () -> Void

    @State private var showingTagPicker = false

    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]

    init(client: Client, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditClientViewModel(
            client: client,
            repository: AppEnvironment.live.clientRepository,
            tagService: AppEnvironment.live.tagService
        ))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                Form {
                    Section(header: Text("Edit Client")) {
                        TextField("First Name", text: $viewModel.firstName)
                        TextField("Last Name", text: $viewModel.lastName)
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                        Picker("Pronouns", selection: $viewModel.pronouns) {
                            ForEach(pronounOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        TextField("Phone Number", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                            .phoneNumberFormatting(text: $viewModel.phone)
                    }

                    // Tag Picker Section
                    Section(header: Text("Client Tags")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.clientTags, id: \ .self) { tag in
                                    TagView(tag: tag, size: .normal)
                                }
                            }
                        }
                        Button(action: { showingTagPicker = true }) {
                            Label("Edit Tags", systemImage: "tag")
                                .font(.body)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .sheet(isPresented: $showingTagPicker) {
                        TagPickerModal(
                            selectedTags: $viewModel.clientTags,
                            availableTags: [], // TagPickerModal loads its own tags
                            context: .client
                        )
                    }

                    if !viewModel.errorMessage.isEmpty {
                        Section {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Edit Client")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.saveChanges()
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(viewModel.isSaving || viewModel.firstName.isEmpty || viewModel.lastName.isEmpty || viewModel.pronouns.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                // Optionally handle error changes (e.g., show alert)
            }
            .onChange(of: viewModel.isSaving) { _, newValue in
                if !newValue && viewModel.errorMessage.isEmpty {
                    // Save successful, dismiss and call onSave
                    onSave()
                    dismiss()
                }
            }
        }
    }
}
