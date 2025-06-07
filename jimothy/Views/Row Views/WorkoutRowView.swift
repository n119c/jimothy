//
//  WorkoutRowView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 21/10/2024.
//

import SwiftUI
import SwiftData

struct WorkoutRowView: View {
    
    var workout: Workout
    
    @State var timeAgo: String = "New!"
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                .foregroundStyle(Color.theme.main)
                .shadow(color: Color.theme.shadow, radius: 5)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.title2)
                        .bold()
                        .lineLimit(1)
                    
                    let numExercises = workout.exercises.count
                    Text("\(numExercises) exercise\(numExercises == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.secondaryText)
                    
                }
                .padding()
                
                Spacer()
                
                
                // MARK: - TIME AGO
                VStack(spacing: 5) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(Color.theme.secondaryText)
                    
                    // compute timeAgo in vm
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 60)
                .padding([.vertical, .trailing])
                
            }
            .frame(height: 80)
        }
        .onAppear {
            timeAgo = computeTimeAgo(for: workout)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Workout.self, configurations: config)
        let workout = Workout(name: "Leg Day")
        
        return WorkoutRowView(workout: workout)
            .modelContainer(container)
    } catch {
        return Text("Failed to load preview.")
    }
}


// MARK: - VIEW MODEL
extension WorkoutRowView {
    
    func computeTimeAgo(for workout: Workout) -> String {
        guard let lastCompletionTime = workout.lastCompletionTime else {
            return "New!"
        }

        let calendar = Calendar.current

        // compute days, ignore hours
        let startOfLastCompletion = calendar.startOfDay(for: lastCompletionTime)
        let startOfToday = calendar.startOfDay(for: Date())
        let dayDifference = calendar.dateComponents([.day], from: startOfLastCompletion, to: startOfToday).day ?? 0

        switch dayDifference {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case 2...13:
            return "\(dayDifference) days"
        case 14...20:
            return "2 weeks"
        case 21...27:
            return "3 weeks"
        default:
            return ">1 month"
        }
    }
}

