////
////  CameraPreview.swift
////  Bebas
////
////  Created by Adya Muhammad Prawira on 10/06/25.
////
//
//import SwiftUI
//import AVFoundation
//
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator()
//    }
//
//    func makeUIView(context: Context) -> UIView {
//        let view = PreviewView()
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        view.previewLayer = previewLayer
//        view.layer.addSublayer(previewLayer)
//                
//        context.coordinator.previewLayer = previewLayer
//        
//        NotificationCenter.default.addObserver(
//            context.coordinator,
//            selector: #selector(Coordinator.orientationChanged),
//            name: UIDevice.orientationDidChangeNotification,
//            object: nil
//        )
//        
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // Called on SwiftUI updates, not orientation necessarily
//    }
//    
//    class PreviewView: UIView {
//        var previewLayer: AVCaptureVideoPreviewLayer?
//
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            previewLayer?.frame = bounds
//        }
//    }
//
//    class Coordinator: NSObject {
//        var previewLayer: AVCaptureVideoPreviewLayer?
//
//        @objc func orientationChanged() {
//            guard let connection = previewLayer?.connection else { return }
//            
//            if connection.isVideoOrientationSupported {
//                connection.videoOrientation = .portrait
////                switch UIDevice.current.orientation {
////                case .portrait:
////                    connection.videoOrientation = .portrait
////                case .landscapeRight:
////                    connection.videoOrientation = .landscapeLeft
////                case .landscapeLeft:
////                    connection.videoOrientation = .landscapeRight
////                default:
////                    break
////                }
//            }
//        }
//    }
//}




import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    class CameraPreview: UIView {
        private var previewLayer: AVCaptureVideoPreviewLayer?

        override init(frame: CGRect) {
            super.init(frame: frame)
            initializeCamera()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initializeCamera()
        }

        private func initializeCamera() {
            let session = AVCaptureSession()
            session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                return
            }

            session.addInput(input)

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspect
            previewLayer.frame = bounds
            layer.addSublayer(previewLayer)

            self.previewLayer = previewLayer
            session.startRunning()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }
    }

    func makeUIView(context: Context) -> UIView {
        return CameraPreview()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
