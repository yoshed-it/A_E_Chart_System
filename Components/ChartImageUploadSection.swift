/// Used in: ChartEntryFormView (Views/Charts/ChartEntryFormView.swift)
import SwiftUI

struct ChartImageUploadSection: View {
    @Binding var uploadedImageURLs: [String]
    @Binding var showCamera: Bool
    var errorMessage: Binding<String?>
    var body: some View {
        ImageUploadView(
            uploadedImageURLs: $uploadedImageURLs,
            showCamera: $showCamera,
            errorMessage: errorMessage
        )
    }
}

#Preview {
    @State var uploadedImageURLs: [String] = []
    @State var showCamera = false
    @State var errorMessage: String? = nil
    return ChartImageUploadSection(
        uploadedImageURLs: $uploadedImageURLs,
        showCamera: $showCamera,
        errorMessage: Binding(
            get: { errorMessage },
            set: { errorMessage = $0 }
        )
    )
    .padding()
    .background(PluckrTheme.background)
} 