import SwiftUI
import PhotosUI

// MARK: - ImageUploadView
struct ImageUploadView: View {
    @Binding var uploadedImageURLs: [String]
    @Binding var showCamera: Bool
    
    var errorMessage: Binding<String?>

    var body: some View {
        Section(header: Text("Images")) {
            Button("Take Photo") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    errorMessage.wrappedValue = "Camera not available on this device."
                }
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            ScrollView(.horizontal) {
                HStack {
                    ForEach(uploadedImageURLs, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().scaledToFit().frame(height: 100).cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}
