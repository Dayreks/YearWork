//
//  HandGestureRecognizer.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 29.01.2023.
//

import UIKit
import SwiftUI
import AVFoundation
import Vision

class GestureRecognizerController: UIViewController {
    
    @Binding var model: TestingModel

    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handGestureProcessor = HandGestureProcessor()
    
    private weak var proposedGestureLabel: UILabel?
    private weak var instructionsView: UIView?
    
    private var proposedGesture: HandGestureProcessor.HandGesture = .empty
    private var totalRounds: Int = 10
    private var currentScore: Int = 0
    private var countdownTimer: Timer?
    private var remainingTime: Int = 5
    
    private var isGameEnded = false
    private var isResultsOfRoundShown = false
    
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
        prepareProposedGestureLabel()
        prepareInstructionsView()
        proposeRandomGesture()
        
        // The default value for this property is 2.
        handPoseRequest.maximumHandCount = 1
        
        startCountdownTimer()
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
    
    
    private func prepareProposedGestureLabel() {
        let proposedGestureLabel = UILabel()
        proposedGestureLabel.translatesAutoresizingMaskIntoConstraints = false
        proposedGestureLabel.font = UIFont.systemFont(ofSize: 24)
        proposedGestureLabel.textColor = .white
        view.addSubview(proposedGestureLabel)
        
        NSLayoutConstraint.activate([
            proposedGestureLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            proposedGestureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        self.proposedGestureLabel = proposedGestureLabel
    }
    
    private func proposeRandomGesture() {
        let gestures: [HandGestureProcessor.HandGesture] = [.highFive, .thumbDown, .thumbUp, .vSign]
        
        proposedGesture = gestures.randomElement() ?? .highFive
        proposedGestureLabel?.text = "Покажи: \(proposedGesture.rawValue)"
    }
    
    private func startCountdownTimer() {
        countdownTimer?.invalidate()
        remainingTime = 5
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.remainingTime -= 1
            
            if self?.remainingTime == 0 {
                self?.countdownTimer?.invalidate()
                self?.nextRound()
            }
        }
    }
    
    private func nextRound() {
        totalRounds -= 1
        if totalRounds == 0 {
            gameOver()
        } else {
            startCountdownTimer()
            proposeRandomGesture()
        }
    }
    
    private func gameOver() {
        // Handle the game over scenario, e.g., present an alert or navigate to another screen
        isGameEnded = true
        
        let alertController = UIAlertController(
            title: "Вітання!",
            message: "Ви успішно завершили цю частину",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) {  [weak self]  _ in
            self?.model.markCompleted(task: .vision, score: self?.currentScore ?? 0, transcribedPhrases: nil)
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func prepareInstructionsView() {
        let instructionsView = UIView()
        // Customize your instructions view here
        self.instructionsView = instructionsView
        view.addSubview(instructionsView)
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
            guard !isGameEnded, !isResultsOfRoundShown else { return }
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
                  let indexTipPoint = handPoints[.indexTip],
                  let middleTipPoint = handPoints[.middleTip],
                  let ringTipPoint = handPoints[.ringTip],
                  let littleTipPoint = handPoints[.littleTip],
                  let wristPoint = handPoints[.wrist]
            else { return }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 && middleTipPoint.confidence > 0.3, ringTipPoint.confidence > 0.3 && littleTipPoint.confidence > 0.3, wristPoint.confidence > 0.3 else {
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
            return
        }
        
        let state = handGestureProcessor.getHandGesture(
            thumbTip: thumbTipConvertedPoint,
            indexTip: indexTipConvertedPoint,
            middleTip: middleTipConvertedPoint,
            ringTip: ringTipConvertedPoint,
            littleTip: littleTipConvertedPoint,
            wrist: wristConvertedPoint)
        
        isResultsOfRoundShown = true
        
        if state == proposedGesture {
            currentScore += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                self.nextRound()
                self.isResultsOfRoundShown = false
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                self.nextRound()
                self.isResultsOfRoundShown = false
            }
        }
    }
}
