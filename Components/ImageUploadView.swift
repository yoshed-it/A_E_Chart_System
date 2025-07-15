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
        VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
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
                        .foregroundColor(PluckrTheme.primaryColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Capture Treatment Image")
                            .font(.journalBody)
                            .fontWeight(.medium)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Text("Document treatment progress")
                            .font(.journalCaption)
                            .foregroundColor(PluckrTheme.secondaryColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(PluckrTheme.accentColor)
                }
                .padding(PluckrTheme.padding)
                .background(Color.white)
                .cornerRadius(PluckrTheme.cornerRadius)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            .opacity(UIImagePickerController.isSourceTypeAvailable(.camera) ? 1.0 : 0.5)

            // Image Gallery
            if !uploadedImageURLs.isEmpty {
                VStack(alignment: .leading, spacing: PluckrTheme.spacing) {
                    Text("Treatment Images")
                        .font(.journalCaption)
                        .foregroundColor(PluckrTheme.secondaryColor)
                        .padding(.horizontal, PluckrTheme.padding)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: PluckrTheme.spacing) {
                            ForEach(uploadedImageURLs, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(PluckrTheme.cornerRadius)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: PluckrTheme.cornerRadius)
                                        .fill(PluckrTheme.backgroundColor)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, PluckrTheme.padding)
                    }
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
    .background(PluckrTheme.backgroundColor)
}
