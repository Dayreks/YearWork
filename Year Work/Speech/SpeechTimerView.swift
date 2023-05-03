import SwiftUI

struct SpeechTimerView: View {
    let speechPhrases: [SpeechModel.SpeechPhrase]
    let theme: Theme
    
    private var currentSpeaker: String {
        speechPhrases.first(where: { !$0.isCompleted })?.text ?? "✓"
    }
    
    var body: some View {
        Circle()
            .strokeBorder(lineWidth: 24)
            .overlay {
                VStack {
                    Text(currentSpeaker)
                        .font(.title)
                }
                .accessibilityElement(children: .combine)
                .foregroundStyle(theme.accentColor)
            }
            .overlay  {
                ForEach(speechPhrases) { phrase in
                    if phrase.isCompleted, let index = speechPhrases.firstIndex(where: { $0.id == phrase.id }) {
                        SpeakerArc(phraseIndex: index, totalPhrases: speechPhrases.count)
                            .rotation(Angle(degrees: -90))
                            .stroke(theme.mainColor, lineWidth: 12)
                    }
                }
            }
            .padding(.horizontal)
    }
}

struct SpeechTimerView_Previews: PreviewProvider {
    static var phrases: [SpeechModel.SpeechPhrase] {
        [SpeechModel.SpeechPhrase(text: "А", isCompleted: true), SpeechModel.SpeechPhrase(text: "Гав", isCompleted: false)]
    }
    
    static var previews: some View {
        SpeechTimerView(speechPhrases: phrases, theme: .bubblegum)
    }
}
