//
//  ContentView.swift
//  Year Work
//
//  Created by Bohdan on 04.01.2023.
//

import SwiftUI


struct VideoView: View {
    @Binding var model: TestingModel

    var body: some View {
        GestureRecognizerView()
            .ignoresSafeArea()
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(model: .constant(TestingModel.sampleData[0]))
    }
}
