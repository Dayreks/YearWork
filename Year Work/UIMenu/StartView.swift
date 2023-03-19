//
//  StartView.swift
//  Year Work
//
//  Created by Bohdan on 11.01.2023.
//

import SwiftUI

struct StartView: View {
    @Binding var model: TestingModel
   
    private let numberColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 170))
    ]
    
    private let fixedColumns = [
        GridItem(.fixed(200)),
        GridItem(.fixed(200))
    ]
    
    private var progress: Double {
        guard model.completedTasks.count < 5 else { return 1 }
        return Double(model.completedTasks.count) / Double(5)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                model.theme.accentColor.ignoresSafeArea()
                VStack(alignment: .center) {
                    Text("Completed")
                        .font(.system(size: 24))
                        .foregroundColor(model.theme.mainColor)
                        .padding([.top], 16)
                    
                    ProgressView(value: progress)
                        .progressViewStyle(CustomProgressViewStyle(theme: model.theme))
                        .padding([.bottom, .leading, .trailing], 16)
                    
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        ForEach(Tasks.allCases, id: \.self) { button in
                            
                            switch button {
                            case .vision:
                                NavigationLink (destination: VideoView(model: $model), label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .rythms:
                                NavigationLink (destination: RythmsView(model: $model), label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .speech:
                                NavigationLink (destination: SpeechView(model: $model), label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .numbers:
                                NavigationLink (destination: NumbersView(model: $model), label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .orientation:
                                NavigationLink (destination: HandGuessingGameView(model: $model), label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            }
                        }
                    }
                    Spacer()
                    
//                    NavigationLink (destination: VideoView(model: $model), label: {
                        VStack{
                            Spacer()
                            
                            HStack(alignment: .center) {
                                Text ("Results")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                            
                            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 50, maxHeight: 74)
                            .background(model.theme.mainColor)
                            .clipShape(Capsule())
                            .onTapGesture {
                                print(model.transcribedPhrases)
                            }
                        }
                        .padding([.trailing, .leading], 16)
//                    })
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(model: .constant(TestingModel.sampleData[0]))
    }
}
