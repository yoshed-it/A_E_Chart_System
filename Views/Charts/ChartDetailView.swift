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
            VStack(alignment: .leading, spacing: 24) {
                // Treatment Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Treatment Details")
                        .pluckrSectionHeader()
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Modality")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Spacer()
                            Text(chart.modality)
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
                        
                        HStack {
                            Text("RF Level")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Spacer()
                            Text(chart.formattedRFLevel)
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
                        
                        HStack {
                            Text("DC Level")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Spacer()
                            Text(chart.formattedDCLevel)
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
                        
                        HStack {
                            Text("Probe")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Spacer()
                            Text(chart.probe)
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
                        
                        HStack {
                            Text("Treatment Area")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Spacer()
                            Text(chart.treatmentArea ?? "Not specified")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
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
                
                // Chart Tags Section
                if !chart.chartTags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chart Tags")
                            .pluckrSectionHeader()
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                            ForEach(chart.chartTags) { tag in
                                TagView(tag: tag, size: .large)
                            }
                        }
                    }
                }
                
                // Clinical Notes Section
                if !chart.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Clinical Notes")
                            .pluckrSectionHeader()
                        NotesCard(mode: .view(chart.notes))
                    }
                }
                
                // Metadata Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Chart Information")
                        .pluckrSectionHeader()
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Created")
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textSecondary)
                            Spacer()
                            Text(chart.formattedCreatedAt)
                                .font(PluckrTheme.bodyFont())
                                .foregroundColor(PluckrTheme.textPrimary)
                        }
                        
                        if let lastEdited = chart.formattedLastEditedAt {
                            HStack {
                                Text("Last Edited")
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(PluckrTheme.textSecondary)
                                Spacer()
                                Text(lastEdited)
                                    .font(PluckrTheme.bodyFont())
                                    .foregroundColor(PluckrTheme.textPrimary)
                            }
                        }
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
                
                imageGallery
            }
            .padding(.horizontal, PluckrTheme.horizontalPadding)
            .padding(.vertical, PluckrTheme.verticalPadding)
            .navigationTitle("Chart Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        onEdit()
                    }
                    .foregroundColor(PluckrTheme.accent)
                }
            }
        }
        .background(PluckrTheme.background.ignoresSafeArea())
        .fullScreenCover(item: $selectedImage) { identifiableImage in
            FullScreenImageView(image: identifiableImage.image) {
                selectedImage = nil
            }
        }
    }

    // MARK: - Chart Image Gallery
    @ViewBuilder
    private var imageGallery: some View {
        if !chart.imageURLs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Chart Images")
                    .pluckrSectionHeader()
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
                                ChartImageThumbnail(
                                    url: URL(string: "")!, // dummy URL
                                    state: .failure("Invalid URL"),
                                    onTap: {}
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
        } else {
            EmptyView()
        }
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
                    .fill(PluckrTheme.card)
                    .frame(width: 80, height: 80)
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .pluckrImage()
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
