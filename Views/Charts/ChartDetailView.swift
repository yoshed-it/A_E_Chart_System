import SwiftUI
import FirebaseStorage
import UIKit

private enum ImageLoadState: Equatable {
    case loading
    case success(UIImage)
    case failure(String)
}

private struct IdentifiableImage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    static func == (lhs: IdentifiableImage, rhs: IdentifiableImage) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChartDetailView: View {
    let chart: ChartEntry
    let onEdit: () -> Void
    
    @State private var imageStates: [URL: ImageLoadState] = [:]
    @State private var selectedImage: IdentifiableImage? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    HStack {
                        Text("Modality:")
                            .bold()
                        Spacer()
                        Text(chart.modality)
                    }
                    
                    HStack {
                        Text("RF Level:")
                            .bold()
                        Spacer()
                        Text("\(chart.rfLevel)")
                    }
                    
                    HStack {
                        Text("DC Level:")
                            .bold()
                        Spacer()
                        Text("\(chart.dcLevel)")
                    }
                    
                    HStack {
                        Text("Probe:")
                            .bold()
                        Spacer()
                        Text(chart.probe)
                    }
                    
                    HStack {
                        Text("Treatment Area:")
                            .bold()
                        Spacer()
                        Text(chart.treatmentArea ?? "")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .bold()
                    Text(chart.notes)
                        .padding(.top, 4)
                }
                
                HStack {
                    Text("Created At:")
                        .bold()
                    Spacer()
                    Text(chart.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
                
                HStack {
                    Text("Last Edited:")
                        .bold()
                    Spacer()
                    if let lastEdited = chart.lastEditedAt {
                        Text("Edited on \(lastEdited.formatted(.dateTime))")
                    }
                }
                .padding()
                imageGallery
            }
            .navigationTitle("Chart Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        onEdit()
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedImage) { identifiableImage in
            FullScreenImageView(image: identifiableImage.image) {
                selectedImage = nil
            }
        }
    }

    private var imageGallery: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !chart.imageURLs.isEmpty {
                Text("Chart Images")
                    .font(.headline)
                    .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(chart.imageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                ChartImageThumbnail(
                                    url: url,
                                    state: imageStates[url] ?? .loading,
                                    onTap: {
                                        if case .success(let img) = imageStates[url] {
                                            selectedImage = IdentifiableImage(image: img)
                                        }
                                    }
                                )
                                .onAppear { loadImage(for: url) }
                            } else {
                                // Invalid URL string, show error placeholder
                                ChartImageThumbnail(
                                    url: URL(string: "")!, // dummy URL, won't be used
                                    state: .failure("Invalid URL"),
                                    onTap: {}
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }

    private func loadImage(for url: URL) {
        guard imageStates[url] == nil else { return } // Already loading/loaded
        imageStates[url] = .loading
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.getData(maxSize: Int64(ImageConstants.maxImageSizeBytes)) { data, error in
            if let error = error {
                PluckrLogger.error("Failed to download image: \(error.localizedDescription)")
                imageStates[url] = .failure("Download error")
                return
            }
            guard let data = data else {
                PluckrLogger.error("No data received for image at \(url)")
                imageStates[url] = .failure("No data")
                return
            }
            guard let orgKey = OrgEncryptionKeyManager.shared.orgKey else {
                PluckrLogger.error("Org encryption key unavailable for image decryption")
                imageStates[url] = .failure("No key")
                return
            }
            guard let image = ChartImageDecryptor.decryptImageData(data, with: orgKey) else {
                PluckrLogger.error("Failed to create UIImage from decrypted data")
                imageStates[url] = .failure("Image decode error")
                return
            }
            imageStates[url] = .success(image)
        }
    }
}

private struct ChartImageThumbnail: View {
    let url: URL
    let state: ImageLoadState
    let onTap: () -> Void
    var body: some View {
        Group {
            switch state {
            case .loading:
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture { onTap() }
                    .accessibilityLabel("Chart image thumbnail")
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .frame(width: 80, height: 80)
            }
        }
    }
}

private struct FullScreenImageView: View, Identifiable {
    let id = UUID()
    let image: UIImage
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .accessibilityLabel("Full-size chart image")
        }
        .onTapGesture { onDismiss() }
        .gesture(DragGesture().onEnded { _ in onDismiss() })
    }
}
