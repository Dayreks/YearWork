//
//  RightOrLeftGestureRecognizer.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import UIKit
import AVFoundation
import Vision

class RightOrLeftGestureRecognizerController: UIViewController {
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handGestureProcessor = HandSideProcessor()
    
    private weak var emojiView: UILabel?
    private weak var scoreLabel: UILabel?
    private weak var sideLabel: UILabel?
    
    private var currentRound = 1
    private var maxRounds = 5
    private var roundDuration: TimeInterval = 10
    private var currentScore = 0
    private var roundTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
        prepareCaptureUI()
        prepareEmojiView()
        prepareScoreLabel()
        prepareSideLabel()
        
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
    
    private func prepareScoreLabel() {
        let scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: 0, y: 50, width: view.bounds.width, height: 40)
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        self.scoreLabel = scoreLabel
    }
    
    private func prepareSideLabel() {
        let sideLabel = UILabel()
        sideLabel.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 40)
        sideLabel.textAlignment = .center
        sideLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(sideLabel)
        
        self.sideLabel = sideLabel
    }
    
    private func startRound() {
        if currentRound <= maxRounds {
            setRandomSide()
            startRoundTimer()
        } else {
            endGame()
        }
    }

    private func startRoundTimer() {
        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: roundDuration, repeats: false) { _ in
            self.currentRound += 1
            self.startRound()
        }
    }

    private func updateScore(correct: Bool) {
        if correct {
            currentScore += 1
        }
    }

    private func endGame() {
        // Handle end of the game (e.g., show final score or reset game)
    }

    private func setRandomSide() {
        // Set the side of the screen (left or right) that the user should show their hand on
    }
}

extension RightOrLeftGestureRecognizerController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
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
                  let littleTipPoint = handPoints[.littleTip]
            else { return }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3, littleTipPoint.confidence > 0.3 else {
                emojiView?.text = ""
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            DispatchQueue.main.async {
                self.processPoints(
                    thumbTipPoint: thumbTipPoint,
                    littleTipPoint: littleTipPoint
                )
            }
        } catch {
            print(error)
        }
    }
    
    private func processPoints(
        thumbTipPoint: VNRecognizedPoint,
        littleTipPoint: VNRecognizedPoint
    ) {
        // Convert points from Vision coordinates to AVFoundation coordinates.
        let thumbTipCGPoint = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
        let littleTipCGPoint = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        guard let thumbTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: thumbTipCGPoint),
              let littleTipConvertedPoint = videoPreviewLayer?.layerPointConverted(fromCaptureDevicePoint: littleTipCGPoint)
        else {
            emojiView?.text = "😱"
            return
        }
        
        let state = handGestureProcessor.getHandGesture(
            thumbTip: thumbTipConvertedPoint,
            littleTip: littleTipConvertedPoint
        )
        
        switch state {
        case .leftHand:
            emojiView?.text = "✋"
        case .rightHand:
            emojiView?.text = "🤚"
        }
        
        ///Debug
//
//        print("1. Vision Coordinates: \(thumbTipPoint)")
//        print("2. AVFoundation coordinates: \(thumbTipCGPoint)")
//        print("3. UIKit coordinates: \(thumbTipConvertedPoint)")
//        print(state)
    }
}
