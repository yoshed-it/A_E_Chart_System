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
            ScrollView {
                VStack(alignment: .leading, spacing: PluckrTheme.verticalPadding) {
                    // Title
                    Text("Image Consent")
                        .font(PluckrTheme.headingFont(size: 24))
                        .foregroundColor(PluckrTheme.textPrimary)
                        .padding(.top, PluckrTheme.verticalPadding)
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                    // Consent Text
                    Text(consentText.isEmpty ? defaultConsentText : consentText)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(PluckrTheme.card)
                        .cornerRadius(PluckrTheme.cardCornerRadius)
                        .padding(.horizontal, PluckrTheme.horizontalPadding)
                    // Signature Pad
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Signature")
                                .font(PluckrTheme.subheadingFont(size: 18))
                                .foregroundColor(PluckrTheme.textPrimary)
                            Spacer()
                            if signatureImage != nil {
                                Button("Clear") {
                                    signatureImage = nil
                                }
                                .font(.caption)
                                .foregroundColor(PluckrTheme.accent)
                            }
                        }
                        .padding(.horizontal, 4)
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                                .stroke(PluckrTheme.borderColor, lineWidth: 1)
                                .background(PluckrTheme.card.cornerRadius(PluckrTheme.cardCornerRadius))
                                .frame(height: 140)
                            if let signatureImage = signatureImage {
                                Image(uiImage: signatureImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 8)
                            } else {
                                Button(action: { isSigning = true }) {
                                    VStack {
                                        Text("Sign Here")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "pencil")
                                            .font(.title2)
                                            .foregroundColor(PluckrTheme.accent)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    // Error
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, PluckrTheme.horizontalPadding)
                    }
                    // Save Button
                    Button(action: uploadConsent) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Save Consent")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(signatureImage != nil ? PluckrTheme.accent : PluckrTheme.card)
                                .cornerRadius(PluckrTheme.cardCornerRadius)
                        }
                    }
                    .disabled(signatureImage == nil || isUploading)
                    .padding(.horizontal, PluckrTheme.horizontalPadding)
                    .padding(.bottom, PluckrTheme.verticalPadding)
                }
            }
            .background(PluckrTheme.background.ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(PluckrTheme.accent)
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
        "By signing below, I consent to the secure, encrypted capture and storage of my treatment images for clinical documentation. Images are never stored on this device, are not accessible outside the Pluckr app, and are protected under HIPAA. I understand I may withdraw consent at any time."
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

// Modern, Pluckr-style signature pad (dummy for now)
struct SignaturePadView: View {
    let onSigned: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Text("Draw your signature")
                .font(.caption)
                .foregroundColor(.secondary)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary, lineWidth: 1)
                .background(Color.white.cornerRadius(16))
                .frame(height: 120)
                .overlay(
                    Text("[Signature Pad]")
                        .foregroundColor(.secondary)
                )
            Button("Done") {
                onSigned(UIImage())
                dismiss()
            }
            .font(.body)
            .foregroundColor(PluckrTheme.accent)
        }
        .padding()
        .background(PluckrTheme.card)
        .cornerRadius(PluckrTheme.cardCornerRadius)
        .padding()
    }
} 