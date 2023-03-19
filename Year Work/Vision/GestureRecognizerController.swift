//
//  HandGestureRecognizer.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 29.01.2023.
//

import UIKit
import AVFoundation
import Vision

class GestureRecognizerController: UIViewController {
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handGestureProcessor = HandGestureProcessor()
    
    private weak var emojiView: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
        prepareCaptureUI()
        prepareEmojiView()
        
        // The default value for this property is 2.
        handPoseRequest.maximumHandCount = 1
    }
    
    private func prepareCaptureSession() {
        let captureSession = AVCaptureSession()
        
        // Select a front facing camera, make an input.
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .main)
        captureSession.addOutput(output)
        
        self.captureSession = captureSession
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    private func prepareCaptureUI() {
        guard let session = captureSession else { return }
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        self.videoPreviewLayer = videoPreviewLayer
    }
    
    private func prepareEmojiView() {
        let emojiView = UILabel()
        emojiView.frame = self.view.bounds
        emojiView.textAlignment = .center
        emojiView.font = UIFont.systemFont(ofSize: 300)
        view.addSubview(emojiView)
        
        self.emojiView = emojiView
    }
}

extension GestureRecognizerController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                emojiView?.text = ""
                return
            }
            // Get points for thumb and index finger.
            let handPoints = try observation.recognizedPoints(.all)
            
            // Look for tip points.
            guard let thumbTipPoint = handPoints[.thumbTip],
                  let indexTipPoint = handPoints[.indexTip],
                  let middleTipPoint = handPoints[.middleTip],
                  let ringTipPoint = handPoints[.ringTip],
                  let littleTipPoint = handPoints[.littleTip],
                  let wristPoint = handPoints[.wrist]
            else { return }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 && middleTipPoint.confidence > 0.3, ringTipPoint.confidence > 0.3 && littleTipPoint.confidence > 0.3, wristPoint.confidence > 0.3 else {
                emojiView?.text = ""
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            DispatchQueue.main.async {
                self.processPoints(
                    thumbTipPoint: thumbTipPoint,
                    indexTipPoint: indexTipPoint,
                    middleTipPoint: middleTipPoint,
                    ringTipPoint: ringTipPoint,
                    littleTipPoint: littleTipPoint,
                    wristPoint: wristPoint
                )
            }
        } catch {
            print(error)
        }
    }
    
    private func processPoints(
        thumbTipPoint: VNRecognizedPoint,
        indexTipPoint: VNRecognizedPoint,
        middleTipPoint: VNRecognizedPoint,
        ringTipPoint: VNRecognizedPoint,
        littleTipPoint: VNRecognizedPoint,
        wristPoint: VNRecognizedPoint
    ) {
        // Convert points from Vision coordinates to AVFoundation coordinates.
        let thumbTipCGPoint = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
        let indexTipCGPoint = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        let middleTipCGPoint = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
        let ringTipCGPoint = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
        let littleTipCGPoint = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
        let wristCGPoint = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        guard let thumbTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: thumbTipCGPoint),
              let indexTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: indexTipCGPoint),
              let middleTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: middleTipCGPoint),
              let ringTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: ringTipCGPoint),
              let littleTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: littleTipCGPoint),
              let wristConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: wristCGPoint)
        else {
            emojiView?.text = "😱"
            return
        }
        
        let state = handGestureProcessor.getHandGesture(
            thumbTip: thumbTipConvertedPoint,
            indexTip: indexTipConvertedPoint,
            middleTip: middleTipConvertedPoint,
            ringTip: ringTipConvertedPoint,
            littleTip: littleTipConvertedPoint,
            wrist: wristConvertedPoint)
        
        switch state {
        case .thumbUp:
            emojiView?.text = "👍"
        case .thumbDown:
            emojiView?.text = "👎"
        case .vSign:
            emojiView?.text = "✌️"
        case .highFive:
            emojiView?.text = "🖐️"
        case .empty:
            emojiView?.text = ""
        }
        
        ///Debug
//    
//        print("1. Vision Coordinates: \(thumbTipPoint)")
//        print("2. AVFoundation coordinates: \(thumbTipCGPoint)")
//        print("3. UIKit coordinates: \(thumbTipConvertedPoint)")
//        print(state)
    }
}

