import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddClientViewModel()

    var onClientAdded: () -> Void
    var providerDisplayName: String

    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                PluckrTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PluckrTheme.spacing * 2) {
                        // Header
                        VStack(spacing: PluckrTheme.spacing) {
                            Text("Add New Client")
                                .font(.journalTitle)
                                .foregroundColor(PluckrTheme.primaryColor)
                            
                            Text("Create a new client record")
                                .font(.journalCaption)
                                .foregroundColor(PluckrTheme.secondaryColor)
                        }
                        .padding(.top, PluckrTheme.padding)
                        
                        // Form
                        VStack(spacing: PluckrTheme.spacing * 2) {
                            // Client Info Section
                            VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                                Text("Client Information")
                                    .font(.journalSubtitle)
                                    .foregroundColor(PluckrTheme.primaryColor)
                                    .padding(.horizontal, PluckrTheme.padding)
                                
                                VStack(spacing: PluckrTheme.spacing) {
                                    TextField("First Name", text: $viewModel.firstName)
                                        .textFieldStyle(PluckrTextFieldStyle())
                                    
                                    TextField("Last Name", text: $viewModel.lastName)
                                        .textFieldStyle(PluckrTextFieldStyle())
                                    
                                    // Pronouns Picker
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Pronouns")
                                            .font(.journalCaption)
                                            .foregroundColor(PluckrTheme.secondaryColor)
                                            .padding(.horizontal, PluckrTheme.padding)
                                        
                                        Picker("Pronouns", selection: $viewModel.pronouns) {
                                            Text("Select pronouns").tag("")
                                            ForEach(pronounOptions, id: \.self) { option in
                                                Text(option).tag(option)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(PluckrTheme.cornerRadius)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                    
                                    TextField("Email Address", text: $viewModel.email)
                                        .textFieldStyle(PluckrTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                    
                                    TextField("Phone Number", text: $viewModel.phone)
                                        .textFieldStyle(PluckrTextFieldStyle())
                                        .keyboardType(.phonePad)
                                        .phoneNumberFormatting(text: $viewModel.phone)
                                }
                                .padding(.horizontal, PluckrTheme.padding)
                            }
                            
                            // Error Message
                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .font(.journalCaption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, PluckrTheme.padding)
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
                                        .font(.journalSubtitle)
                                        .fontWeight(.semibold)
                                }
                            }
                            .buttonStyle(PluckrButtonStyle())
                            .disabled(viewModel.isSaving)
                            .padding(.horizontal, PluckrTheme.padding)
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
                    .foregroundColor(PluckrTheme.accentColor)
                }
            }
        }
    }
}
