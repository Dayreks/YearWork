//
//  GameView.swift
//  Year Work
//
//  Created by Bohdan on 11.01.2023.
//

import SwiftUI
import AVFoundation

struct RythmsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var model: TestingModel
    @State var points: Int = 0
    
    @State var sequenceToRemember : [Int] = []
    @State var sequenceToInsert : [Int] = []
    
    @State var insertedValue : Int = -1
    
    @State var touchable = false
    
    @State var firstBright = false
    @State var secondBright = false
    @State var thirdBright = false
    @State var fourthBright = false
    
    @State var listening = false
    
    @State var playing = false
    
    private var player1: AVPlayer { AVPlayer.click1Player }
    private var player2: AVPlayer { AVPlayer.click2Player }
    private var player3: AVPlayer { AVPlayer.click3Player }
    private var player4: AVPlayer { AVPlayer.click4Player }
    
    var body: some View {
        VStack{
            Text("\(points)")
                .font(.largeTitle)
                .padding(.top, 32)
            
            Spacer()
            
            HStack{
                TileView(color: model.theme.mainColor, bright: $firstBright)
                    .onTapGesture {
                        if(touchable){
                            firstTileBright(delay: 0.0)
                            sequenceToInsert.append(1)
                            checkNextRound()
                        }
                    }
                
                TileView(color: model.theme.mainColor, bright: $secondBright)
                    .onTapGesture {
                        if(touchable){
                            secondTileBright(delay: 0.0)
                            sequenceToInsert.append(2)
                            checkNextRound()
                        }
                    }
            }
            
            HStack{
                TileView(color: model.theme.mainColor, bright: $thirdBright)
                    .onTapGesture {
                        if(touchable){
                            thirdTileBright(delay: 0.0)
                            sequenceToInsert.append(3)
                            checkNextRound()
                        }
                    }
                
                TileView(color: model.theme.mainColor, bright: $fourthBright)
                    .onTapGesture {
                        if(touchable){
                            fourthTileBright(delay: 0.0)
                            sequenceToInsert.append(4)
                            checkNextRound()
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
        .navigationTitle("Rythms")
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            playing = false
            listening = false
            touchable = false
        }
    }
    
    typealias StepComplete = () -> Void
    
    func startRound() -> Void {
        playing = true
        
        sequenceToRemember.append(Int.random(in: 1...4))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            playSequence(sequence: sequenceToRemember) { () -> () in
                sequenceToInsert.removeAll()
                listening = true
                
            }
        }
    }
    
    func playSequence(sequence: [Int], completed: @escaping StepComplete) -> Void {
        touchable = false
        var counter = 0.0
        sequence.forEach { num in
            switch num {
            case 1:
                firstTileBright(delay: counter)
            case 2:
                secondTileBright(delay: counter)
            case 3:
                thirdTileBright(delay: counter)
            case 4:
                fourthTileBright(delay: counter)
            default:
                print("something wrong")
            }
            
            counter += 1.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (1.2 * Double(sequence.count))){
            
            touchable = true
            completed()
        }
    }
    
    func checkNextRound() {
        if(listening){
            let lastInsertedIndex : Int = sequenceToInsert.count - 1
            
            if(sequenceToInsert[lastInsertedIndex] == sequenceToRemember[lastInsertedIndex]){
                if(sequenceToInsert.count == sequenceToRemember.count){
                    points += 1
                    listening = false
                    touchable = false
                    startRound()
                }
            }
            else {
                points = 0
                listening = false
                sequenceToInsert.removeAll()
                sequenceToRemember.removeAll()
                playing = false
                touchable = false
            }
        }
    }
    
    
    func firstTileBright(delay: Double) -> Void{
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            withAnimation(.easeInOut(duration: 0.2)){
                firstBright.toggle()
                
                player1.seek(to: .zero)
                player1.play()
                
                withAnimation(.easeOut(duration: 0.2).delay(0.3)){
                    firstBright.toggle()
                }
            }
        }
    }
    
    func secondTileBright(delay: Double) -> Void{
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            withAnimation(.easeInOut(duration: 0.2)){
                secondBright.toggle()
                
                player2.seek(to: .zero)
                player2.play()
                
                withAnimation(.easeOut(duration: 0.2).delay(0.3)){
                    secondBright.toggle()
                }
            }
        }
    }
    
    func thirdTileBright(delay: Double) -> Void{
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            withAnimation(.easeInOut(duration: 0.2)){
                thirdBright.toggle()
                
                player3.seek(to: .zero)
                player3.play()
                
                withAnimation(.easeOut(duration: 0.2).delay(0.3)){
                    thirdBright.toggle()
                }
            }
        }
    }
    
    func fourthTileBright(delay: Double) -> Void{
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            withAnimation(.easeInOut(duration: 0.2)){
                fourthBright.toggle()
                
                player4.seek(to: .zero)
                player4.play()
                
                withAnimation(.easeOut(duration: 0.2).delay(0.3)){
                    fourthBright.toggle()
                }
            }
        }
    }
}


    
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        RythmsView(model: .constant(TestingModel.sampleData[0]))
    }
}


