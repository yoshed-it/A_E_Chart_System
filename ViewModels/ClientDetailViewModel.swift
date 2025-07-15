import Foundation
import SwiftUI

@MainActor
class ClientDetailViewModel: ObservableObject {
    @Published var client: Client
    @Published var isSaving = false
    @Published var errorMessage = ""

    private let repository = ClientRepository()

    init(client: Client) {
        self.client = client
    }

    func saveChanges(onSuccess: @escaping () -> Void) {
        isSaving = true
        errorMessage = ""

        repository.updateClient(client) { [weak self] success in
            Task { @MainActor in
                self?.isSaving = false
                if success {
                    onSuccess()
                } else {
                    self?.errorMessage = "Failed to save changes."
                }
            }
        }
    }

    func deleteClient(onSuccess: @escaping () -> Void) {
        repository.archiveClient(client) { [weak self] success in
            Task { @MainActor in
                if success {
                    onSuccess()
                } else {
                    self?.errorMessage = "Failed to archive client."
                }
            }
        }
    }

    // Optional binding-friendly properties for TextFields
    var firstNameBinding: Binding<String> {
        Binding(
            get: { self.client.firstName },
            set: { self.client.firstName = $0 }
        )
    }

    var lastNameBinding: Binding<String> {
        Binding(
            get: { self.client.lastName },
            set: { self.client.lastName = $0 }
        )
    }

    var pronounsBinding: Binding<String> {
        Binding(
            get: { self.client.pronouns ?? "" },
            set: { self.client.pronouns = $0 }
        )
    }

    var phoneBinding: Binding<String> {
        Binding(
            get: { self.client.phone ?? "" },
            set: { self.client.phone = $0 }
        )
    }

    var emailBinding: Binding<String> {
        Binding(
            get: { self.client.email ?? "" },
            set: { self.client.email = $0 }
        )
    }
}
