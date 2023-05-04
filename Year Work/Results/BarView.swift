//
//  BarView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 04.05.2023.
//

import SwiftUI

struct BarView: View {
    var value: Double
    var maxValue: Double
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(color)
                .frame(height: CGFloat(value / maxValue) * geometry.size.height)
                .cornerRadius(12)
        }
    }
}

