//
//  GridBackgroundView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 04.05.2023.
//

import SwiftUI

struct GridBackgroundView: View {
    var numberOfLines: Int
    var lineColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Path { path in
                    let lineSpacing = geometry.size.height / CGFloat(numberOfLines + 1)
                    for i in 0...numberOfLines {
                        let y = lineSpacing * CGFloat(i)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(lineColor, lineWidth: 1)

                VStack {
                    ForEach((0...numberOfLines), id: \.self) { i in
                        Text("\(i * 25)%")
                            .foregroundColor(lineColor)
                            .font(.caption)
                        Spacer()
                    }
                }
                .frame(height: geometry.size.height)
                .padding(.leading, 8)
            }
        }
    }
}



