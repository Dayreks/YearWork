//
//  HandGestureProccessor.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import Foundation

class HandSideProcessor {
    enum HandGesture {
        case leftHand
        case rightHand
    }
    
    func getHandGesture(thumbTip: CGPoint, littleTip: CGPoint) -> HandGesture {
        if thumbTip.x <= littleTip.x  {
            return .rightHand
        } else {
            return .leftHand
        }
    }
}
