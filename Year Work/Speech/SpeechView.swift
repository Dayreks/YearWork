import SwiftUI
import AVFoundation

struct SpeechView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var model: TestingModel
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
                        model.markCompleted(task: .speech)
                        presentationMode.wrappedValue.dismiss()
                    })
                SpeechTimerView(speechPhrases: speechModel.speechPhrases, theme: model.theme)
                SpeechFooterView(secondsElapsed: speechModel.secondsElapsed, secondsRemaining: speechModel.secondsRemaining, theme: model.theme)
            }
            .padding([.top, .bottom], 48)
            .padding([.leading, .trailing], 16)
        }
        .foregroundColor(model.theme.accentColor)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("You have completed this part already"),
                dismissButton: .default(Text("Ok")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            if model.completedTasks.contains(.speech) {
                showAlert = true
            } else {
                speechModel.reset(lengthInMinutes: model.lengthInMinutes, phrases: model.phrases)
                speechRecognizer.reset()
                speechRecognizer.transcribe()
                isRecording = true
                speechModel.startPhraseRead()
                
                speechModel.phraseChangedAction = {
                    speechRecognizer.stopTranscribing()
                    model.transcribedPhrases.append(speechRecognizer.transcript)
                    speechRecognizer.transcribe()
                }
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
