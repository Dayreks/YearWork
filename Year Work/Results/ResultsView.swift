import SwiftUI

struct ResultsView: View {
    var resultsModel: ResultsViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Text("Результати тестування")
                    .font(.system(size: 24))
                    .foregroundColor(resultsModel.model.theme.reverseAccentColor)
                    .padding([.top], 16)
                
                Text("Ваша ймовірність дислексії: ")
                    .font(.system(size: 18))
                    .foregroundColor(resultsModel.model.theme.reverseAccentColor)
                    .padding([.top, .bottom], 16)
                    .multilineTextAlignment(.center)
                switch totalScore() {
                case .high:
                    Text("Висока")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                case .medium:
                    Text("Cередня")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                    
                case .low:
                    Text("Низька")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                    
                }

                Spacer()
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ZStack(alignment: .bottom) {
                            GridBackgroundView(numberOfLines: 4, lineColor: resultsModel.model.theme.reverseAccentColor.opacity(0.2))
                            
                            HStack(alignment: .bottom, spacing: 16) {
                                ForEach(TestTask.allCases, id: \.self) { task in
                                    VStack {
                                        BarView(value: taskScore(task: task), maxValue: 100, color: resultsModel.model.theme.mainColor)
                                        Text(task.rawValue)
                                            .font(.system(size: 11))
                                            .foregroundColor(resultsModel.model.theme.reverseAccentColor)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                        }
                        .padding(.top, 24)
                    }
                    .frame(height: geometry.size.height * 0.5)
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.9)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(resultsModel.model.theme.accentColor.ignoresSafeArea())
            .navigationBarTitle("", displayMode: .inline)
        }
    }

    private func taskScore(task: TestTask) -> Double {
        return resultsModel.barTaskScore(task: task)
    }
    
    private func totalScore() -> ResultsViewModel.DyslexiaResult {
        return resultsModel.dyslexiaScoreResult()
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(resultsModel: ResultsViewModel(model: .constant(TestingModel.sampleData[0])))
    }
}
