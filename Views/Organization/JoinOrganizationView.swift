import SwiftUI

struct JoinOrganizationView: View {
    @StateObject private var viewModel = JoinOrganizationViewModel()
    var onJoinSuccess: ((String, String) -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Join Organization")
                            .font(PluckrTheme.displayFont(size: 28))
                            .foregroundColor(PluckrTheme.textPrimary)
                        Text("Enter your invite code to join your clinic or organization.")
                            .font(PluckrTheme.bodyFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        TextField("Invite Code", text: $viewModel.inviteCode)
                            .pluckrTextField()
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                        TextField("Organization ID", text: $viewModel.orgId)
                            .pluckrTextField()
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                        Button(action: {
                            viewModel.onJoinSuccess = onJoinSuccess
                            viewModel.joinOrg()
                        }) {
                            if viewModel.isJoining {
                                ProgressView()
                            } else {
                                Text("Join Organization")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(PluckrTheme.accent)
                                    .cornerRadius(PluckrTheme.cardCornerRadius)
                                    .shadow(color: PluckrTheme.shadow, radius: 8, x: 0, y: 2)
                            }
                        }
                        .disabled(viewModel.inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.orgId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isJoining)
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

// MARK: - Usage: Place this view in your onboarding flow where providers join via invite code.
// NOTE: This component uses PluckrTheme and follows app design standards. Update as needed for future UI/UX changes. 
