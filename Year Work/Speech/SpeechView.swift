import SwiftUI
import AVFoundation

struct SpeechView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var model: TestingModel
    @StateObject var speechResultsModel = SpeechResultsModel()
    @StateObject var speechModel = SpeechModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            model.theme.mainColor
                .ignoresSafeArea()
            VStack {
                SpeechHeaderView(
                    phrases: speechModel.speechPhrases,
                    skipAction: speechModel.skipSpeechPhrase,
                    completedAction: {
                        model.markCompleted(task: .speech, score: speechResultsModel.correctScore, transcribedPhrases: speechResultsModel.transcribedResults)
                        presentationMode.wrappedValue.dismiss()
                    })
                SpeechTimerView(speechPhrases: speechModel.speechPhrases, theme: model.theme)
                SpeechFooterView(secondsElapsed: speechModel.secondsElapsed, secondsRemaining: speechModel.secondsRemaining, theme: model.theme)
            }
            .padding([.top, .bottom], 48)
            .padding([.leading, .trailing], 16)
        }
        .foregroundColor(model.theme.accentColor)
        .onAppear {
            model.fetchCompletedTasks()
            speechModel.reset(lengthInMinutes: SpeechResultsModel.lengthInMinutes, speechPhrases: SpeechResultsModel.speechPhrases)
            speechRecognizer.reset()
            speechRecognizer.transcribeUntilWordRecognized()
            isRecording = true
            speechModel.startPhraseRead()
            
            speechModel.phraseChangedAction = {
                speechRecognizer.stopTranscribing()
                speechResultsModel.storeTranscribedResult(speechRecognizer.transcript)
                speechModel.startPhraseRead()
                speechRecognizer.transcribeUntilWordRecognized()
            }
        }
        .onDisappear {
            speechModel.stopPhraseRead()
            speechRecognizer.stopTranscribing()
            isRecording = false
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechView(model: .constant(TestingModel.sampleData[0]))
    }
}
