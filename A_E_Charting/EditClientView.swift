import SwiftUI
import FirebaseFirestore

struct EditClientView: View {
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String
    @State private var lastName: String
    @State private var pronouns: String
    @State private var phone: String
    @State private var isSaving = false
    @State private var errorMessage = ""

    let clientID: String
    let onSave: () -> Void

    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]

    init(client: Client, onSave: @escaping () -> Void) {
        self.clientID = client.id
        self._firstName = State(initialValue: client.name.components(separatedBy: " ").first ?? "")
        self._lastName = State(initialValue: client.name.components(separatedBy: " ").dropFirst().joined(separator: " "))
        self._pronouns = State(initialValue: client.pronouns)
        self._phone = State(initialValue: "") // You can load this onAppear if needed
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Client")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)

                    Picker("Pronouns", selection: $pronouns) {
                        ForEach(pronounOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }

                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Client")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateClient()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || pronouns.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(perform: loadPhone)
    }

    private func loadPhone() {
        let db = Firestore.firestore()
        db.collection("clients").document(clientID).getDocument { snapshot, error in
            if let data = snapshot?.data(), let phone = data["phone"] as? String {
                self.phone = phone
            }
        }
    }

    private func updateClient() {
        let db = Firestore.firestore()
        let name = "\(firstName) \(lastName)"

        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "name": name,
            "pronouns": pronouns,
            "phone": phone,
            "lastSeenAt": Timestamp(date: Date()) // optional update
        ]

        isSaving = true
        db.collection("clients").document(clientID).updateData(updatedData) { error in
            isSaving = false
            if let error = error {
                errorMessage = "Failed to save: \(error.localizedDescription)"
            } else {
                print("✅ Client updated.")
                onSave()
                dismiss()
            }
        }
    }
}
