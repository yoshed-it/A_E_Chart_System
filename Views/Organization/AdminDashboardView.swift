import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var viewModel = AdminDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                PluckrTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("Admin Dashboard")
                        .font(PluckrTheme.displayFont(size: 28))
                        .foregroundColor(PluckrTheme.textPrimary)
                        .padding(.top, 32)
                    
                    // Providers List
                    Section(header: Text("Providers").font(PluckrTheme.subheadingFont(size: 20))) {
                        if viewModel.isLoading {
                            ProgressView("Loading providers...")
                        } else if viewModel.providers.isEmpty {
                            Text("No providers found.")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                        } else {
                            List {
                                ForEach(viewModel.providers) { provider in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(provider.name)
                                                .font(PluckrTheme.bodyFont())
                                            Text(provider.email)
                                                .font(PluckrTheme.captionFont())
                                                .foregroundColor(PluckrTheme.textSecondary)
                                        }
                                        Spacer()
                                        Picker("Role", selection: Binding(
                                            get: { provider.role },
                                            set: { newRole in
                                                Task { await viewModel.updateProviderRole(providerId: provider.id, newRole: newRole) }
                                            })) {
                                            Text("Admin").tag("admin")
                                            Text("Provider").tag("provider")
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        Toggle(isOn: Binding(
                                            get: { provider.isActive },
                                            set: { isActive in
                                                Task { await viewModel.updateProviderStatus(providerId: provider.id, isActive: isActive) }
                                            })) {
                                            Text("")
                                        }
                                        .labelsHidden()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .listStyle(.plain)
                            .frame(maxHeight: 300)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Invite Codes
                    Section(header: Text("Invite Codes").font(PluckrTheme.subheadingFont(size: 20))) {
                        HStack {
                            Button(action: {
                                viewModel.generateInviteCode { _ in }
                            }) {
                                Label("Generate Invite Code", systemImage: "plus")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(PluckrTheme.accent)
                                    .cornerRadius(12)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        if viewModel.inviteCodes.isEmpty {
                            Text("No invite codes yet.")
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.inviteCodes) { code in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(code.id)
                                                .font(PluckrTheme.bodyFont())
                                                .foregroundColor(code.used ? .gray : PluckrTheme.accent)
                                            Text(code.used ? "Used" : "Active")
                                                .font(PluckrTheme.captionFont())
                                                .foregroundColor(code.used ? .gray : .green)
                                            if let expires = code.expiresAt {
                                                Text("Expires: \(expires.formatted(date: .abbreviated, time: .shortened))")
                                                    .font(PluckrTheme.captionFont())
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(8)
                                        .background(PluckrTheme.card)
                                        .cornerRadius(12)
                                        .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
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
            .onAppear {
                Task {
                    await viewModel.loadProviders()
                    await viewModel.loadInviteCodes()
                }
            }
        }
    }
}

// MARK: - Usage: Place this view in your admin flow for provider and invite management.
// NOTE: This component uses PluckrTheme and follows app design standards. Update as needed for future UI/UX changes. 