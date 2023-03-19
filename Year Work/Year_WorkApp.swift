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
        phrases: ["а", "та", "ла", "жах", "страх", "вибух"],
        lengthInMinutes: 1,
        theme: .navy
    )
    
    var body: some Scene {
        WindowGroup {
            StartView(model: $model)
                .preferredColorScheme(.light)
        }
    }
}
