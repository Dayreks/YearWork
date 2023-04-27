//
//  ExplanationView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 27.04.2023.
//

import SwiftUI

struct ExplanationView<Content: View>: View {
    let explanationText: String
    let destination: Content
    let theme: Theme
    
    init(explanationText: String, theme: Theme, @ViewBuilder destination: () -> Content) {
        self.explanationText = explanationText
        self.destination = destination()
        self.theme = theme
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
        }
    }
}


struct ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationView(explanationText: "Explanation", theme: .indigo) {
            HandGuessingGameView(model: .constant(TestingModel.sampleData[0]))
        }
    }
}
