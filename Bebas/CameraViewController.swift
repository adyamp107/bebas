//
//  CameraViewController.swift
//  Bebas
//
//  Created by Ashraf Alif Adillah on 10/06/25.
//

import AVFoundation
import CoreML
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
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    lazy var model: NewModel? = {
        do {
            let config = MLModelConfiguration()
            return try NewModel(configuration: config)
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }()
    var onHandPointsDetected: (([CGPoint]) -> Void)?
    var onPredictGesture: ((String) -> Void)?

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
                title: "Error", message: error.alertDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: -- Capturing Hand Points
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated public func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        let handPoseRequest = VNDetectHumanHandPoseRequest()

        let jointOrder: [VNHumanHandPoseObservation.JointName] = [
            // Thumb
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            // Index
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            // Middle
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            // Ring
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            // Little
            .littleMCP, .littlePIP, .littleDIP, .littleTip,
            // Wrist
            .wrist,
        ]

        // Ambil maksimal 2 tangan (kiri dan kanan)
        var fullHandPoints: [CGPoint] = []

        do {
            try requestHandler.perform([handPoseRequest])
            guard let observations = handPoseRequest.results else {
                DispatchQueue.main.async {
                    fullHandPoints = Array(repeating: .zero, count: 42)
                }
                return
            }

            for handIndex in 0..<2 {
                if handIndex < observations.count {
                    let hand = observations[handIndex]
                    let recognizedPoints = try hand.recognizedPoints(.all)

                    for joint in jointOrder {
                        if let point = recognizedPoints[joint], point.confidence > 0.5 {
                            let screenPoint: CGPoint
                            screenPoint = CGPoint(
                                x: (1 - point.y) * screenWidth,
                                y: point.x * screenHeight - 50
                            )
                            fullHandPoints.append(screenPoint)
                        } else {
                            fullHandPoints.append(.zero)
                        }
                    }
                } else {
                    fullHandPoints.append(contentsOf: Array(repeating: .zero, count: 21))
                }
            }

            let normalizedPoints = self.normalizeHandPoints(fullHandPoints)

            DispatchQueue.main.async {
                self.onHandPointsDetected?(fullHandPoints)
                self.predictGesture(from: normalizedPoints)
            }

        } catch {
            print("Hand tracking error: \(error)")
        }
    }

    nonisolated private func normalizeHandPoints(_ points: [CGPoint]) -> [CGPoint] {
        let validPoints = points.filter { $0 != .zero }
        guard !validPoints.isEmpty else { return points }

        let minX = validPoints.map { $0.x }.min() ?? 0
        let minY = validPoints.map { $0.y }.min() ?? 0

        return points.map { point in
            point == .zero ? .zero : CGPoint(x: point.x - minX, y: point.y - minY)
        }
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

// MARK: -- Predicting

extension CameraViewController {
    private func predictGesture(from points: [CGPoint]) {
        let inputArray = flattenPoints(points)
        //        let gestureModel = ModelHand1()

        assert(inputArray.count == 84)

        let input = NewModelInput(
            f1: inputArray[0], f2: inputArray[1], f3: inputArray[2], f4: inputArray[3],
            f5: inputArray[4], f6: inputArray[5], f7: inputArray[6], f8: inputArray[7],
            f9: inputArray[8], f10: inputArray[9], f11: inputArray[10], f12: inputArray[11],
            f13: inputArray[12], f14: inputArray[13], f15: inputArray[14], f16: inputArray[15],
            f17: inputArray[16], f18: inputArray[17], f19: inputArray[18], f20: inputArray[19],
            f21: inputArray[20], f22: inputArray[21], f23: inputArray[22], f24: inputArray[23],
            f25: inputArray[24], f26: inputArray[25], f27: inputArray[26], f28: inputArray[27],
            f29: inputArray[28], f30: inputArray[29], f31: inputArray[30], f32: inputArray[31],
            f33: inputArray[32], f34: inputArray[33], f35: inputArray[34], f36: inputArray[35],
            f37: inputArray[36], f38: inputArray[37], f39: inputArray[38], f40: inputArray[39],
            f41: inputArray[40], f42: inputArray[41], f43: inputArray[42], f44: inputArray[43],
            f45: inputArray[44], f46: inputArray[45], f47: inputArray[46], f48: inputArray[47],
            f49: inputArray[48], f50: inputArray[49], f51: inputArray[50], f52: inputArray[51],
            f53: inputArray[52], f54: inputArray[53], f55: inputArray[54], f56: inputArray[55],
            f57: inputArray[56], f58: inputArray[57], f59: inputArray[58], f60: inputArray[59],
            f61: inputArray[60], f62: inputArray[61], f63: inputArray[62], f64: inputArray[63],
            f65: inputArray[64], f66: inputArray[65], f67: inputArray[66], f68: inputArray[67],
            f69: inputArray[68], f70: inputArray[69], f71: inputArray[70], f72: inputArray[71],
            f73: inputArray[72], f74: inputArray[73], f75: inputArray[74], f76: inputArray[75],
            f77: inputArray[76], f78: inputArray[77], f79: inputArray[78], f80: inputArray[79],
            f81: inputArray[80], f82: inputArray[81], f83: inputArray[82], f84: inputArray[83]
        )

        do {
            //let result = try gestureModel.prediction(input: input)
            let result = try model?.prediction(input: input)
            self.onPredictGesture?(result?.word ?? "What?")
            print(result?.word ?? "What?")
        } catch {
            print("❌ Gagal memprediksi gesture: \(error)")
        }
    }

    private func flattenPoints(_ points: [CGPoint]) -> [Double] {
        return points.flatMap { [$0.x, $0.y] }
    }

}
