import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var handPoints: [CGPoint]
    func makeUIViewController(context: Context) -> some UIViewController {

        let cameraViewController = CameraViewController()
        cameraViewController.onHandPointsDetected = { points in
            handPoints = points
        }
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
