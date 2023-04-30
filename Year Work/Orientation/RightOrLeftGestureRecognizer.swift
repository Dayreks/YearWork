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
    
    enum ScreenSide {
        case left
        case right
    }
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handGestureProcessor = HandSideProcessor()
    
    private weak var scoreLabel: UILabel?
    private weak var sideLabel: UILabel?
    
    private weak var instructionView: UIView?
    
    private var isGameEnded = false
    private var isInstructionViewShown = false
    private var currentRound = 1
    private var maxRounds = 10
    private var roundDuration: TimeInterval = 3
    private var currentScore = 0
    private var roundTimer: Timer?
    
    private var currentSide: ScreenSide = .left
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
        prepareCaptureUI()
        prepareScoreLabel()
        prepareSideLabel()
        prepareInstructionView()
        
        handPoseRequest.maximumHandCount = 1
        
        startRound()
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
    
    private func prepareScoreLabel() {
        let scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: 0, y: 50, width: view.bounds.width, height: 40)
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.text = "Рахунок: 0"
        view.addSubview(scoreLabel)
        
        self.scoreLabel = scoreLabel
    }
    
    private func prepareSideLabel() {
        let sideLabel = UILabel()
        sideLabel.frame = CGRect(x: 0, y: (view.bounds.height / 2) - 20, width: view.bounds.width, height: 40)
        sideLabel.textAlignment = .center
        sideLabel.font = UIFont.systemFont(ofSize: 24)
        sideLabel.alpha = 0
        view.addSubview(sideLabel)
        
        self.sideLabel = sideLabel
    }

    
    private func prepareInstructionView() {
        // Create a view for the left side with a translucent black background
        let leftInstructionView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width / 2, height: view.bounds.height))
        leftInstructionView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.addSubview(leftInstructionView)
        
        // Create a view for the right side with a translucent black background
        let rightInstructionView = UIView(frame: CGRect(x: view.bounds.width / 2, y: 0, width: view.bounds.width / 2, height: view.bounds.height))
        rightInstructionView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.addSubview(rightInstructionView)
        
        self.instructionView = leftInstructionView
        
        // Hide the instruction views initially
        leftInstructionView.alpha = 0
        rightInstructionView.alpha = 0
    }
    
    private func startRound() {
        if currentRound <= maxRounds {
            setRandomSide()
            
            isInstructionViewShown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                self.showInstructionView {
                    self.hideInstructionView {
                        self.startRoundTimer()
                        self.isInstructionViewShown = false
                    }
                }
            }
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
            currentRound += 1
            startRound()
        }
    }
    
    private func endGame() {
        isGameEnded = true
        
        let alertController = UIAlertController(
            title: "Вітання!",
            message: "Ви успішно завершили цю частину",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func setRandomSide() {
        currentSide = Int.random(in: 0...2) == 0 ? .left : .right
        
        switch currentSide {
        case .left:
            instructionView?.frame.origin.x = 0
        case .right:
            instructionView?.frame.origin.x = view.bounds.width / 2
        }
    }
    
    private func applyTransition(to view: UIView, fadeIn: Bool, duration: TimeInterval) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        view.layer.add(transition, forKey: fadeIn ? "fadeIn" : "fadeOut")
        view.alpha = fadeIn ? 1 : 0
    }

    
    private func showInstructionView(completion: @escaping () -> Void) {
        instructionView?.alpha = 0
        sideLabel?.alpha = 0
        sideLabel?.text = currentSide == .left ? "Ліва" : "Права"
        
        applyTransition(to: instructionView!, fadeIn: true, duration: 0.8)
        applyTransition(to: sideLabel!, fadeIn: true, duration: 0.8)
        
        instructionView?.superview?.subviews.forEach { view in
            if view != self.instructionView && view != self.scoreLabel && view != self.sideLabel {
                applyTransition(to: view, fadeIn: false, duration: 0.8)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            completion()
        }
    }

    private func hideInstructionView(completion: @escaping () -> Void) {
        applyTransition(to: instructionView!, fadeIn: false, duration: 0.8)
        applyTransition(to: sideLabel!, fadeIn: false, duration: 0.8)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            completion()
        }
    }

}

extension RightOrLeftGestureRecognizerController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        
        guard !isGameEnded, !isInstructionViewShown else { return }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
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
                return
            }
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
            return
        }
        
        let state = handGestureProcessor.getHandGesture(
            thumbTip: thumbTipConvertedPoint,
            littleTip: littleTipConvertedPoint
        )
        
        switch state {
        case .leftHand:
            updateScore(correct: currentSide == .left)
        case .rightHand:
            updateScore(correct: currentSide == .right)
        }
        
        scoreLabel?.text = "Рахунок: \(currentScore)"
    }
}
