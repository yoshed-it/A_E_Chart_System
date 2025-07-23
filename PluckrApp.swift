//
//  A_E_ChartingApp.swift
//  A_E_Charting
//
//  Created by Yosh Nebe on 6/27/25.
//

import SwiftUI
import Firebase

@main
struct PluckrApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var organizationService = OrganizationService.shared
    @State private var showingOrganizationSetup = false
    @State private var showingLaunchScreen = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showingLaunchScreen {
                    LaunchScreenView()
                        .onAppear {
                            // Show launch screen for 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showingLaunchScreen = false
                                }
                            }
                        }
                } else if authService.isAuthenticated {
                    // Check if user has any organizations
                    let hasOrganizations = !organizationService.userOrganizations.isEmpty
                    
                    if hasOrganizations {
                        // User has organizations, show main app
                        ProviderHomeView()
                            .environmentObject(authService)
                            .environmentObject(organizationService)
                            .onAppear {
                                PluckrLogger.info("App checking organizations. Has organizations: \(hasOrganizations), Count: \(organizationService.userOrganizations.count)")
                                PluckrLogger.info("Showing ProviderHomeView")
                            }
                    } else {
                        // User has no organizations, show organization setup
                        OrganizationSelectionView()
                            .environmentObject(authService)
                            .environmentObject(organizationService)
                            .onAppear {
                                PluckrLogger.info("App checking organizations. Has organizations: \(hasOrganizations), Count: \(organizationService.userOrganizations.count)")
                                PluckrLogger.info("Showing OrganizationSelectionView")
                            }
                    }
                } else {
                    // Show login/signup screen first
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .onAppear {
                Task {
                    // Give the organization service time to initialize
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    try? await organizationService.fetchUserOrganizations()
                }
            }
            .onChange(of: organizationService.userOrganizations.count) { _, count in
                PluckrLogger.info("Organization count changed to: \(count)")
            }
        }
    }
}


