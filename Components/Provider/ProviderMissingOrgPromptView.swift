import SwiftUI

/**
 *Displays a prompt when the provider has no organization*
 
 This component shows when a provider hasn't joined or created an organization yet.
 It provides buttons to either join an existing organization or create a new one.
 
 ## Usage
 ```swift
 ProviderMissingOrgPromptView(
     showJoinOrganization: $showJoinOrganization,
     showCreateOrganization: $showCreateOrganization
 )
 ```
 
 ## Used in
 - ProviderHomeView
 */
struct ProviderMissingOrgPromptView: View {
    @Binding var showJoinOrganization: Bool
    @Binding var showCreateOrganization: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "building.2")
                    .font(.system(size: 64))
                    .foregroundColor(PluckrTheme.accent)
                
                Text("No Organization")
                    .font(PluckrTheme.headingFont())
                    .foregroundColor(PluckrTheme.textPrimary)
                
                Text("You need to join or create an organization to start using Pluckr.")
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                Button(action: { showJoinOrganization = true }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                        Text("Join Organization")
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PluckrTheme.accent)
                    .cornerRadius(12)
                }
                
                Button(action: { showCreateOrganization = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Organization")
                    }
                    .font(PluckrTheme.bodyFont())
                    .foregroundColor(PluckrTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PluckrTheme.accent.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding()
    }
} 