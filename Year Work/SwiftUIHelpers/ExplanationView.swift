//
//  ExplanationView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 27.04.2023.
//

import SwiftUI

struct ExplanationView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    
    let explanationText: String
    let destination: Content
    let theme: Theme
    let task: TestTask
    
    @Binding var model: TestingModel
    @State private var showAlert = false
    
    init(model: Binding<TestingModel>, task: TestTask, explanationText: String, theme: Theme, @ViewBuilder destination: () -> Content) {
        self.explanationText = explanationText
        self.destination = destination()
        self.theme = theme
        self.task = task
        _model = model
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(explanationText)
                .font(.system(size: 24, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            NavigationLink(destination: destination) {
                HStack(alignment: .center) {
                    Text ("Продовжити")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                    .frame(minWidth: 100, maxWidth: 200, minHeight: 25, maxHeight: 60)
                    .background(theme.mainColor)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 20)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Ви вже завершили цю секцію"),
                    dismissButton: .default(Text("Ок")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .onAppear() {
                if model.completedTasks.contains(where: { $0.task == task.rawValue}) {
                    showAlert = true
                }
            }
        }
    }
}


struct ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationView(model: .constant(TestingModel.sampleData[0]), task: .vision, explanationText: "Explanation", theme: .indigo) {
            HandGuessingGameView(model: .constant(TestingModel.sampleData[0]))
        }
    }
}
