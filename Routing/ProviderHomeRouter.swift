//
//  ProviderHomeRouter.swift
//  A_E_Charting
//
//  Created by Yosh Nebe on 6/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProviderHomeRouter: View {
    @State private var providerExists = false
    @State private var isLoading = true
    @State private var didFinishSetup = false
    
    var body: some View {
        let content: AnyView

        if isLoading {
            content = AnyView(ProgressView("Loading..."))
        } else if providerExists {
            content = AnyView(ProviderHomeView())
        } else {
            content = AnyView(ProviderProfileSetupView(didFinishSetup: $didFinishSetup))
        }

        return content
            .onAppear {
                checkIfProviderExists()
            }
            .onChange(of: didFinishSetup) { oldValue, newValue in
                if newValue {
                    isLoading = true
                    checkIfProviderExists()
                }
            }
    }
    
    func checkIfProviderExists() {
        guard let user = Auth.auth().currentUser else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("providers").document(user.uid)
        
        docRef.getDocument { docSnapshot, error in
            defer { isLoading = false }
            
            if let error = error {
                print("❌ Firestore error: \(error.localizedDescription)")
                return
            }
            
            guard let doc = docSnapshot, doc.exists else {
                print("🆕 No provider doc, go to setup")
                return
            }
            
            let data = doc.data()
            let name = data?["name"] as? String ?? ""
            
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("⚠️ Provider profile incomplete — missing name.")
            } else {
                print("✅ Provider profile complete. Name: \(name)")
                providerExists = true
            }
        }
    }
}
