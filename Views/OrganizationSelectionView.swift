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
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to Pluckr")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose or create an organization to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Organization List
                if !organizationService.userOrganizations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Organizations")
                            .font(.headline)
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
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
                        .cornerRadius(12)
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
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let description = organization.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Text(userRole.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(userRole.color.opacity(0.2))
                            .foregroundColor(userRole.color)
                            .cornerRadius(8)
                        
                        if isSelected {
                            Text("Current")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Join Organization")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter the invite code provided by your organization")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    TextField("Invite Code", text: $inviteCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    .cornerRadius(12)
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