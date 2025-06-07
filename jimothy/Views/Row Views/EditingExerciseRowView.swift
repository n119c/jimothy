//
//  EditingExerciseRowView.swift
//  jimothy
//
//  Created by Nick van Tilburg on 9/11/2024.
//

import SwiftUI
import SwiftData

struct EditingExerciseRowView: View {
    @Environment(\.modelContext) var modelContext
    
// not sure if the exercise needs to be bindable
    @Bindable var exercise: Exercise
    @Bindable var workout: Workout
    @State private var showSubstituteScreen = false
    
    var onSubstitute: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - LABEL
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                    .foregroundStyle(Color.theme.main)
                    .shadow(color: Color.theme.shadow, radius: 3)
                
                HStack {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
            }
            .padding(.trailing, 4)
            
            
            // MARK: - BUTTONS
            Button {
                withAnimation {
                    moveExerciseUp()
                }
            } label: {
                CircleButtonView(imageName: "chevron.up", shadowColor: Color.clear)
            }
            .opacity(isTopExercise() ? 0.3 : 1) // Make up button less visible if it's the top exercise
            .disabled(isTopExercise()) // Disable if it's the top exercise
            
            Button {
                withAnimation {
                    moveExerciseDown()
                }
            } label: {
                CircleButtonView(imageName: "chevron.down", shadowColor: Color.clear)
            }
            .opacity(isBottomExercise() ? 0.3 : 1) // Make down button less visible if it's the bottom exercise
            .disabled(isBottomExercise()) // Disable if it's the bottom exercise
            
            Button {
                showSubstituteScreen.toggle()
            } label: {
                CircleButtonView(imageName: "rectangle.2.swap", shadowColor: Color.clear)
            }
        }
        .sheet(isPresented: $showSubstituteScreen) {
            SubstituteView(oldExercise: exercise, exerciseIDs: workout.orderedExerciseIDs) { newExercise in
                substituteExercise(with: newExercise)
                showSubstituteScreen = false
                // chain callback to parent view to turn off isEditing
                onSubstitute()
            }
        }
    }
    
    private func isTopExercise() -> Bool {
        guard let currentIndex = workout.orderedExerciseIDs.first(where: { $0.value == exercise.id })?.key else { return false }
        return currentIndex == 0
    }
    
    private func isBottomExercise() -> Bool {
        guard let currentIndex = workout.orderedExerciseIDs.first(where: { $0.value == exercise.id })?.key else { return false }
        return currentIndex == workout.orderedExerciseIDs.count - 1
    }
    
    private func moveExerciseUp() {
        guard let currentIndex = workout.orderedExerciseIDs.first(where: { $0.value == exercise.id })?.key else { return }
        let previousIndex = currentIndex - 1
        if workout.orderedExerciseIDs.keys.contains(previousIndex) {
            swapExerciseOrder(at: currentIndex, and: previousIndex)
        }
    }
    
    private func moveExerciseDown() {
        guard let currentIndex = workout.orderedExerciseIDs.first(where: { $0.value == exercise.id })?.key else { return }
        let nextIndex = currentIndex + 1
        if workout.orderedExerciseIDs.keys.contains(nextIndex) {
            swapExerciseOrder(at: currentIndex, and: nextIndex)
        }
    }
    
    private func swapExerciseOrder(at index1: Int, and index2: Int) {
        let valueAtIndex1 = workout.orderedExerciseIDs[index1]
        workout.orderedExerciseIDs[index1] = workout.orderedExerciseIDs[index2]
        workout.orderedExerciseIDs[index2] = valueAtIndex1
    }

    private func substituteExercise(with newExercise: Exercise) {
        if let index = workout.orderedExerciseIDs.first(where: { $0.value == exercise.id })?.key {
            workout.orderedExerciseIDs[index] = newExercise.id
            if let oldExerciseIndex = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
                workout.exercises[oldExerciseIndex] = newExercise
            }
        }
    }
}
