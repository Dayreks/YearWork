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
                    Text("Прогрес")
                        .font(.system(size: 24))
                        .foregroundColor(model.theme.mainColor)
                        .padding([.top], 16)
                    
                    ProgressView(value: progress)
                        .progressViewStyle(CustomProgressViewStyle(theme: model.theme))
                        .padding([.bottom, .leading, .trailing], 16)
                    
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        ForEach(TestTask.allCases, id: \.self) { button in
                            
                            switch button {
                            case .vision:
                                NavigationLink (
                                    destination: ExplanationView(explanationText: "Повтори своїми руками жести відображені на екрані", theme: model.theme) { VideoView(model: $model)
                                    },
                                    label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .rythms:
                                NavigationLink (
                                    destination: ExplanationView(explanationText: "Запамʼятовуй звуки та послідовність ритмів і відтворюй їх у такому ж порядку", theme: model.theme) { RythmsView(model: $model)
                                    },
                                    label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .speech:
                                NavigationLink (
                                    destination: ExplanationView(explanationText: "Читай в слух те що бачиш посередині екрану", theme: model.theme) { SpeechView(model: $model)
                                    },
                                    label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .numbers:
                                NavigationLink (
                                    destination: ExplanationView(explanationText: "Запамʼятовуй послідовність цифр та відтворюй її по памʼяті", theme: model.theme) { NumbersView(model: $model)
                                    },
                                    label: {
                                    MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                })
                                
                            case .orientation:
                                NavigationLink (
                                    destination: ExplanationView(explanationText: "Піднімай руку з тої сторони де підсвічується екран", theme: model.theme) { HandGuessingGameView(model: $model)
                                    },
                                    label: {
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
                                Text ("Результати")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                            .frame(minWidth: 100, maxWidth: 200, minHeight: 25, maxHeight: 60)
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
            .onAppear() {
                model.fetchCompletedTasks()
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
