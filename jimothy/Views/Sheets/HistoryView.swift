//
//  HistoryView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 23/10/2024.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \WorkoutSnapshot.timestamp, order: .reverse) var workoutSnapshots: [WorkoutSnapshot]
    
    var body: some View {
        
        ZStack {
            Color.theme.background
                .ignoresSafeArea(.all, edges: .all)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Workout History")
                        .font(.title)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .padding()
                
                List(workoutSnapshots) { workoutSnapshot in
                    VStack(alignment: .leading) {
                        
                        HStack {
                            // workout name
                            Text(workoutSnapshot.name)
                                .font(.title2)
                                .foregroundStyle(Color.theme.main)
                                .bold()
                            
                            Spacer()
                            
                            // date
                            Text(workoutSnapshot.timestamp, style: .date)
                                .foregroundStyle(Color.theme.secondaryText)
                        }
                        
                        ForEach(workoutSnapshot.exerciseSnapshots, id: \.name) { exerciseSnapshot in
                            
                            // exercise name
                            Text(exerciseSnapshot.name)
                                .font(.title3)
                                .bold()
                            
                            // set data
                            ForEach(exerciseSnapshot.setData, id: \.setNumber) { setDatum in
                                HStack {
                                    Text("      Set \(setDatum.setNumber):")
                                        .bold()
                                    Spacer()
                                    // weight is formatted here but should be formatted upon input
                                    Text("\(setDatum.reps ?? 0)")
                                    Text("reps x")
                                        .foregroundStyle(.secondary)
                                    Text("\(String(format: "%.2f", setDatum.weight ?? 0.0))")
                                    Text("kg")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // exercise volume
                            HStack {
                                Text("      Volume:")
                                    .bold()
                                Spacer()
                                Text("\(String(format: "%.2f", exerciseSnapshot.volume)) kg")
                            }
                        }
                    }
                    .listRowBackground(Color.theme.background)
                }
                .scrollContentBackground(.hidden)
            }
            .overlay {
                if workoutSnapshots.isEmpty {
                    ContentUnavailableView(
                        "No recorded workouts yet",
                        systemImage: "filemenu.and.selection",
                        description: Text("Complete a workout to see it recorded here!")
                    )
                }
            }
        }
    }
}
