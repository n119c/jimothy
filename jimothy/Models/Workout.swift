//
//  Workout.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 18/10/2024.
//

import Foundation
import SwiftData

@Model
class Workout: Identifiable {
    var name: String
    var id = UUID()
    
    var exercises = [Exercise]()
    var orderedExerciseIDs = [Int : UUID]()
    
    var lastCompletionTime: Date?

    init(name: String) {
        self.name = name
    }
}

// MARK: - LOGGING
extension Workout {
    
    func snapshot() -> WorkoutSnapshot {
        return WorkoutSnapshot(
            name: self.name,
            exerciseSnapshots: self.exercises.map { $0.snapshot() }
        )
    }
}

// MARK: - WORKOUT SNAPSHOT
@Model
class WorkoutSnapshot: Identifiable {
    var id = UUID()
    var timestamp = Date.now
    
    var name: String
    var exerciseSnapshots: [ExerciseSnapshot]
    
    init(name: String, exerciseSnapshots: [ExerciseSnapshot]) {
        self.name = name
        self.exerciseSnapshots = exerciseSnapshots
    }
}
