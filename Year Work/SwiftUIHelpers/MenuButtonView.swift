//
//  MenuButtonView.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 13.03.2023.
//

import SwiftUI

struct MenuButtonView: View {
    var color: Color
    var image: String

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 170, height: 170)
                .foregroundColor(color)
                .cornerRadius(30)
            Image(image)
                .resizable()
                .frame(width: 150, height: 150)
        }
    }
    
    
}

struct MenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MenuButtonView(color: .red, image: "vision")
    }
}
