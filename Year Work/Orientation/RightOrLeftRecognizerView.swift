//
//  RightOrLeftRecognizerView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import SwiftUI

struct RightOrLeftRecognizerView: UIViewControllerRepresentable {
    @Binding var model: TestingModel
    
    typealias UIViewControllerType = RightOrLeftGestureRecognizerController
    
    func makeUIViewController(context: Context) -> RightOrLeftGestureRecognizerController {
        let vc = RightOrLeftGestureRecognizerController(model: $model)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: RightOrLeftGestureRecognizerController, context: Context) {
        
    }
}

