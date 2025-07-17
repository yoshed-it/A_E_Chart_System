import SwiftUI
import FirebaseAuth

/**
 *Custom probe creation sheet*
 
 This component provides a form for creating custom probes with
 proper validation and database integration.
 
 ## Usage
 ```swift
 CustomProbeSheet(
     isPresented: $showCustomProbeSheet,
     onProbeCreated: { probe in
         // Handle newly created probe
     }
 )
 ```
 */
struct CustomProbeSheet: View {
    @Binding var isPresented: Bool
    let onProbeCreated: (Probe) -> Void
    
    @StateObject private var probeService = ProbeService.shared
    @State private var probeName: String = ""
    @State private var probeType: Probe.ProbeType = .onePiece
    @State private var specifications: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Create Custom Probe")
                        .font(PluckrTheme.headingFont(size: 28))
                        .foregroundColor(PluckrTheme.textPrimary)
                    Text("Add a new probe configuration")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                }
                .padding(.top, PluckrTheme.verticalPadding)
                
                // Form Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Probe Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Probe Name")
                                .pluckrSectionHeader()
                            
                            TextField("e.g. Custom F2 Gold", text: $probeName)
                                .pluckrTextField()
                        }
                        
                        // Probe Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Probe Type")
                                .pluckrSectionHeader()
                            
                            Picker("Probe Type", selection: $probeType) {
                                ForEach(Probe.ProbeType.allCases, id: \.self) { type in
                                    Text(type.displayName)
                                        .font(PluckrTheme.bodyFont())
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.pluckrCard)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                                .stroke(PluckrTheme.borderColor, lineWidth: 1)
                        )
                        
                        // Specifications
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Specifications")
                                .pluckrSectionHeader()
                            
                            TextField("e.g. 0.1mm diameter, gold-plated tip", text: $specifications)
                                .pluckrTextField()
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(PluckrTheme.captionFont())
                                .foregroundColor(PluckrTheme.error)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                }
                
                // Save Button
                VStack(spacing: 12) {
                    Button(action: saveCustomProbe) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Create Probe")
                                .font(PluckrTheme.subheadingFont())
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? PluckrTheme.accent : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(PluckrTheme.buttonCornerRadius)
                    .disabled(!isFormValid || isSaving)
                    
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textSecondary)
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
                .padding(.bottom, PluckrTheme.verticalPadding)
            }
            .background(PluckrTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(PluckrTheme.accent)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !probeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !specifications.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Actions
    
    private func saveCustomProbe() {
        guard isFormValid else { return }
        
        isSaving = true
        errorMessage = nil
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "User not authenticated"
            isSaving = false
            return
        }
        
        let customProbe = Probe(
            id: UUID().uuidString,
            name: probeName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: probeType,
            specifications: specifications.trimmingCharacters(in: .whitespacesAndNewlines),
            isCustom: true,
            createdBy: currentUser.uid,
            createdByName: currentUser.displayName ?? "Unknown",
            createdAt: Date(),
            isActive: true
        )
        
        Task {
            do {
                try await probeService.saveCustomProbe(customProbe)
                
                await MainActor.run {
                    isSaving = false
                    onProbeCreated(customProbe)
                    isPresented = false
                }
                
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to create probe: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    CustomProbeSheet(
        isPresented: .constant(true),
        onProbeCreated: { _ in }
    )
} 