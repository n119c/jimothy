//
//  WorkoutDetailedView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 21/10/2024.
//

import SwiftUI
import SwiftData

struct WorkoutDetailedView: View {
    
    @Bindable var workout: Workout
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showSheet = false
    @State private var showCompletion = false
    @Environment(\.presentationMode) var presentationMode
    
    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - HEADER
                        HStack {
                            // back button
                            Button {
                                dismissKeyboard()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                CircleButtonView(imageName: "chevron.left")
                            }
                            
                            Spacer()
                            
                            // workout name
                            Text(workout.name)
                                .font(.title3)
                                .fontWeight(.heavy)
                            
                            Spacer()
                            
                            // reorder button
                            if !workout.exercises.isEmpty {
                                Button {
                                    withAnimation {
                                        dismissKeyboard()
                                        isEditing.toggle()
                                    }
                                } label: {
                                    CircleButtonView(
                                        imageName: "rectangle.2.swap",
                                        shadowColor: isEditing ? Color.theme.main : nil
                                    )
                                }
                            }
                            
                            // select exercises button
//                            Button {
//                                dismissKeyboard()
//                                withAnimation {
//                                    self.showSheet.toggle()
//                                }
//                            } label: {
//                                CircleButtonView(imageName: "plus")
//                                    .padding(.leading)
//                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        
                        // MARK: - BODY (WORKOUTVIEW CONTENT)
                        LazyVStack(spacing: 8) {
                            ForEach(workout.orderedExerciseIDs.keys.sorted(), id: \.self) { index in
                                if let exerciseID = workout.orderedExerciseIDs[index],
                                   let exercise = workout.exercises.first(where: { $0.id == exerciseID }) {
                                    
                                    if isEditing {
                                        HStack {
                                            EditingExerciseRowView(exercise: exercise, workout: workout) {
                                                // onSubstitute callback
                                                isEditing = false
                                            }
                                        }
                                    } else {
                                        ExerciseView(exercise: exercise)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 7)
                        
                        if !isEditing, !workout.exercises.isEmpty {
//                            WorkoutCompleteButton(showCompletion: $showCompletion) {
//                                completeWorkout()
//                            }
                            SwipeButtonView() {
                                completeWorkout()
                            }
                        } else {
                            Button {
                                dismissKeyboard()
                                withAnimation {
                                    self.showSheet.toggle()
                                }
                            } label: {
                                CircleButtonView(imageName: "plusminus", isBig: true)
                                    .padding(.top)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // dismiss keyboard on tap
                    .contentShape(Rectangle()) // ensures the tap gesture registers across the view
                    .onTapGesture {
                        dismissKeyboard()
                    }
                }
                .scrollIndicators(.hidden)
                
                
                // MARK: - CONTENT UNAVAILABLE VIEW
                .overlay {
                    if workout.exercises.isEmpty {
                        ContentUnavailableView(
                            "No exercises yet!",
                            systemImage: "rectangle.stack.badge.plus.fill",
                            description: Text("Tap the ± button at the top of the screen to add some exercises to the workout"))
                    }
                }
                
                .overlay {
                    if showCompletion {
                        WorkoutCompleteView()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        
        
        // MARK: - SELECT EXERCISES SHEET
        .sheet(isPresented: $showSheet) {
            SelectExercisesView(showSheet: $showSheet, workout: workout)
                .presentationDetents([.fraction(0.87)])
                .presentationDragIndicator(.visible)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color.theme.background)
                        .ignoresSafeArea()
                )
        }
    }
}


// MARK: - VIEWMODEL
extension WorkoutDetailedView {
    
    private func completeWorkout() {
        self.showCompletion.toggle()
        
        // update the last completion time
        workout.lastCompletionTime = .now
        
        // save a snapshot (struct) of the current workout data
        let snapshot = workout.snapshot()
        modelContext.insert(snapshot)
        
        // display complete workout screen for 5 seconds, then go back to WorkoutsView
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.showCompletion.toggle()
                self.presentationMode.wrappedValue.dismiss()
            }
            
            // clear set data for each exercise
            workout.exercises.forEach { exercise in
                exercise.setData.removeAll()
            }
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// allow for swipe to go back a view gesture without native back button
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


// MARK: - WORKOUT COMPLETE VIEW
struct WorkoutCompleteView: View {
    
    var body: some View {
        
        VStack(spacing: 5) {
            HStack {
                Image(systemName: "laurel.leading")
                Text("Workout Complete!")
                Image(systemName: "laurel.trailing")
            }
            .font(.title)
            .bold()
            
            Text("Congratulations :) Proud of you!!")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.theme.secondaryText)
        }
        // red foreground
        .padding()
        .padding(.vertical)
        .background(Color.theme.main)
        .cornerRadius(20)
        .shadow(radius: 15)
        // background
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all)
        .background(Color.theme.background)
        //.animation(.easeInOut, value: workoutComplete)
        //.opacity(showCompletion ? 1 : 0)
        //.scaleEffect(showCompletion ? 1 : 0.9)
        //.animation(.spring(response: 0.5, dampingFraction: 0.7), value: showCompletion)
    }
}

