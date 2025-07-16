import SwiftUI

struct OrganizationSetupView: View {
    @StateObject private var organizationService = OrganizationService.shared
    @State private var organizationName = ""
    @State private var organizationDescription = ""
    @State private var isCreating = false
    @State private var showingMigrationAlert = false
    @State private var isMigrating = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Organization Details")) {
                    TextField("Organization Name", text: $organizationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (Optional)", text: $organizationDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Data Migration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Migrate Existing Data")
                            .font(.headline)
                        
                        Text("This will move your existing clients, tags, and settings into the new organization structure. This action cannot be undone.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Migrate Data") {
                            showingMigrationAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isMigrating)
                        
                        if isMigrating {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Migrating data...")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Create Organization") {
                        createOrganization()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(organizationName.isEmpty || isCreating)
                    
                    if isCreating {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Creating organization...")
                                .font(.caption)
                        }
                    }
                }
                
                if !(organizationService.errorMessage ?? "").isEmpty {
                    Section {
                        Text(organizationService.errorMessage ?? "")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Setup Organization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Migrate Data", isPresented: $showingMigrationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Migrate") {
                migrateData()
            }
        } message: {
            Text("This will move all your existing data into the new organization structure. This action cannot be undone. Are you sure you want to continue?")
        }
        .onAppear {
            Task {
                try? await organizationService.fetchUserOrganizations()
            }
        }
    }
    
    private func createOrganization() {
        guard !organizationName.isEmpty else { return }
        
        isCreating = true
        organizationService.errorMessage = ""
        
        Task {
            do {
                let organization = try await organizationService.createOrganization(
                    name: organizationName,
                    description: organizationDescription.isEmpty ? nil : organizationDescription
                )
                
                // Automatically migrate existing data to the new organization
                do {
                    try await organizationService.migrateExistingData()
                    PluckrLogger.success("Data migration completed for new organization")
                } catch {
                    PluckrLogger.warning("Data migration failed: \(error.localizedDescription)")
                    // Don't fail organization creation if migration fails
                }
                
                await MainActor.run {
                    organizationService.setCurrentOrganization(organization)
                    isCreating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    organizationService.errorMessage = error.localizedDescription
                    isCreating = false
                }
            }
        }
    }
    
    private func migrateData() {
        isMigrating = true
        organizationService.errorMessage = ""
        
        Task {
            do {
                try await organizationService.migrateExistingData()
                await MainActor.run {
                    isMigrating = false
                    organizationService.errorMessage = "Data migration completed successfully!"
                }
            } catch {
                await MainActor.run {
                    organizationService.errorMessage = "Migration failed: \(error.localizedDescription)"
                    isMigrating = false
                }
            }
        }
    }
}

#Preview {
    OrganizationSetupView()
} 