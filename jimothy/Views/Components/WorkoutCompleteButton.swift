//
//  WorkoutCompleteButton.swift
//  jimothy
//
//  Created by Nick van Tilburg on 11/11/2024.
//

import SwiftUI

struct WorkoutCompleteButton: View {
    
    @Binding var showCompletion: Bool
    
    @State private var progress: Double = 0.0
    @State private var isPressing = false
    @State private var timer: Timer? = nil
    
    // on completion closure to notify parent and trigger completeWorkout function call
    var onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            
            // progress bar circle
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0))) // Limit progress to 1.0 (100%)
                .stroke(Color.theme.main, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .frame(width: 67)
                .rotationEffect(.degrees(-90))
            
            // background circle with shadow applied only to the edges
            Circle()
                .foregroundColor(Color.theme.background)
                .frame(width: 70, height: 70)
                .shadow(color: Color.theme.shadow, radius: 5)
            
            // checkmark
            Image(systemName: "checkmark")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(Color.theme.main)
                .frame(width: 70, height: 70)
        }
        .padding(.top)
        .onLongPressGesture(
            minimumDuration: 2.1,
            maximumDistance: 50, // allows some movement during the press
            perform: {
                if progress >= 1 {
                    print("Long press completed!")
                }
            },
            onPressingChanged: { isPressing in
                if isPressing {
                    startProgress()
                } else {
                    stopProgress()
                }
            }
        )
    }
    
    private func startProgress() {
        isPressing = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isPressing && progress < 1.0 {
                progress += 0.05 // Adjust increment speed as desired
                
                // completion of the circle
                if progress >= 1.0 {
                    stopProgress()
                    progress = 1.0
                    
                    // trigger the closure
                    onCompletion()
                }
            }
        }
    }
    
    private func stopProgress() {
        isPressing = false
        timer?.invalidate()
        timer = nil
        progress = 0.0
    }
    
}
