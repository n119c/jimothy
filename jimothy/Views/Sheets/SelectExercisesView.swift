//
//  SelectExercisesView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 21/10/2024.
//

import SwiftUI
import SwiftData

struct SelectExercisesView: View {
    
    @Environment(\.modelContext) var context
    @Query(sort: \Exercise.name) var exerciseStore: [Exercise] = []
    
    @Binding var showSheet: Bool
    @Bindable var workout: Workout
    
    @State private var selectedExercises: [UUID] = []
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea(.all, edges: .all)
            
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: - ADD NEW EXERCISE
                        if !searchText.isEmpty && !exerciseStore.contains(where: { $0.name.localizedCaseInsensitiveCompare(searchText) == .orderedSame }) {
                            Button {
                                addNewExercise(named: searchText)
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Add \"\(searchText)\"")
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .background(Color.theme.background)
                            }
                        }
                        
                        // MARK: - EXERCISE STORE (BODY)
                        ForEach(exerciseStore.sorted(by: { $0.name < $1.name }), id: \.self) { exercise in
                            
                            if searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText) {
                                
                                Button {
                                    toggleSelection(for: exercise)
                                } label: {
                                    HStack {
                                        Image(systemName: selectedExercises.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(selectedExercises.contains(exercise.id) ? Color.theme.primaryText : Color.theme.secondaryText)
                                        
                                        Text("\(exercise.name)")
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                }
                                // text color
                                .foregroundStyle(selectedExercises.contains(exercise.id) ? Color.theme.primaryText : Color.theme.secondaryText)
                                //.listRowBackground(Color.theme.main)
                            }
                        }
                    }
                }
                
                // MARK: - TOOLBAR (HEADER)
                .navigationBarTitleDisplayMode(.inline) // removes space at top
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Select Exercises in Order")
                            .font(.title2)
                            .fontWeight(.heavy)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            selectedExercises = []
                        } label: {
                            Text("clear")
                                .foregroundStyle(Color.theme.main)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.all, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.theme.background)
                                )
                                .shadow(color: Color.theme.shadow.opacity(0.35), radius: 6)
                        }
                    }
                }
                
                // background modifiers
                .background(Color.theme.background.edgesIgnoringSafeArea(.all))
            }
            .padding(.top)
            .searchable(
                text: $searchText,
                // keep the bar always displayed
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search or Add"
            )
        }
        .onAppear {
            // load exercises in the saved order
            selectedExercises = workout.orderedExerciseIDs.sorted(by: { $0.key < $1.key }).map { $0.value }
        }
        .onDisappear {
            saveSelectedExercises()
        }
    }
}


// MARK: - VIEWMODEL METHODS
extension SelectExercisesView {
    private func toggleSelection(for exercise: Exercise) {
        if let index = selectedExercises.firstIndex(of: exercise.id) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise.id)
        }
    }
    
    private func addNewExercise(named name: String) {
        let newExercise = Exercise(name: name)
        context.insert(newExercise)
        selectedExercises.append(newExercise.id)
        searchText = "" // clear the search bar after adding the new exercise
    }
    
    
    private func saveSelectedExercises() {
        // Find and add the selected exercises in the order of selectedExercises
        workout.exercises = selectedExercises.compactMap { exerciseID in
            exerciseStore.first { $0.id == exerciseID }
        }
        
        workout.orderedExerciseIDs = [:]  // reset orderedExercises before setting
        // Update orderedExercises with index-based ordering
        for (index, exerciseID) in selectedExercises.enumerated() {
            workout.orderedExerciseIDs[index] = exerciseID
        }
        
        // Save changes to the context
        do {
            try context.save()
        } catch {
            print("Failed to save changes to context: \(error)")
        }
    }
    
}
