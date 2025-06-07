//
//  ContentView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 18/10/2024.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    
    @Query(sort: \Workout.lastCompletionTime, order: .reverse) var workouts: [Workout]
    
    @State var showAddWorkoutSheet = false
    @State var showHistorySheet = false
    @State var showSettingsSheet = false
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    // MARK: - HEADER
                    VStack(spacing: 25) {
                        
                        // MARK: TOOLBAR BUTTONS
                        HStack {
                            // settings button
                            Button {
                                showSettingsSheet.toggle()
                            } label: {
                                CircleButtonView(imageName: "gearshape")
                            }
                            
                            Spacer()
                            
                            // history button
                            Button {
                                withAnimation {
                                    showHistorySheet.toggle()
                                }
                            } label: {
                                CircleButtonView(imageName: "book.pages")
                            }
                            
                            // add workout button
                            Button {
                                withAnimation {
                                    showAddWorkoutSheet.toggle()
                                }
                            } label: {
                                CircleButtonView(imageName: "plus")
                                    .padding(.leading)
                            }
                        }
                        
                        // MARK: TITLE
                        HStack {
                            Image(systemName: "poweroutlet.type.f")
                                .font(.largeTitle)
                            
                            Text("jimothy")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - BODY (WORKOUT PREVIEWS)
                    LazyVStack(spacing: 10) {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailedView(workout: workout)
                            } label: {
                                WorkoutRowView(workout: workout)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .background(Color.theme.background.ignoresSafeArea())
            }
            .background(Color.theme.background.ignoresSafeArea()) // background applied to ScrollView
        }
        
        // MARK: - CONTENT UNAVAILABLE VIEW
        .overlay {
            if workouts.isEmpty {
                ContentUnavailableView(
                    "No workouts yet!",
                    systemImage: "rectangle.stack.badge.plus.fill",
                    description: Text("Tap the plus button on the top right of the screen to add your first workout!"))
            }
        }
        // MARK: - SHEETS
        .blur(radius: showAddWorkoutSheet ? 5 : 0) // apply blur effect conditionally
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: showAddWorkoutSheet)
        
        
        // ADDWORKOUT SHEET
        .sheet(isPresented: $showAddWorkoutSheet) {
            AddWorkoutView()
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color.theme.background)
                        .ignoresSafeArea()
                )
        }
        
        // HISTORY SHEET
        .sheet(isPresented: $showHistorySheet) {
            HistoryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color.theme.background)
                        .ignoresSafeArea()
                )
        }
        
        // SETTINGS SHEET
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color.theme.background)
                        .ignoresSafeArea()
                )
        }
        
        .onAppear {
            requestNotificationPermission()
        }
    }
}


extension ContentView {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}
