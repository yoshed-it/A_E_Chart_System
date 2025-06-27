import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddClientView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var pronouns = ""  // Start empty, not "Select"
    let pronounOptions = ["She/Her", "He/Him", "They/Them", "Other"]
    @State private var phone = ""
    @State private var isSaving = false
    @State private var errorMessage = ""

    var onClientAdded: () -> Void

    var body: some View {
        Form {
            Section(header: Text("Client Info")) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                
                Picker("Pronouns", selection: $pronouns) {
                    Text("Select").tag("").disabled(true)  // 🔹 Safe placeholder
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

    func saveClient() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No authenticated user."
            return
        }

        isSaving = true
        let db = Firestore.firestore()
        let clientRef = db.collection("clients").document()
        let clientData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "name": "\(firstName) \(lastName)",
            "pronouns": pronouns,
            "phone": phone,
            "createdBy": user.uid,
            "createdByName": user.email ?? "Unknown",
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
