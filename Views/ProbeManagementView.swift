import SwiftUI

/**
 *Probe management view for administrators*
 
 This view allows administrators to view, manage, and organize all probes
 in the system, including predefined and custom probes.
 
 ## Features
 - View all probes (predefined and custom)
 - Toggle probe active status
 - View probe details and specifications
 - Filter by probe type
 */
struct ProbeManagementView: View {
    @StateObject private var probeService = ProbeService.shared
    @State private var selectedFilter: ProbeFilter = .all
    @State private var showCustomProbeSheet = false
    @State private var searchText = ""
    
    enum ProbeFilter: String, CaseIterable {
        case all = "All"
        case onePiece = "One-Piece"
        case twoPiece = "Two-Piece"
        case custom = "Custom"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    TextField("Search probes...", text: $searchText)
                        .pluckrTextField()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ProbeFilter.allCases, id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter.displayName)
                                        .font(PluckrTheme.captionFont())
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? PluckrTheme.accent : Color.pluckrCard)
                                        .foregroundColor(selectedFilter == filter ? .white : PluckrTheme.textPrimary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedFilter == filter ? PluckrTheme.accent : PluckrTheme.borderColor, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                    }
                }
                .padding(.horizontal, PluckrTheme.horizontalPadding)
                .padding(.vertical, 16)
                .background(Color.pluckrCard)
                
                // Probe List
                if probeService.isLoading {
                    Spacer()
                    ProgressView("Loading probes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredProbes) { probe in
                            ProbeRowView(probe: probe) { updatedProbe in
                                // Handle probe status update
                                Task {
                                    try await probeService.updateProbeStatus(
                                        probeId: updatedProbe.id,
                                        isActive: updatedProbe.isActive
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Probe Management")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCustomProbeSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(PluckrTheme.accent)
                            .font(PluckrTheme.subheadingFont(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showCustomProbeSheet) {
                CustomProbeSheet(
                    isPresented: $showCustomProbeSheet,
                    onProbeCreated: { _ in
                        // The probe service will automatically refresh
                    }
                )
            }
            .refreshable {
                probeService.fetchProbes()
            }
            .onAppear {
                if probeService.probes.isEmpty {
                    probeService.fetchProbes()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredProbes: [Probe] {
        var probes = probeService.probes
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .onePiece:
            probes = probes.filter { $0.type == .onePiece }
        case .twoPiece:
            probes = probes.filter { $0.type == .twoPiece }
        case .custom:
            probes = probes.filter { $0.isCustom }
        }
        
        // Apply search
        if !searchText.isEmpty {
            probes = probes.filter { probe in
                probe.name.localizedCaseInsensitiveContains(searchText) ||
                probe.specifications.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return probes.sorted { $0.name < $1.name }
    }
}

// MARK: - Probe Row View

struct ProbeRowView: View {
    let probe: Probe
    let onStatusChanged: (Probe) -> Void
    
    @State private var isActive: Bool
    
    init(probe: Probe, onStatusChanged: @escaping (Probe) -> Void) {
        self.probe = probe
        self.onStatusChanged = onStatusChanged
        self._isActive = State(initialValue: probe.isActive)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(probe.name)
                            .font(PluckrTheme.bodyFont())
                            .fontWeight(.medium)
                            .foregroundColor(PluckrTheme.textPrimary)
                        
                        if probe.isCustom {
                            Text("Custom")
                                .font(PluckrTheme.captionFont())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(PluckrTheme.accent.opacity(0.2))
                                .foregroundColor(PluckrTheme.accent)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(probe.type.displayName)
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isActive)
                    .onChange(of: isActive) { _, newValue in
                        var updatedProbe = probe
                        updatedProbe.isActive = newValue
                        onStatusChanged(updatedProbe)
                    }
            }
            
            Text(probe.specifications)
                .font(PluckrTheme.captionFont())
                .foregroundColor(PluckrTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(PluckrTheme.background)
                .cornerRadius(8)
            
            if probe.isCustom {
                HStack {
                    Text("Created by \(probe.createdByName ?? "Unknown")")
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.background)
                    
                    Spacer()
                    
                    Text(probe.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(PluckrTheme.captionFont())
                        .foregroundColor(PluckrTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProbeManagementView()
} 
