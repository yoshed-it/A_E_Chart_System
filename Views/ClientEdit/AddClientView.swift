import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddClientViewModel()
    @State private var showingTagPicker = false

    var onClientAdded: () -> Void
    var providerDisplayName: String

    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PluckrTheme.verticalPadding) {
                        // Header
                        VStack(spacing: PluckrTheme.verticalPadding / 2) {
                            Text("Add New Client")
                                .font(PluckrTheme.displayFont(size: 32))
                                .foregroundColor(PluckrTheme.textPrimary)
                            Text("Create a new client record")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                        }
                        .padding(.top, PluckrTheme.verticalPadding)
                        
                        // Form
                        VStack(spacing: PluckrTheme.verticalPadding) {
                            // Client Info Section
                            VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding / 2) {
                                Text("Client Information")
                                    .font(PluckrTheme.subheadingFont())
                                    .foregroundColor(PluckrTheme.textPrimary)
                                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                                
                                VStack(spacing: PluckrTheme.verticalPadding / 2) {
                                    TextField("First Name", text: $viewModel.firstName)
                                        .pluckrTextField()
                                    
                                    TextField("Last Name", text: $viewModel.lastName)
                                        .pluckrTextField()
                                    
                                    // Pronouns Picker
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Pronouns")
                                            .font(PluckrTheme.captionFont())
                                            .foregroundColor(PluckrTheme.textSecondary)
                                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                                        
                                        Picker("Pronouns", selection: $viewModel.pronouns) {
                                            Text("Select pronouns").tag("")
                                            ForEach(pronounOptions, id: \.self) { option in
                                                Text(option).tag(option)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                                        .background(PluckrTheme.card)
                                        .cornerRadius(PluckrTheme.cardCornerRadius)
                                        .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                                    }
                                    
                                    TextField("Email Address", text: $viewModel.email)
                                        .pluckrTextField()
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                    
                                    TextField("Phone Number", text: $viewModel.phone)
                                        .pluckrTextField()
                                        .keyboardType(.phonePad)
                                        .phoneNumberFormatting(text: $viewModel.phone)
                                }
                                .padding(.horizontal, PluckrTheme.horizontalPadding)
                            }
                            
                            // Tag Picker Section
                            VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding / 2) {
                                Text("Client Tags")
                                    .font(PluckrTheme.subheadingFont(size: 18))
                                    .foregroundColor(PluckrTheme.textPrimary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(viewModel.clientTags, id: \.self) { tag in
                                            TagView(tag: tag, size: .normal)
                                        }
                                    }
                                }
                                Button(action: { showingTagPicker = true }) {
                                    Label("Edit Tags", systemImage: "tag")
                                        .font(PluckrTheme.bodyFont())
                                        .foregroundColor(PluckrTheme.accent)
                                }
                            }
                            .padding(.vertical, PluckrTheme.verticalPadding / 2)
                            .sheet(isPresented: $showingTagPicker) {
                                TagPickerModal(
                                    selectedTags: $viewModel.clientTags,
                                    availableTags: [], // TagPickerModal loads its own tags
                                    context: .client
                                )
                            }
                            
                            // Error Message
                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 8)
                                    .padding(.horizontal)
                            }
                            
                            // Save Button
                            Button(action: {
                                viewModel.onClientAdded = {
                                    dismiss()
                                    onClientAdded()
                                }
                                viewModel.saveClient()
                            }) {
                                if viewModel.isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Save Client")
                                        .font(PluckrTheme.subheadingFont())
                                        .fontWeight(.semibold)
                                }
                            }
                            .pluckrButton()
                            .disabled(viewModel.isSaving)
                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("Add New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }
}
