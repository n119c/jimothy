//
//  ExerciseView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 21/10/2024.
//

import SwiftUI
import SwiftData


struct ExerciseView: View {
    @Environment(\.modelContext) var modelContext
    
    @Bindable var exercise: Exercise
    @State private var lastSnapshot: ExerciseSnapshot?
    @State private var isDisclosing = false
    
    @State private var showExerciseDetailSheet = false
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                .foregroundStyle(Color.theme.main)
                .shadow(color: Color.theme.shadow, radius: 3)
            
            VStack(spacing: 0) {
                
                // MARK: - HEADER
                Button {
                    withAnimation {
                        isDisclosing.toggle()
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                                .fontWeight(.heavy)
                                .lineLimit(1)
                                //.minimumScaleFactor(0.8)
                            
                            HStack {
                                // disclosure indicator
                                Image(systemName: isDisclosing ? "chevron.up" : "chevron.down")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(Color.theme.secondaryText.opacity(0.4))
                                
                                Text("\(exercise.setData.count) sets")
                                    .font(.caption)
                                    .foregroundStyle(Color.theme.secondaryText)
                            }
                        }
                        Spacer()
                        
                        RestTimerView(exercise: exercise)
                        
                        // exercise detailed view button
                        Button {
                            withAnimation {
                                showExerciseDetailSheet.toggle()
                            }
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color.theme.secondaryText)
                                .padding(.leading, 2)
                        }
                    }
                    .padding()
                }
//                .contextMenu {
//// these might need to be changed to a Move and then it shows a list of the exercises and you pick the position? although how do you pick idk
//                    Button {
//
//                    } label: {
//                        Label("Move Up", systemImage: "chevron.up")
//                    }
//                    
//                    Button {
//                        
//                    } label: {
//                        Label("Move Down", systemImage: "chevron.down")
//                    }
//                    
//                    Button {
//                        
//                    } label: {
//                        Label("Substitute", systemImage: "rectangle.2.swap")
//                    }
//                    
//                    Button {
//                        
//                    } label: {
//                        Label("Remove", systemImage: "minus.circle")
//                    }
//                }
                
                // MARK: - SET VIEWS
                if isDisclosing {
                    Divider()
                        .frame(height: 0.8)
                        .background(Color.theme.secondaryText)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    LazyVStack {
                        ForEach($exercise.setData) { $setDatum in
                            if let lastSnapshot = lastSnapshot,
                               lastSnapshot.setData.count >= setDatum.setNumber {
                                let placeholderSetDatum = lastSnapshot.setData[setDatum.setNumber - 1]
                                
                                SetView(setDatum: $setDatum,
                                        repsPlaceholder: placeholderSetDatum.reps ?? 0,
                                        weightPlaceholder: placeholderSetDatum.weight ?? 0.0)
                            } else {
                                SetView(setDatum: $setDatum)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Divider()
                        .frame(height: 0.8)
                        .background(Color.theme.secondaryText)
                        .padding(.horizontal)
//                    
//                    // MARK: - REMOVE AND ADD BUTTONS
//                    HStack {
//                        // remove button
//                        Button {
//                            if exercise.setData.count > 1 {
//                                
//                                var lastSet = exercise.setData.last
//                                            lastSet?.reps = nil
//                                            lastSet?.weight = nil
//                                
//                                exercise.setData.removeLast()
//                                
//                                // update set numbers after removal to avoid index mismatches
//                                for (index, _) in exercise.setData.enumerated() {
//                                    exercise.setData[index].setNumber = index + 1
//                                }
//                            }
//                        } label: {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "minus.circle")
//                                    .font(.subheadline)
//                                    .bold()
//                                    .shadow(radius: 3)
//                                Text("REMOVE SET")
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .shadow(radius: 3)
//                                Spacer()
//                            }
//                            .foregroundStyle(exercise.setData.count > 1 ? Color.theme.primaryText : Color.theme.secondaryText)
//                        }
//                        .padding(.bottom, 7)
//                        
//                        Divider()
//                            .frame(width: 0.8)
//                            .background(Color.theme.secondaryText)
//                            .padding(.vertical, 5)
//                        
//                        // add button
//                        Button {
//                            if exercise.setData.count < 9 {
//                                let blankSet = SetDatum(setNumber: exercise.setData.count + 1, reps: nil, weight: nil)
//                                exercise.setData.append(blankSet)
//                            }
//                        } label: {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "plus.circle")
//                                    .font(.subheadline)
//                                    .bold()
//                                    .shadow(radius: 3)
//                                Text("ADD SET")
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .shadow(radius: 3)
//                                Spacer()
//                            }
//                            .foregroundStyle(exercise.setData.count < 9 ? Color.theme.primaryText : Color.theme.secondaryText)
//                        }
//                        .padding(.bottom, 7)
//                    }
//                    .padding(.vertical, 5)
                    
                    
                    HStack {
                        // REMOVE SET BUTTON
                        Spacer()
                        Button {
                            removeSet()
                        } label: {
                            SetCapsuleButtonView(imageName: "minus", text: "remove set")
                                .opacity(exercise.setData.count > 1 ? 1 : 0.5)
                        }
                        
                        Spacer()
                        Divider()
                            .frame(width: 0.8)
                            .background(Color.theme.secondaryText)
                            .padding(.vertical, 5)
                        Spacer()
                        
                        // ADD SET BUTTON
                        Button {
                            addSet()
                        } label: {
                            SetCapsuleButtonView(imageName: "plus", text: "add set")
                                .opacity(exercise.setData.count < 9 ? 1 : 0.5)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .padding(.top, 5)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            lastSnapshot = exercise.getLastSnapshot(using: modelContext)
            
            // initialise with 4 blank sets
            if exercise.setData.isEmpty {
                exercise.setData = (1...4).map { setNumber in
                    SetDatum(setNumber: setNumber, reps: nil, weight: nil)
                }
            }
        }
        .animation(.easeInOut, value: isDisclosing)
        
        .sheet(isPresented: $showExerciseDetailSheet) {
            ExerciseDetailedView(exercise: exercise)
                .presentationDragIndicator(.visible)
        }
    }
}


// MARK: - VIEW MODEL
extension ExerciseView {
    
    private func removeSet() -> Void {
        if exercise.setData.count > 1 {
            var lastSet = exercise.setData.last
            lastSet?.reps = nil
            lastSet?.weight = nil
            
            exercise.setData.removeLast()
            
            // update set numbers after removal to avoid index mismatches
            for (index, _) in exercise.setData.enumerated() {
                exercise.setData[index].setNumber = index + 1
            }
        }
    }
    
    private func addSet() -> Void {
        if exercise.setData.count < 9 {
           let blankSet = SetDatum(setNumber: exercise.setData.count + 1, reps: nil, weight: nil)
           exercise.setData.append(blankSet)
       }
    }
}


// MARK: - CAPSULE BUTTON VIEW FOR SETS
struct SetCapsuleButtonView: View {
    
    let imageName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .bold()
            
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.theme.secondaryText)
                
        }
        .frame(width: 100)
        .padding(.vertical, 3)
    }
}
