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
    nonisolated public func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        let jointOrder: [VNHumanHandPoseObservation.JointName] = [
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip,
            .wrist,
        ]

        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2

        var handPoints: [CGPoint] = []
        handPoints.reserveCapacity(42) // Reserve for 2 hands * 21 joints

        do {
            try handler.perform([request])
            guard let observations = request.results, !observations.isEmpty else {
                handPoints = Array(repeating: .zero, count: 42)
                Task { @MainActor in
                    self.onHandPointsDetected?(handPoints)
                }
                return
            }

            // File: HandTrackingProcessor.swift

            for handIndex in 0..<2 {
                guard handIndex < observations.count else {
                    handPoints.append(contentsOf: Array(repeating: .zero, count: 21))
                    continue
                }

                let hand = observations[handIndex]
                guard let recognizedPoints = try? hand.recognizedPoints(.all) else {
                    handPoints.append(contentsOf: Array(repeating: .zero, count: 21))
                    continue
                }

                for joint in jointOrder {
                    guard let point = recognizedPoints[joint], point.confidence > 0.5 else {
                        handPoints.append(.zero)
                        continue
                    }

                    Task { @MainActor in
                        handPoints.append(convertHandPoints(point))
                    }
                }
            }
            
            Task { @MainActor in
                self.onHandPointsDetected?(handPoints)
            }
        } catch {
            Task { @MainActor in
                showErrorAlert(.vision)
            }
        }
    }

    // Convert Vision coordinate system to SwiftUI coordinate system
    private func convertHandPoints(_ point: VNRecognizedPoint) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        return CGPoint(x: (1 - point.y) * screenSize.width, y: (point.x) * screenSize.height)
    }

    /** Method ini harusnya untuk memastikan kalau tangan kiri itu selalu di awal
    daripada array nya. Pada penulisan comment ini, aku gatau perlu dipakai atau tidak **/
    private func sortHandsByXPosition(_ observations: [VNHumanHandPoseObservation])
        -> [VNHumanHandPoseObservation]
    {
        guard observations.count == 2,
            let wrist1 = try? observations[0].recognizedPoint(.wrist),
            let wrist2 = try? observations[1].recognizedPoint(.wrist)
        else {
            return observations
        }
        return wrist1.location.x < wrist2.location.x
            ? observations : [observations[1], observations[0]]
    }

}
