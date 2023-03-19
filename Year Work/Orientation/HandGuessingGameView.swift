//
//  HandGuessingGameView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import SwiftUI

struct HandGuessingGameView: View {
    @Binding var model: TestingModel
    
    var body: some View {
        RightOrLeftRecognizerView().ignoresSafeArea()
    }
}

struct HandGuessingGameView_Previews: PreviewProvider {

    static var previews: some View {
        HandGuessingGameView(model: .constant(TestingModel.sampleData[0]))
    }
}


