import SwiftUI

struct SpeakerArc: Shape {
    let phraseIndex: Int
    let totalPhrases: Int
    
    private var degreesPerPhrase: Double {
        360.0 / Double(totalPhrases)
    }
    private var startAngle: Angle {
        Angle(degrees: degreesPerPhrase * Double(phraseIndex) + 1.0)
    }
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerPhrase - 1.0)
    }

    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}
