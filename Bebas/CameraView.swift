import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var handPoints: [CGPoint]
    @Binding var predictedString: String

    func makeUIViewController(context: Context) -> some UIViewController {

        let cameraViewController = CameraViewController()
        cameraViewController.onHandPointsDetected = { points in
            handPoints = points
        }

        cameraViewController.onPredictGesture = { prediction in
            predictedString = prediction
        }
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
