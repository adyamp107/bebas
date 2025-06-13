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
    case tracking

    var alertDescription: String {
        switch self {
        case .camera:
            return "This device does not have a camera"
        case .vision:
            return "Vision framework is not available"
        case .tracking:
            return "Hand tracking error"
        }
    }
}

class CameraViewController: UIViewController {
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    var onHandPointsDetected: (([CGPoint]) -> Void)?

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
        previewLayer.videoGravity = .resizeAspect
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
    nonisolated public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handJoints: [VNHumanHandPoseObservation.JointName] = [
            .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        // handPoseRequest.maximumHandCount = 2

        do {
            try handler.perform([handPoseRequest])
            guard let observations = handPoseRequest.results, !observations.isEmpty else { return }
            
            var rightHandPoints: [CGPoint] = []
            var leftHandPoints: [CGPoint] = []

            for observation in observations {
                var visionHandPoints: [CGPoint] = []

                for joint in handJoints {
                    if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.3 {
                        visionHandPoints.append(recognizedPoint.location)
                    }
                }

                switch observation.chirality {
                case .right:
                    rightHandPoints = visionHandPoints
                case .left:
                    leftHandPoints = visionHandPoints
                default:
                    break
                }
            }

            DispatchQueue.main.async {
                let convertedRightHandPoints = rightHandPoints.map { self.convertHandPoints($0) }
                let convertedLeftHandPoints = leftHandPoints.map { self.convertHandPoints($0) }

                // Concatenate both hands' points into a single array
                let allHandPoints = convertedRightHandPoints + convertedLeftHandPoints

                print("Total Hand Points: \(allHandPoints.count)")

                // Trigger handler with combined points
                self.onHandPointsDetected?(allHandPoints)
            }

        } catch {
            DispatchQueue.main.async {
                self.showErrorAlert(.vision)
            }
            print("Hand tracking failed: \(error)")
        }
    }
    
    // Convert Vision coordinate system to SwiftUI coordinate system
    @MainActor
    private func convertHandPoints(_ point: CGPoint) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        return CGPoint(x: (1 - point.y) * screenSize.width, y: (point.x) * screenSize.height)
    }
}
