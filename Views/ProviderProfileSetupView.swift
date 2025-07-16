//
//  ProviderProfileSetupView.swift
//  A_E_Charting
//
//  Created by Yosh Nebe on 6/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProviderProfileSetupView: View {
    @State private var name = ""
    @State private var phone = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    @Binding var didFinishSetup: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Up Your Provider Profile")
                .font(.title2)
                .bold()

            TextField("Full Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Phone Number", text: $phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
                .phoneNumberFormatting(text: $phone)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: saveProfile) {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Save Profile")
                }
            }
            .disabled(name.isEmpty || phone.isEmpty)
        }
        .padding()
    }

    func saveProfile() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No authenticated user found."
            return
        }

        isSaving = true
        let db = Firestore.firestore()
        let docRef = db.collection("providers").document(user.uid)
        let providerData: [String: Any] = [
            "name": name,
            "phone": phone,
            "email": user.email ?? ""
        ]

        docRef.setData(providerData) { error in
            isSaving = false
            if let error = error {
                errorMessage = "Error saving profile: \(error.localizedDescription)"
            } else {
                print("✅ Profile saved to Firestore.")
                didFinishSetup = true 
            }
        }
    }
}

