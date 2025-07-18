import SwiftUI

struct CreateOrganizationView: View {
    @StateObject private var viewModel = CreateOrganizationViewModel()
    var onOrgCreated: ((String) -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Create Organization")
                            .font(PluckrTheme.displayFont(size: 28))
                            .foregroundColor(PluckrTheme.textPrimary)
                        Text("Set up your clinic or organization to get started.")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        TextField("Organization Name", text: $viewModel.orgName)
                            .pluckrTextField()
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                        TextField("Description (optional)", text: $viewModel.orgDescription)
                            .pluckrTextField()
                            .autocapitalization(.sentences)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                        Button(action: {
                            Task {
                                viewModel.onOrgCreated = onOrgCreated
                                await viewModel.createOrganization()
                            }
                        }) {
                            if viewModel.isCreating {
                                ProgressView()
                            } else {
                                Text("Create Organization")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(PluckrTheme.accent)
                                    .cornerRadius(PluckrTheme.cardCornerRadius)
                                    .shadow(color: PluckrTheme.shadow, radius: 8, x: 0, y: 2)
                            }
                        }
                        .disabled(viewModel.orgName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isCreating)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 24)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(PluckrTheme.bodyFont())
                            .padding(.horizontal)
                    }
                    if let success = viewModel.successMessage {
                        Text(success)
                            .foregroundColor(.green)
                            .font(PluckrTheme.bodyFont())
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Usage: Place this view in your onboarding flow for org creation.
// NOTE: This component uses PluckrTheme and follows app design standards. Update as needed for future UI/UX changes. 