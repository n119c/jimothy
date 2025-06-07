//
//  RestTimerView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 5/11/2024.
//

import SwiftUI
import UserNotifications

import SwiftUI
import UserNotifications

struct RestTimerView: View {
    @State private var remainingTime: CGFloat
    @State private var isTimerRunning = false
    @State private var endTime: Date? // Add @State to allow mutability
    
    var exercise: Exercise
    
    // Initialize remainingTime with the restTime from the Exercise object
    init(exercise: Exercise) {
        self.exercise = exercise
        _remainingTime = State(initialValue: CGFloat(exercise.restTime))
    }

    var body: some View {
        ZStack {
            // route for progress circle
            Circle()
                .stroke(Color.theme.secondaryText.opacity(0.2), lineWidth: 4)
                .frame(width: 32, height: 32)
                .opacity(isTimerRunning ? 1 : 0)
            
            // progress circle
            Circle()
                .trim(from: 0, to: 1 - (remainingTime / CGFloat(exercise.restTime)))
                .stroke(Color.theme.secondaryText, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 32, height: 32)
                .animation(.linear, value: remainingTime)
            
            // timer
            Button(action: toggleTimer) {
                Image(systemName: "timer")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.theme.secondaryText)
            }
        }
        .onAppear(perform: updateRemainingTime)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isTimerRunning {
                updateRemainingTime()
            }
        }
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
        if isTimerRunning {
            endTime = Date().addingTimeInterval(TimeInterval(exercise.restTime))
            scheduleNotification(at: endTime!)
        } else {
            cancelNotification()
            remainingTime = CGFloat(exercise.restTime)
        }
    }
    
    private func updateRemainingTime() {
        if let endTime = endTime, isTimerRunning {
            remainingTime = max(0, CGFloat(endTime.timeIntervalSinceNow))
            if remainingTime <= 0 {
                timerDidFinish()
            }
        }
    }
    
    private func timerDidFinish() {
        isTimerRunning = false
        remainingTime = CGFloat(exercise.restTime)
        scheduleNotification(at: Date()) // Send notification immediately
    }
    
    private func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Time Complete!"
        content.body = "Your rest period is over. Time to get back to your workout!"
        content.sound = .default
        
        let timeInterval = max(1, date.timeIntervalSinceNow) // Use 1 second minimum for immediate trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "RestTimerNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestTimerNotification"])
    }
}
