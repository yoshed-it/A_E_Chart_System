import SwiftUI
import PhotosUI

// MARK: - ImageSection
struct ImageSection: View {
    @Binding var uploadedImageURLs: [String]
    @Binding var imageSelections: [PhotosPickerItem]
    @Binding var showCamera: Bool
    @Binding var errorMessage: String
    let clientId: String

    var body: some View {
        Section(header: Text("Images")) {
            Button("Take Photo") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    errorMessage = "Camera not available on this device."
                }
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            PhotosPicker("Select Photos", selection: $imageSelections, maxSelectionCount: 5, matching: .images)
                .padding(.vertical, 5)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(uploadedImageURLs, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}
