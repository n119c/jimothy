//
//  SubstituteView.swift
//  jimothy
//
//  Created by Nick van Tilburg on 11/11/2024.
//

import SwiftUI
import SwiftData

struct SubstituteView: View {
    
    @Environment(\.modelContext) var modelContext
    
    var oldExercise: Exercise
    var exerciseIDs: [Int : UUID]
    var onSubstitute: (Exercise) -> Void  // callback for substitution
    
    @Query(sort: \Exercise.name) var exerciseStore: [Exercise]
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // searchable list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: - ADD/SEARCH EXERCISE
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
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                            }
                            .padding(.horizontal)
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // MARK: - EXERCISE STORE (BODY)
                        ForEach(filteredExercises) { exercise in
                            
                            Button {
                                onSubstitute(exercise)
                            } label: {
                                HStack {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 13)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color.gray.opacity(0.2))
//                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Substitute Exercise")
                            .font(.title2)
                            .fontWeight(.heavy)
                    }
                }
                .background(Color.theme.background)
            }
            .background(Color.theme.background)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search or Add"
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // filter exercises based on search text and exclude exercises already in the workout
    private var filteredExercises: [Exercise] {
        exerciseStore.filter { exercise in
            !exerciseIDs.values.contains(exercise.id) &&
            (searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    // add a new exercise to the context and refresh the view
    private func addNewExercise(named name: String) {
        let newExercise = Exercise(name: name)
        modelContext.insert(newExercise)
        onSubstitute(newExercise)  // call substitution immediately
        searchText = ""  // clear search bar after adding
    }
}
