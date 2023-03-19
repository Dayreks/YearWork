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
    
    init(lengthInMinutes: Int = 0, phrases: [TestingModel.Phrase] = []) {
        self.lengthInMinutes = lengthInMinutes
        self.speechPhrases = phrases.list
        secondsRemaining = lengthInSeconds
        currentPhrase = phraseText
    }
    
    func startPhraseRead() {
        changeToPhrase(at: 0)
    }
    
    func stopPhraseRead() {
        timer?.invalidate()
        timer = nil
        timerStopped = true
    }
    
    func skipSpeechPhrase() {
        phraseChangedAction?()
        changeToPhrase(at: pharseIndex + 1)
    }

    private func changeToPhrase(at index: Int) {
        if index > 0 {
            let previousSpeakerIndex = index - 1
            speechPhrases[previousSpeakerIndex].isCompleted = true
        }
        secondsElapsedForPhrase = 0
        guard index < speechPhrases.count else { return }
        pharseIndex = index
        currentPhrase = phraseText

        secondsElapsed = index * secondsPerPhrase
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
            changeToPhrase(at: pharseIndex + 1)
            phraseChangedAction?()
        }
    }
    
    func reset(lengthInMinutes: Int, phrases: [TestingModel.Phrase]) {
        self.lengthInMinutes = lengthInMinutes
        self.speechPhrases = phrases.list
        secondsRemaining = lengthInSeconds
        currentPhrase = phraseText
    }
}

extension TestingModel {
    var speechModel: SpeechModel {
        SpeechModel(lengthInMinutes: lengthInMinutes, phrases: phrases)
    }
}

extension Array where Element == TestingModel.Phrase {
    var list: [SpeechModel.SpeechPhrase] {
        if isEmpty {
            return [SpeechModel.SpeechPhrase(text: "Phrase 1", isCompleted: false)]
        } else {
            return map { SpeechModel.SpeechPhrase(text: $0.text, isCompleted: false) }
        }
    }
}
