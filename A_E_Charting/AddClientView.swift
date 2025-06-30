import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddClientView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var pronouns = ""  // Start empty
    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]
    @State private var phone = ""
    @State private var isSaving = false
    @State private var errorMessage = ""

    var onClientAdded: () -> Void
    var providerDisplayName: String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Client Info")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)

                    Picker("Pronouns", selection: $pronouns) {
                        Text("Select").tag("").disabled(true)
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

                Button(action: saveClient) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Client")
                    }
                }
                .disabled(firstName.isEmpty || lastName.isEmpty || pronouns.isEmpty || phone.isEmpty)
            }
            .navigationTitle("Add New Client")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func saveClient() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No authenticated user."
            return
        }

        isSaving = true

        // Trim inputs
        let firstNameTrimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastNameTrimmed = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneTrimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic phone validation
        guard phoneTrimmed.allSatisfy(\.isNumber) else {
            errorMessage = "Phone number should contain only digits."
            isSaving = false
            return
        }

        let db = Firestore.firestore()
        let clientRef = db.collection("clients").document()
        let clientData: [String: Any] = [
            "firstName": firstNameTrimmed,
            "lastName": lastNameTrimmed,
            "name": "\(firstNameTrimmed) \(lastNameTrimmed)",
            "pronouns": pronouns,
            "phone": phoneTrimmed,
            "createdBy": user.uid,
            "createdByName": providerDisplayName,
            "createdAt": Timestamp(date: Date()),
            "lastSeenAt": Timestamp(date: Date())
        ]

        clientRef.setData(clientData) { error in
            isSaving = false
            if let error = error {
                errorMessage = "Failed to save: \(error.localizedDescription)"
            } else {
                print("✅ Client saved.")
                onClientAdded()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
