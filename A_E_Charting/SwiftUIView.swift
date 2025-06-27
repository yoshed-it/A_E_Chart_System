//
//  SwiftUIView.swift
//  A_E_Charting
//
//  Created by Susan Bailey on 6/27/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddClientView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var pronouns = ""

    var onClientAdded: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Pronouns", text: $pronouns)
                TextField("Email", text: $email)
                TextField("Phone", text: $phone)
            }
            .navigationTitle("Add Client")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addClient()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    func addClient() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("providers").document(user.uid).getDocument { snapshot, _ in
            let nameField = snapshot?.data()?["name"] as? String ?? "Unknown"

            db.collection("clients").addDocument(data: [
                "name": name,
                "pronouns": pronouns,
                "email": email,
                "phone": phone,
                "createdAt": FieldValue.serverTimestamp(),
                "createdBy": user.uid,
                "createdByName": nameField,
                "lastSeenAt": FieldValue.serverTimestamp()
            ]) { error in
                if error == nil {
                    onClientAdded()
                    dismiss()
                }
            }
        }
    }
}
