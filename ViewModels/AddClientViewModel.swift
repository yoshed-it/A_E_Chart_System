import Foundation
import FirebaseAuth

@MainActor
class AddClientViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var pronouns = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var isSaving = false
    @Published var errorMessage = ""

    var onClientAdded: () -> Void = {}

    private let repository = ClientRepository()

    func saveClient() {
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

        repository.createClient(from: input) { [weak self] success in
            Task { @MainActor in
                self?.isSaving = false
                if success {
                    self?.onClientAdded()
                } else {
                    self?.errorMessage = "Failed to save client."
                }
            }
        }
    }
}
