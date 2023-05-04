//
//  Year_WorkApp.swift
//  Year Work
//
//  Created by Bohdan on 04.01.2023.
//

import SwiftUI

@main
struct Year_WorkApp: App {
    @State var model = TestingModel(
        title: "MainTestingModel",
        theme: .lavender
    )
    
    var body: some Scene {
        WindowGroup {
            IntroductionView(model: $model, isButtonShown: true)
                .preferredColorScheme(.light)
        }
    }
}
