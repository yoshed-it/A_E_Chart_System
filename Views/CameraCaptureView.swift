import SwiftUI
import PhotosUI
import FirebaseStorage

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

func compressImage(_ image: UIImage, maxDimension: CGFloat = 1024, compression: CGFloat = 0.7) -> Data? {
    let aspectRatio = image.size.width / image.size.height
    let targetSize: CGSize

    if aspectRatio > 1 {
        targetSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
    } else {
        targetSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
    }

    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let resizedImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }

    return resizedImage.jpegData(compressionQuality: compression)
}

func uploadCompressedImage(_ image: UIImage, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
    guard let imageData = compressImage(image) else {
        completion(.failure(NSError(domain: "Image compression failed", code: -1)))
        return
    }

    let ref = Storage.storage().reference().child(path)
    ref.putData(imageData, metadata: nil) { _, error in
        if let error = error {
            completion(.failure(error))
        } else {
            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(error ?? NSError(domain: "URL fetch failed", code: -2)))
                }
            }
        }
    }
}
