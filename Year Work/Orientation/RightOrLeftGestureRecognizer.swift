//
//  RightOrLeftGestureRecognizer.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import UIKit
import SwiftUI
import AVFoundation
import Vision

class RightOrLeftGestureRecognizerController: UIViewController {
    
    enum ScreenSide {
        case left
        case right
    }
    
    @Binding var model: TestingModel
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var lastProcessingTime: TimeInterval = 0
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handGestureProcessor = HandSideProcessor()
    
    private weak var instructionView: UIView?
    private weak var rightInstructionView: UIView?
    private weak var leftInstructionView: UIView?
    
    private var isGameEnded = false
    private var isInstructionViewShown = false
    private var currentRound = 1
    private var maxRounds = 10
    private var roundDuration: TimeInterval = 3
    private var currentScore = 0
    private var roundTimer: Timer?
    
    private var currentSide: ScreenSide = .left
    
    init(model: Binding<TestingModel>) {
        _model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
        prepareCaptureUI()
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
    
    private func prepareInstructionView() {
        // Create a view for the left side with a translucent black background
        let leftInstructionView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width / 2, height: view.bounds.height))
        leftInstructionView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        let leftSideLabel = UILabel()
        leftSideLabel.frame = CGRect(x: 0, y: (view.bounds.height / 2) - 20, width: view.bounds.width / 2, height: 40)
        leftSideLabel.center.y = leftInstructionView.center.y
        leftSideLabel.textAlignment = .center
        leftSideLabel.font = UIFont.systemFont(ofSize: 24)
        leftSideLabel.text = "Ліва"
        leftInstructionView.addSubview(leftSideLabel)
        
        view.addSubview(leftInstructionView)

        // Create a view for the right side with a translucent black background
        let rightInstructionView = UIView(frame: CGRect(x: view.bounds.width / 2, y: 0, width: view.bounds.width / 2, height: view.bounds.height))
        rightInstructionView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        let rightSideLabel = UILabel()
        rightSideLabel.frame = CGRect(x: 0, y: (view.bounds.height / 2) - 20, width: view.bounds.width / 2, height: 40)
        rightSideLabel.center.y = rightInstructionView.center.y
        rightSideLabel.textAlignment = .center
        rightSideLabel.font = UIFont.systemFont(ofSize: 24)
        rightSideLabel.text = "Права"
        rightInstructionView.addSubview(rightSideLabel)
        
        view.addSubview(rightInstructionView)
        
        self.rightInstructionView = rightInstructionView
        self.leftInstructionView = leftInstructionView
        
        // Hide the instruction views initially
        leftInstructionView.alpha = 0
        rightInstructionView.alpha = 0
    }
    
    private func startRound() {
        if currentRound <= maxRounds {
            setRandomSide()
            
            isInstructionViewShown = true
            showInstructionView {  [weak self] in
                self?.hideInstructionView {
                    self?.startRoundTimer()
                    self?.isInstructionViewShown = false
                }
            }
        } else {
            endGame()
        }
    }
    
    private func startRoundTimer() {
        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: roundDuration, repeats: false) {  [weak self]  _ in
            self?.currentRound += 1
            self?.startRound()
        }
    }
    
    private func updateScore(correct: Bool) {
        if correct {
            currentScore += 1
        }
        currentRound += 1
        startRound()
    }
    
    private func endGame() {
        isGameEnded = true
        
        let alertController = UIAlertController(
            title: "Вітання!",
            message: "Ви успішно завершили цю частину",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) {  [weak self]  _ in
            self?.model.markCompleted(task: .orientation, score: self?.currentScore ?? 0)
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func setRandomSide() {
        currentSide = Int.random(in: 0...2) == 0 ? .left : .right
        
        switch currentSide {
        case .left:
            instructionView = leftInstructionView
        case .right:
            instructionView = rightInstructionView
        }
    }
    
    private func applyTransition(to view: UIView, fadeIn: Bool, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            view.alpha = fadeIn ? 1 : 0
        }, completion: completion)
    }

    private func showInstructionView(completion: @escaping () -> Void) {
        applyTransition(to: instructionView!, fadeIn: true, duration: 0.8){ _ in
            completion()
        }
    }

    private func hideInstructionView(completion: @escaping () -> Void) {
        applyTransition(to: instructionView!, fadeIn: false, duration: 0.8){ _ in
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
        let currentTime = Date().timeIntervalSinceReferenceDate
        if currentTime - lastProcessingTime >= 1.6, !isInstructionViewShown {
            guard !isGameEnded else { return }
            
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
            
            lastProcessingTime = currentTime
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
    }
}
