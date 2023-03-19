//
//  RightOrLeftRecognizerView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import SwiftUI

struct RightOrLeftRecognizerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RightOrLeftGestureRecognizerController
    
    func makeUIViewController(context: Context) -> RightOrLeftGestureRecognizerController {
        let vc = RightOrLeftGestureRecognizerController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: RightOrLeftGestureRecognizerController, context: Context) {

    }
}
