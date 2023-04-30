import SwiftUI

struct NumbersView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var model: TestingModel
    
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var round: Int = 1
    @State private var showingAlert: Bool = false
    @State private var isShowingDigits: Bool = false
    @State private var showStartButton: Bool = true
    @State private var correctCount: Int = 0
    @State private var brightTiles: [Bool] = Array(repeating: false, count: 9)
    
    let maxRounds = 1
    let digitDisplayTime: TimeInterval = 2
    let tileHighlightDuration: TimeInterval = 0.1
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Раунд: \(round)")
                .font(.largeTitle)
            Spacer()

            if isShowingDigits {
                Text(sequence.map { String($0) }.joined(separator: ""))
                    .font(.largeTitle)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + digitDisplayTime) {
                            isShowingDigits = false
                        }
                    }
            }
            
            if !isShowingDigits {
                VStack {
                    ForEach(0..<3) { row in
                        HStack {
                            ForEach(0..<3) { col in
                                let index = row * 3 + col
                                TileView(color: model.theme.mainColor, bright: $brightTiles[index])
                                    .overlay(content: {
                                        Text("\(row * 3 + col + 1)")
                                            .font(.title)
                                            .foregroundColor(model.theme.accentColor)
                                    })
                                    .onTapGesture {
                                        if !isShowingDigits {
                                            numberTapped(number: row * 3 + col + 1)
                                        }
                                    }
                            }
                        }
                    }
                }
                .disabled(isShowingDigits)
            }

            Spacer()
            
            Button {
                startRound()
            } label: {
                Text("Старт")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .offset(y: !showStartButton ? 200 : -80.0)
            .disabled(!showStartButton)
            .transition(.move(edge: .bottom))
            
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Тест завершено"),
                message: Text("You made it to round \(round) with a score of \(correctCount)"),
                dismissButton: .default(Text("Продовжити"), action: {
                    resetGame()
                    presentationMode.wrappedValue.dismiss()
                })
            )
        }
    }
    
    func startRound() -> Void {
        userSequence.removeAll()
        sequence.append(Int.random(in: 1...9))
        isShowingDigits = true
        showStartButton = false
    }

    
    private func numberTapped(number: Int) {
        userSequence.append(number)
        brightTiles[number - 1] = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + tileHighlightDuration) {
            brightTiles[number - 1] = false
        }
        
        if userSequence.count == sequence.count {
            if userSequence == sequence {
                correctCount += 1
                
                if round < maxRounds {
                    round += 1
                    startRound()
                } else {
                    showingAlert = true
                }
            } else {
                round += 1
                if round <= maxRounds {
                    startRound()
                } else {
                    showingAlert = true
                }
            }
        }
    }
    
    private func resetGame() {
        round = 1
        correctCount = 0
        sequence.removeAll()
        userSequence.removeAll()
        showStartButton = true
    }

}

struct NumbersView_Previews: PreviewProvider {
    static var previews: some View {
        NumbersView(model: .constant(TestingModel.sampleData[0]))
    }
}
