//
//  GestureRecognizerViewRepresentable.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 29.01.2023.
//

import SwiftUI

struct GestureRecognizerView: UIViewControllerRepresentable {
    @Binding var model: TestingModel
    
    typealias UIViewControllerType = GestureRecognizerController
    
    func makeUIViewController(context: Context) -> GestureRecognizerController {
        let vc = GestureRecognizerController(model: $model)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: GestureRecognizerController, context: Context) {

    }
}
