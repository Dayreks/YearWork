import Foundation


class SpeechModel: ObservableObject {
   
    struct SpeechPhrase: Identifiable {
        let text: String
        var isCompleted: Bool
        let id = UUID()
    }
    
    @Published var currentPhrase = ""
    @Published var secondsElapsed = 0
    @Published var secondsRemaining = 0
    private(set) var speechPhrases: [SpeechPhrase] = []

    private(set) var lengthInMinutes: Int
    var phraseChangedAction: (() -> Void)?

    private var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerPhrase: Int {
        (lengthInMinutes * 60) / speechPhrases.count
    }
    private var secondsElapsedForPhrase: Int = 0
    private var pharseIndex: Int = 0
    private var phraseText: String {
        return "SpeechPhrase \(pharseIndex + 1): " + speechPhrases[pharseIndex].text
    }
    private var startDate: Date?
    
    init(lengthInMinutes: Int = 0, speechPhrases: [SpeechPhrase] = []) {
        self.lengthInMinutes = lengthInMinutes
        self.speechPhrases = speechPhrases
        secondsRemaining = lengthInSeconds
        if !speechPhrases.isEmpty {
            currentPhrase = phraseText
        } else {
            currentPhrase = ""
        }
    }
    
    func startPhraseRead() {
        nextPhrase()
    }
    
    func stopPhraseRead() {
        timer?.invalidate()
        timer = nil
        timerStopped = true
    }
    
    func skipSpeechPhrase() {
        phraseChangedAction?()
        nextPhrase()
    }
    
    private func nextPhrase() {
        pharseIndex += 1
        guard pharseIndex < speechPhrases.count else {
            stopPhraseRead() // Stop the timer when there are no more phrases
            return
        }
        
        if pharseIndex > 0 {
            let previousSpeakerIndex = pharseIndex - 1
            speechPhrases[previousSpeakerIndex].isCompleted = true
        }
        
        secondsElapsedForPhrase = 0
        currentPhrase = phraseText
        
        secondsElapsed = pharseIndex * secondsPerPhrase
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            if let self = self, let startDate = self.startDate {
                let secondsElapsed = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
                self.update(secondsElapsed: Int(secondsElapsed))
            }
        }
    }

    private func update(secondsElapsed: Int) {
        secondsElapsedForPhrase = secondsElapsed
        self.secondsElapsed = secondsPerPhrase * pharseIndex + secondsElapsedForPhrase
        guard secondsElapsed <= secondsPerPhrase else {
            return
        }
        secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)

        guard !timerStopped else { return }

        if secondsElapsedForPhrase >= secondsPerPhrase {
            nextPhrase()
            phraseChangedAction?()
        }
    }
    
    func reset(lengthInMinutes: Int, speechPhrases: [SpeechPhrase]) {
        self.lengthInMinutes = lengthInMinutes
        self.speechPhrases = speechPhrases
        secondsRemaining = lengthInSeconds
        currentPhrase = phraseText
    }
    
    func calculateSpeechScore(transcribedPhrases: [String], originalPhrases: [SpeechModel.SpeechPhrase]) -> Int {
        var score = 0
        
        for transcribedPhrase in transcribedPhrases {
            if originalPhrases.contains(where: { $0.text == transcribedPhrase }) {
                score += 1
            }
        }
        
        return score
    }
}

extension SpeechModel {
    var speechModel: SpeechModel {
        SpeechModel( lengthInMinutes: SpeechResultsModel.lengthInMinutes, speechPhrases: SpeechResultsModel.speechPhrases)
    }
}
