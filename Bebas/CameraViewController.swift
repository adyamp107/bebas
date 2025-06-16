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
    nonisolated public func captureOutput(
        _ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let handJoints: [VNHumanHandPoseObservation.JointName] = [
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

        Task {  // allow async context
            var allHandPoints: [CGPoint] = []

            do {
                try handler.perform([request])
                guard let observations = request.results, !observations.isEmpty else {
                    allHandPoints = Array(repeating: .zero, count: 42)
                    return
                }

                let screenSize = await MainActor.run {
                    UIScreen.main.bounds.size
                }

                for index in 0..<2 {
                    guard index < observations.count else {
                        allHandPoints.append(contentsOf: Array(repeating: .zero, count: 21))
                        continue
                    }

                    let hand = observations[index]
                    let recognizedPoints = try hand.recognizedPoints(.all)

                    for joint in handJoints {
                        guard let point = recognizedPoints[joint], point.confidence > 0.85 else {
                            allHandPoints.append(.zero)
                            continue
                        }

                        let screenPoint = await MainActor.run {
                            self.convertHandPoints(point, screenSize: screenSize)
                        }

                        allHandPoints.append(screenPoint)
                    }
                }

                let normalizedPoints = await self.normalizeHandPoints(allHandPoints)

                await MainActor.run {
                    self.onHandPointsDetected?(normalizedPoints)
                }

            } catch {
                await MainActor.run {
                    self.showErrorAlert(.tracking)
                }
            }
        }
    }

    @MainActor
    private func convertHandPoints(_ point: VNRecognizedPoint, screenSize: CGSize) -> CGPoint {
        return CGPoint(x: (1 - point.y) * screenSize.width, y: point.x * screenSize.height - 50)
    }

    private func normalizeHandPoints(_ points: [CGPoint]) -> [CGPoint] {

        let validPoints = points.filter { $0 != .zero }
        guard !validPoints.isEmpty else { return points }

        let minX = validPoints.map { $0.x }.min() ?? 0
        let minY = validPoints.map { $0.y }.min() ?? 0

        return points.map { point in
            point == .zero ? .zero : CGPoint(x: point.x - minX, y: point.y - minY)
        }

    }
}
