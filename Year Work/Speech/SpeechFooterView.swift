import SwiftUI

struct SpeechFooterView: View {
    let secondsElapsed: Int
    let secondsRemaining: Int
    let theme: Theme
    
    private var totalSeconds: Int {
        secondsElapsed + secondsRemaining
    }
    private var progress: Double {
        guard totalSeconds > 0 else { return 1 }
        return Double(secondsElapsed) / Double(totalSeconds)
    }
    private var minutesRemaining: Int {
        secondsRemaining / 60
    }
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(CustomProgressViewStyle(theme: theme))
        }
        .accessibilityElement(children: .ignore)
        .padding([.top, .horizontal])
    }
}

struct SpeechHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechFooterView(secondsElapsed: 60, secondsRemaining: 180, theme: .bubblegum)
            .previewLayout(.sizeThatFits)
    }
}
