//
//  HandGestureProccessor.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 16.03.2023.
//

import Foundation

class HandGestureProcessor {
    enum HandGesture: String, CaseIterable {
        case thumbUp = "👍"
        case thumbDown = "👎"
        case vSign = "✌️"
        case highFive = "🖐️"
        case empty
    }
    
    func getHandGesture(
        thumbTip: CGPoint,
        indexTip: CGPoint,
        middleTip: CGPoint,
        ringTip: CGPoint,
        littleTip: CGPoint,
        wrist: CGPoint
    ) -> HandGesture {
        let fingers = [thumbTip, indexTip, middleTip, ringTip, littleTip]
        let minY = fingers.min(by: { $0.y > $1.y })?.y ?? 0
        let maxY = fingers.max(by: { $0.y > $1.y })?.y ?? 0
        
        if thumbTip.y == maxY && wrist.y > thumbTip.y { return .thumbUp }
        if thumbTip.y == minY && wrist.y < thumbTip.y && indexTip.y > wrist.y  { return .thumbDown }
        
        if abs(thumbTip.x - ringTip.x) > abs(indexTip.x - ringTip.x) && middleTip.y < thumbTip.y {
            return .highFive
        }
        if indexTip.y < thumbTip.y && indexTip.y < ringTip.y && middleTip.y < thumbTip.y && middleTip.y < ringTip.y && middleTip.y < littleTip.y {
            return .vSign
        }
        return .empty
    }
}
