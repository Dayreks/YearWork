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
    
    @State private var progress: Double = 0
    @State private var resetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                model.theme.accentColor.ignoresSafeArea()
                VStack(alignment: .center) {
                    HStack {
                        Text("Прогрес")
                            .font(.system(size: 24))
                            .foregroundColor(model.theme.mainColor)
                            .padding([.top], 16)
                        
                        Spacer()
                        
                        NavigationLink (destination: IntroductionView(model: $model, isButtonShown: false), label: {
                            ZStack {
                                Rectangle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(model.theme.mainColor)
                                    .cornerRadius(10)
                                Image(systemName: "questionmark")
                                    .foregroundColor(model.theme.accentColor)
                            }
                            .padding([.top], 16)
                        })
                    }
                    .padding([.leading, .trailing], 32)
                    
                    ProgressView(value: progress)
                        .progressViewStyle(CustomProgressViewStyle(theme: model.theme))
                        .padding([.bottom, .leading, .trailing], 16)
                    
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        ForEach(TestTask.allCases, id: \.self) { button in
                            
                            switch button {
                            case .vision:
                                NavigationLink (
                                    destination: ExplanationView(
                                        model: $model,
                                        task: .vision,
                                        explanationText: button.description,
                                        theme: model.theme
                                    ) {
                                        VideoView(model: $model)
                                    },
                                    label: {
                                        MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                    })
                                
                            case .rythms:
                                NavigationLink (
                                    destination: ExplanationView(
                                        model: $model,
                                        task: .rythms,
                                        explanationText: button.description,
                                        theme: model.theme
                                    ) {
                                        RythmsView(model: $model)
                                    },
                                    label: {
                                        MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                    })
                                
                            case .speech:
                                NavigationLink (
                                    destination: ExplanationView(
                                        model: $model,
                                        task: .speech,
                                        explanationText: button.description,
                                        theme: model.theme
                                    ) {
                                        SpeechView(model: $model)
                                    },
                                    label: {
                                        MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                    })
                                
                            case .numbers:
                                NavigationLink (
                                    destination: ExplanationView(
                                        model: $model,
                                        task: .numbers,
                                        explanationText: button.description,
                                        theme: model.theme) {
                                            NumbersView(model: $model)
                                        },
                                    label: {
                                        MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                    })
                                
                            case .orientation:
                                NavigationLink (
                                    destination: ExplanationView(
                                        model: $model,
                                        task: .orientation,
                                        explanationText: button.description,
                                        theme: model.theme
                                    ) {
                                        HandGuessingGameView(model: $model)
                                    },
                                    label: {
                                        MenuButtonView(color: model.theme.mainColor, image: button.rawValue)
                                    })
                                
                            }
                        }
                        
                        MenuButtonView(color: .red, image: "reset")
                            .onTapGesture {
                                resetAlert = true
                            }
                            .alert(isPresented: $resetAlert) {
                                Alert(
                                    title: Text("Увага!"),
                                    message: Text("Ви впевненні що хоче почати наново ?"),
                                    primaryButton: .destructive(Text("Так")) {
                                        model.resetCompletedTasks()
                                        resetAlert = false
                                        model.fetchCompletedTasks()
                                        progress = Double(model.completedTasks.count) / Double(5)
                                    },
                                    secondaryButton: .default(Text("ні"))
                                )
                            }
                    }
                    Spacer()
                    
                    NavigationLink (destination: ResultsView(resultsModel: ResultsViewModel(model: $model)), label: {
                        VStack{
                            Spacer()
                            
                            Group {
                                if model.completedTasks.count >= 5 {
                                    HStack(alignment: .center) {
                                        Text ("Результати")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20))
                                    }
                                    .frame(minWidth: 100, maxWidth: 200, minHeight: 25, maxHeight: 60)
                                    .background(model.theme.mainColor)
                                    .clipShape(Capsule())
                                    //                                .onTapGesture {
                                    //                                    model.completedTasks.forEach {
                                    //                                        if $0.task == TestTask.speech.rawValue {
                                    //                                            print($0.transcribedPhrases)
                                    //                                        }
                                    //                                    }
                                    //                                }
                                }
                            }
                            .padding([.trailing, .leading], 16)
                        }
                    })
                }
            }
            .onAppear() {
                model.fetchCompletedTasks()
                progress = Double(model.completedTasks.count) / Double(5)
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
