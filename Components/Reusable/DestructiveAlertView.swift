// DestructiveAlertView.swift
// Used in EditClientView for delete client confirmation
import SwiftUI

struct DestructiveAlertView: View {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    let destructiveAction: () -> Void
    let destructiveLabel: String
    let cancelLabel: String

    var body: some View {
        EmptyView()
            .alert(title, isPresented: $isPresented) {
                Button(destructiveLabel, role: .destructive, action: destructiveAction)
                Button(cancelLabel, role: .cancel) {}
            } message: {
                Text(message)
            }
    }
} 