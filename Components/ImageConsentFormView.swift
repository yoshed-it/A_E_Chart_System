import SwiftUI

struct ImageConsentFormView: View {
    let client: Client
    let onSigned: (Client) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var signatureImage: UIImage? = nil
    @State private var isSigning = false
    @State private var isUploading = false
    @State private var errorMessage: String? = nil
    @State private var consentText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Consent")) {
                    Text(consentText.isEmpty ? defaultConsentText : consentText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                }
                Section(header: Text("Signature")) {
                    if let signatureImage = signatureImage {
                        Image(uiImage: signatureImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    } else {
                        Button("Sign Consent") {
                            isSigning = true
                        }
                        .font(.headline)
                        .padding()
                    }
                }
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Image Consent")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        uploadConsent()
                    }
                    .disabled(signatureImage == nil || isUploading)
                }
            }
            .sheet(isPresented: $isSigning) {
                SignaturePadView(onSigned: { image in
                    signatureImage = image
                    isSigning = false
                })
            }
        }
    }
    
    private var defaultConsentText: String {
        "I consent to the capture and secure, encrypted storage of my treatment images for clinical documentation purposes. Images are never stored on this device or accessible outside the Pluckr app."
    }
    
    private func uploadConsent() {
        // Simulate upload and callback
        isUploading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isUploading = false
            var updatedClient = client
            updatedClient.hasSignedImageConsent = true
            onSigned(updatedClient)
            dismiss()
        }
    }
}

// Dummy signature pad for preview/demo
struct SignaturePadView: View {
    let onSigned: (UIImage) -> Void
    var body: some View {
        VStack {
            Text("[Signature Pad Here]")
                .frame(height: 120)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            Button("Done") {
                onSigned(UIImage())
            }
            .padding()
        }
    }
} 