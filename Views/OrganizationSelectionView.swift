import SwiftUI

struct OrganizationSelectionView: View {
    @StateObject private var viewModel = OrganizationSelectionViewModel()
    @StateObject private var organizationService = OrganizationService.shared
    @State private var showingCreateOrganization = false

    
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
                    
                    Text("Create your organization to get started")
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
                
                // Action Button
                VStack(spacing: 16) {
                    Button(action: {
                        showingCreateOrganization = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Organization")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(PluckrTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showingCreateOrganization) {
                OrganizationSetupView()
                    .onDisappear {
                        // Refresh organizations when the sheet is dismissed
                        Task {
                            await viewModel.loadOrganizations()
                        }
                    }
            }
            .task {
                await viewModel.loadOrganizations()
            }

        }
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