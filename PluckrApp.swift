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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    if organizationService.currentOrganization != nil {
                        ProviderHomeView()
                            .environmentObject(authService)
                            .environmentObject(organizationService)
                    } else {
                        // Show organization setup or selection
                        OrganizationSelectionView()
                            .environmentObject(authService)
                            .environmentObject(organizationService)
                    }
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .onAppear {
                Task {
                    try? await organizationService.fetchUserOrganizations()
                }
            }
        }
    }
}


