import SwiftUI

/**
 *Displays the provider header with name and welcome message*
 
 This component shows the provider's name and a welcome message at the top
 of the provider home screen.
 
 ## Usage
 ```swift
 ProviderHeaderView(providerName: "Dr. Smith")
 ```
 
 ## Used in
 - ProviderHomeView
 */
struct ProviderHeaderView: View {
    let providerName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back,")
                .font(PluckrTheme.bodyFont())
                .foregroundColor(PluckrTheme.textSecondary)
            
            Text(providerName.isEmpty ? "Provider" : providerName)
                .font(PluckrTheme.headingFont())
                .foregroundColor(PluckrTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PluckrTheme.horizontalPadding)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
} 