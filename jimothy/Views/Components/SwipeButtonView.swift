//
//  SwipeButtonView.swift
//  jimothy
//
//  Created by Nick van Tilburg on 13/11/2024.
//

import SwiftUI

struct SwipeButtonView: View {
    
    private let barWidth = 250
    private let barHeight = 70
    private let buttonWidth = 70
    private let maxPathDrag = 250 - 70
    private let startingOffset = -(250 / 2) + (70 / 2)
    
    @State private var offset = 0
    @State private var isDragging = false
    
    // callback to register button completion
    var isComplete: () -> Void
    
    var body: some View {
        ZStack {
            // BACKGROUND TRACK
            // right side of bar
            Capsule()
                .frame(width: CGFloat(barWidth), height: 70)
                .foregroundStyle(Color.theme.mainAccent)
                .shadow(color: Color.theme.shadow, radius: 10)
            
//            // left side of bar
//            Capsule()
//                .frame(width: CGFloat(barWidth), height: 70)
//                .foregroundStyle(Color.theme.secondaryText)
//                .shadow(color: Color.theme.shadow, radius: 10)
            
            Text("complete workout")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Color.theme.secondaryText)
                .offset(x: 25)
                .opacity(isDragging ? 0 : 1)
            
            // DRAG BUTTON
            ZStack {
                Circle()
                    .frame(width: CGFloat(buttonWidth), height: CGFloat(buttonWidth))
                    .foregroundStyle(Color.theme.main)
                    
                
                Image(systemName: "checkmark")
                    .font(.title)
                    .fontWeight(.heavy)
                    
            }
            .offset(x: CGFloat(startingOffset + offset))
            .gesture(DragGesture()
                .onChanged { gesture in
                    isDragging = true
                    
                    let translation = gesture.translation.width
                    
                    // register gestures to the right
                    if translation > 0 && translation < CGFloat(maxPathDrag) {
                        offset = Int(translation)
                        
                    }
                }
                .onEnded { gesture in
                    isDragging = false
                    
                    let translation = gesture.translation.width
                    
                    // reset the offset when released
                    withAnimation {
                        offset = 0
                    }
                    
                    // if dragged past 90%
                    if translation > 0.9 * CGFloat(maxPathDrag) {
                        isComplete()
                    }
                }
            )
            
        }
    }
}
