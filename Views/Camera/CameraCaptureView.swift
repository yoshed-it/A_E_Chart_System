import SwiftUI
import UIKit

/// HIPAA-SAFE: This view captures images directly from the camera and never saves to Photos.
/// In the simulator, a placeholder image is used for dev testing.
struct CameraCaptureView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        #if targetEnvironment(simulator)
        // Simulator fallback: show a dummy image for dev testing
        let vc = UIViewController()
        let image = UIImage(systemName: "photo")!.withTintColor(.gray, renderingMode: .alwaysOriginal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PluckrLogger.info("Simulator: Using placeholder image for camera capture (HIPAA-safe, not saved to Photos)")
            onImageCaptured(image)
        }
        return vc
        #else
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        // HIPAA: Do NOT save to Photos. No call to UIImageWriteToSavedPhotosAlbum.
        PluckrLogger.info("CameraCaptureView: Presenting camera for image capture (HIPAA-safe)")
        return picker
        #endif
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImageCaptured: (UIImage) -> Void

        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                PluckrLogger.info("CameraCaptureView: Image captured (HIPAA-safe, not saved to Photos)")
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
