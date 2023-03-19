//
//  NumbersView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 19.03.2023.
//

import SwiftUI

struct NumbersView: View {
    @Binding var model: TestingModel
    
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var round: Int = 1
    @State private var showingAlert: Bool = false
    @State var playing = false
    @State var firstBright = false
    
    let maxRounds = 7
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Round: \(round)")
                .font(.largeTitle)
            Spacer()
            
            Text("Sequence: \(userSequence.map { String($0) }.joined(separator: ""))")
                .font(.title)
            
            VStack {
                ForEach(0..<3) { row in
                    HStack {
                        ForEach(0..<3) { col in
                            TileView(color: model.theme.mainColor, bright: $firstBright)
                                .overlay(content: {
                                    Text("\(row * 3 + col + 1)")
                                        .font(.largeTitle)
                                        .foregroundColor(model.theme.accentColor)
                                })
                                .onTapGesture {
                                    
                                    numberTapped(number: row * 3 + col + 1)
                                    
                                }
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                startRound()
            } label: {
                Text("Start")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .offset(y: playing ? 200 : -80.0)
            .disabled(playing)
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("You made it to round \(round)"),
                dismissButton: .default(Text("Retry"), action: {
                    resetGame()
                })
            )
        }
    }
    
    func startRound() -> Void {
        playing = true
        
        userSequence.append(Int.random(in: 1...4))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
        }
    }
    
    private func numberTapped(number: Int) {
        userSequence.append(number)
        
        if userSequence.count == sequence.count {
            if userSequence == sequence {
                if round < maxRounds {
                    round += 1
                    nextRound()
                } else {
                    showingAlert = true
                }
            } else {
                showingAlert = true
            }
        }
    }
    
    private func nextRound() {
        userSequence.removeAll()
        sequence = (0..<round).map { _ in Int.random(in: 1...9) }
    }
    
    private func resetGame() {
        round = 1
        nextRound()
    }
}

struct NumbersView_Previews: PreviewProvider {
    static var previews: some View {
        NumbersView(model: .constant(TestingModel.sampleData[0]))
    }
}

