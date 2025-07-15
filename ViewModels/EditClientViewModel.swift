//
//  EditClientViewModel.swift
//  Pluckr
//
//  Created by Susan Bailey on 7/14/25.
//

import Foundation
import FirebaseAuth

@MainActor
class EditClientViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var pronouns = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var isSaving = false
    @Published var errorMessage = ""

    var onClientUpdated: () -> Void = {}
    private let repository = ClientRepository()
    private let clientId: String

    init(client: Client) {
        self.clientId = client.id
        self.firstName = client.firstName
        self.lastName = client.lastName
        self.pronouns = client.pronouns ?? ""
        self.phone = client.phone ?? ""
        self.email = client.email ?? ""
    }

    func saveChanges() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No authenticated user."
            return
        }

        isSaving = true
        errorMessage = ""

        let firstNameTrimmed = firstName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lastNameTrimmed = lastName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let phoneTrimmed = phone.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let emailTrimmed = email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        guard !firstNameTrimmed.isEmpty,
              !lastNameTrimmed.isEmpty,
              !pronouns.isEmpty,
              !phoneTrimmed.isEmpty else {
            errorMessage = "All fields are required."
            isSaving = false
            return
        }

        guard Validation.isValidPhone(phoneTrimmed) else {
            errorMessage = "Invalid phone number. Enter 10-15 digits."
            isSaving = false
            return
        }

        if !emailTrimmed.isEmpty && !Validation.isValidEmail(emailTrimmed) {
            errorMessage = "Invalid email address."
            isSaving = false
            return
        }

        let input = ClientInput(
            firstName: firstNameTrimmed,
            lastName: lastNameTrimmed,
            phone: phoneTrimmed,
            email: emailTrimmed.isEmpty ? nil : emailTrimmed,
            pronouns: pronouns,
            createdBy: user.uid,
            createdByName: user.displayName ?? "Unknown"
        )

        let updatedClient = Client(
            id: clientId,
            firstName: firstNameTrimmed,
            lastName: lastNameTrimmed,
            phone: phoneTrimmed.isEmpty ? nil : phoneTrimmed,
            email: emailTrimmed.isEmpty ? nil : emailTrimmed,
            pronouns: pronouns,
            createdBy: user.uid,
            createdByName: user.displayName ?? "Unknown",
            lastSeenAt: Date(),
            createdAt: nil
        )

        repository.updateClient(updatedClient) { success in
            Task { @MainActor in
                self.isSaving = false
                if success {
                    self.onClientUpdated()
                } else {
                    self.errorMessage = "Failed to update client."
                }
            }
        }
    }
}

