import SwiftUI

struct SpeechHeaderView: View {
    let phrases: [SpeechModel.SpeechPhrase]
    var skipAction: ()->Void
    var completedAction: () -> Void
    
    private var phraseNumber: Int? {
        guard let index = phrases.firstIndex(where: { !$0.isCompleted }) else { return nil}
        return index + 1
    }
    private var isLastSpeaker: Bool {
        return phrases.dropLast().allSatisfy { $0.isCompleted }
    }
    private var speakerText: String {
        guard let phraseNumber = phraseNumber else { return "No more phrases" }
        return "Phrase \(phraseNumber) of \(phrases.count)"
    }
    
    var body: some View {
        VStack {
            HStack {
                if isLastSpeaker {
                    Text("Continue")
                    Spacer()
                    Button(action: completedAction) {
                        Image(systemName: "forward.fill")
                    }
                } else {
                    Text(speakerText)
                    Spacer()
                    Button(action: skipAction) {
                        Image(systemName: "forward.fill")
                    }
                    .accessibilityLabel("Next Phrase")
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
}

struct SpeechFooterView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechHeaderView(phrases: TestingModel.sampleData[0].phrases.list, skipAction: {}, completedAction: {})
            .previewLayout(.sizeThatFits)
    }
}
