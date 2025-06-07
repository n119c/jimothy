//
//  swiftdatatestApp.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 18/10/2024.
//

import SwiftUI
import SwiftData

// Step 1: Create a custom environment key for default text color
struct DefaultTextColorKey: EnvironmentKey {
    static let defaultValue: Color = Color.theme.primaryText // Default color can be set here
}

extension EnvironmentValues {
    var defaultTextColor: Color {
        get { self[DefaultTextColorKey.self] }
        set { self[DefaultTextColorKey.self] = newValue }
    }
}

// Step 2: Create a view modifier to apply the default text color
struct DefaultTextStyle: ViewModifier {
    @Environment(\.defaultTextColor) var defaultTextColor

    func body(content: Content) -> some View {
        content.foregroundColor(defaultTextColor)
    }
}

extension View {
    func applyDefaultTextStyle() -> some View {
        self.modifier(DefaultTextStyle())
    }
}

@main
struct swiftdatatestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.defaultTextColor, Color.theme.primaryText) // Use your custom text color here
                .applyDefaultTextStyle() // Apply the default text style to the content view
        }
        .modelContainer(for: [Workout.self, Exercise.self, WorkoutSnapshot.self, ExerciseSnapshot.self])
    }
}
