//
//  CircleButtonView.swift
//  jimothy
//
//  Created by Nick van Tilburg on 6/11/2024.
//

import SwiftUI

struct CircleButtonView: View {
    
    var imageName: String
    var shadowColor: Color?
    var isBig = false
    
    var body: some View {
        Image(systemName: imageName)
            .font(isBig ? .title : .headline)
            .fontWeight(.heavy)
            .foregroundStyle(Color.theme.main)
            .frame(width: isBig ? 70 : 40, height: isBig ? 70 : 40)
            .background(
                Circle()
                    .foregroundColor(Color.theme.background)
                    .shadow(color: shadowColor ?? Color.theme.shadow, radius: 10)
            )
    }
}

#Preview {
    CircleButtonView(imageName: "chevron.left")
}
