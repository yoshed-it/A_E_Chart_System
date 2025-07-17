import SwiftUI

struct OrganizationSelectionView: View {
    @StateObject private var organizationService = OrganizationService.shared
    @State private var showingCreateOrganization = false
    @State private var showingJoinOrganization = false
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(PluckrTheme.displayFont(size: 60))
                        .foregroundColor(PluckrTheme.accent)
                    
                    Text("Welcome to Pluckr")
                        .font(PluckrTheme.headingFont(size: 38))
                        .fontWeight(.bold)
                    
                    Text("Choose or create an organization to get started")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Organization List
                if !organizationService.userOrganizations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Organizations")
                            .font(PluckrTheme.subheadingFont())
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(organizationService.userOrganizations) { userOrg in
                                    if let org = organizationService.currentOrganization,
                                       userOrg.organizationId == org.id {
                                        OrganizationCard(
                                            organization: org,
                                            userRole: userOrg.role,
                                            isSelected: true
                                        ) {
                                            // Already selected
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingCreateOrganization = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Organization")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(PluckrTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                    }
                    
                    Button(action: {
                        showingJoinOrganization = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Join Organization")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(isPresented: $showingCreateOrganization) {
                OrganizationSetupView()
            }
            .sheet(isPresented: $showingJoinOrganization) {
                JoinOrganizationView()
            }
            .task {
                await loadOrganizations()
            }
        }
    }
    
    private func loadOrganizations() async {
        isLoading = true
        do {
            try await organizationService.fetchUserOrganizations()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct OrganizationCard: View {
    let organization: Organization
    let userRole: OrganizationRole
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(organization.name)
                        .font(PluckrTheme.subheadingFont())
                        .foregroundColor(.primary)
                    
                    if let description = organization.description {
                        Text(description)
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Text(userRole.displayName)
                            .font(PluckrTheme.captionFont())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(userRole.color.opacity(0.18))
                            .foregroundColor(userRole.color)
                            .cornerRadius(PluckrTheme.tagCornerRadius)
                        
                        if isSelected {
                            Text("Current")
                                .font(PluckrTheme.captionFont())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(PluckrTheme.accent.opacity(0.18))
                                .foregroundColor(PluckrTheme.accent)
                                .cornerRadius(PluckrTheme.tagCornerRadius)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PluckrTheme.accent)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(PluckrTheme.cardCornerRadius)
            .shadow(color: PluckrTheme.shadow, radius: 4, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JoinOrganizationView: View {
    @StateObject private var organizationService = OrganizationService.shared
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(PluckrTheme.displayFont(size: 50))
                        .foregroundColor(PluckrTheme.accent)
                    
                    Text("Join Organization")
                        .font(PluckrTheme.subheadingFont(size: 22))
                        .fontWeight(.bold)
                    
                    Text("Enter the invite code provided by your organization")
                        .font(PluckrTheme.bodyFont())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    TextField("Invite Code", text: $inviteCode)
                        .pluckrTextField()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: joinOrganization) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Join Organization")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(PluckrTheme.cardCornerRadius)
                    .disabled(inviteCode.isEmpty || isLoading)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Join Organization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func joinOrganization() {
        guard !inviteCode.isEmpty else { return }
        
        isLoading = true
        Task {
            do {
                try await organizationService.joinOrganization(inviteCode: inviteCode)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    OrganizationSelectionView()
} 

extension OrganizationRole {
    var color: Color {
        switch self {
        case .owner:
            return .purple
        case .admin:
            return .orange
        case .member:
            return .blue
        case .viewer:
            return .gray
        }
    }
} 