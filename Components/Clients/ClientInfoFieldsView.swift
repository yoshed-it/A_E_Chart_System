/// Used in: ClientDetailView (Views/Clients/ClientDetailView.swift)
import SwiftUI

struct ClientInfoFieldsView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var pronouns: String
    @Binding var phone: String
    @Binding var email: String

    var body: some View {
        Group {
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            TextField("Pronouns", text: $pronouns)
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .phoneNumberFormatting(text: $phone)
            TextField("Email", text: $email)
        }
    }
} 