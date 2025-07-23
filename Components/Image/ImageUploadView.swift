import SwiftUI
import PhotosUI

/**
 *Image upload and display component*
 
 This component provides camera capture functionality and displays
 uploaded treatment images in a horizontal scroll view.
 
 ## Usage
 ```swift
 ImageUploadView(
     uploadedImageURLs: $viewModel.uploadedImageURLs,
     showCamera: $showCamera,
     errorMessage: $viewModel.imageUploadErrorMessage
 )
 ```
 */
struct ImageUploadView: View {
    @Binding var uploadedImageURLs: [String]
    @Binding var showCamera: Bool
    var errorMessage: Binding<String?>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Camera Button
            Button(action: {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    errorMessage.wrappedValue = "Camera not available on this device."
                }
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(PluckrTheme.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Capture Treatment Image")
                            .font(PluckrTheme.bodyFont())
                            .fontWeight(.medium)
                            .foregroundColor(PluckrTheme.textPrimary)
                        
                        Text("Document treatment progress")
                            .font(PluckrTheme.captionFont())
                            .foregroundColor(PluckrTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(PluckrTheme.accent)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.pluckrCard)
                .cornerRadius(PluckrTheme.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                        .stroke(PluckrTheme.borderColor, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            .opacity(UIImagePickerController.isSourceTypeAvailable(.camera) ? 1.0 : 0.5)

            // Image Gallery
            if !uploadedImageURLs.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Treatment Images")
                        .pluckrSectionHeader()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(uploadedImageURLs, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(PluckrTheme.cardCornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                                                .stroke(PluckrTheme.borderColor, lineWidth: 1)
                                        )
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                                        .fill(PluckrTheme.background)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                                                .stroke(PluckrTheme.borderColor, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.pluckrCard)
                    .cornerRadius(PluckrTheme.cardCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: PluckrTheme.cardCornerRadius)
                            .stroke(PluckrTheme.borderColor, lineWidth: 1)
                    )
                }
            }
        }
    }
}

#Preview {
    ImageUploadView(
        uploadedImageURLs: .constant([
            "https://example.com/image1.jpg",
            "https://example.com/image2.jpg"
        ]),
        showCamera: .constant(false),
        errorMessage: .constant(nil)
    )
    .padding()
    .background(PluckrTheme.background)
}
