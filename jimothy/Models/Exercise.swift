//
//  Exercise.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 18/10/2024.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable {
    var id: UUID = UUID() // Unique identifier for the exercise
    @Attribute(.unique) var name: String
    
    var setData: [SetDatum] = []
    
    var restTime: Int = 90 // rest time in seconds
    var notes: String?
    
    init(name: String) {
        self.name = name
    }
}

// codable means it can be formatted into a way that can be stored and retrieved from a database
struct SetDatum: Identifiable, Codable {
    var id: Int { setNumber }
    
    var setNumber: Int
    var reps: Int?
    var weight: Double?
}


// MARK: - LOGGING
extension Exercise {
    func snapshot() -> ExerciseSnapshot {
        // calculate total volume
        let totalVolume = setData.reduce(0.0) { result, setDatum in
            result + (Double(setDatum.reps ?? 0) * (setDatum.weight ?? 0))
        }
        
        let exerciseSnapshot = ExerciseSnapshot(
            exerciseID: self.id,
            name: self.name,
            volume: totalVolume,
            restTime: self.restTime,
            setData: self.setData
        )
        
        return exerciseSnapshot
    }
    
    func getAllSnapshots(using modelContext: ModelContext) -> [ExerciseSnapshot] {
        let targetExerciseID = self.id // Extract `self.id` into a local variable
        
        let descriptor = FetchDescriptor<ExerciseSnapshot>(
            predicate: #Predicate { snapshot in
                snapshot.exerciseID == targetExerciseID
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch snapshots: \(error)")
            return []
        }
    }

    func getLastSnapshot(using modelContext: ModelContext) -> ExerciseSnapshot? {
        let snapshots = getAllSnapshots(using: modelContext)
        return snapshots.first // Return the most recent snapshot
    }


}

@Model
class ExerciseSnapshot: Identifiable {
    var id = UUID()
    var timestamp = Date.now
    
    var exerciseID: UUID // to maintain relationship to exercise
    var name: String
    var volume: Double
    var restTime: Int
    var setData: [SetDatum]
    
    init(exerciseID: UUID, name: String, volume: Double, restTime: Int, setData: [SetDatum]) {
        self.exerciseID = exerciseID
        self.name = name
        self.volume = volume
        self.restTime = restTime
        self.setData = setData
    }
}
