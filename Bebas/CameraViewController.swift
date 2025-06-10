//
//  CameraViewController.swift
//  Bebas
//
//  Created by Ashraf Alif Adillah on 10/06/25.
//

import AVFoundation
import UIKit
import Vision

enum AppError: Error {
    case camera
    case vision

    var alertDescription: String {
        switch self {
        case .camera:
            return "This device does not have a camera"
        case .vision:
            return "Vision framework is not available"
        }
    }
}

class CameraViewController: UIViewController {
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedDataOutputf", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try setupAVSession()
        } catch let error as AppError {
            showErrorAlert(error)
        } catch {
            showErrorAlert(.camera)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }

    func setupAVSession() throws {
        guard
            let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .front)
        else { throw AppError.camera }

        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.camera
        }

        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard session.canAddInput(deviceInput) else { throw AppError.camera }
        session.addInput(deviceInput)

        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(
                    kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.camera
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds

        session.commitConfiguration()
        session.startRunning()
        cameraFeedSession = session
    }

    private func showErrorAlert(_ error: AppError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
}
