//
//  LoginView.swift
//  A_E_Charting
//
//  Created by Yoah Nebe on 6/27/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            ProviderHomeRouter()
        } else {
            VStack(spacing: 20) {
                Text("Login").font(.largeTitle).bold()

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if let error = loginError {
                    Text(error).foregroundColor(.red)
                }

                Button("Sign In") {
                    login()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                loginError = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}
