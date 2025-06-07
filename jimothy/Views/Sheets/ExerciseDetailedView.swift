//
//  ExerciseDetailedView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 5/11/2024.
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseDetailedView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var exercise: Exercise
    @State var snapshots: [ExerciseSnapshot]?
    
    // Rest time and picker visibility state
    @State private var restTimeInSeconds: Int = 90
    @State private var isPickerVisible: Bool = false
    
    @State private var notes: String = ""
    
    private var minutes: Int {
        Int(restTimeInSeconds) / 60
    }
    private var seconds: Int {
        Int(restTimeInSeconds) % 60
    }
    
    // Volume difference calculation
    private var volumeDifference: CGFloat? {
        guard let snapshots = snapshots, snapshots.count > 1 else { return nil }
        return snapshots[0].volume - snapshots[1].volume
    }
    
    // Average percentage change over the last 5 entries
    private var averagePercentageChange: CGFloat? {
        guard let snapshots = snapshots, snapshots.count > 5 else { return nil }
        
        let lastFiveSnapshots = Array(snapshots.prefix(5))
        let percentageChanges: [CGFloat] = zip(lastFiveSnapshots, lastFiveSnapshots.dropFirst()).map { current, next in
            ((current.volume - next.volume) / next.volume) * 100
        }
        
        let averageChange = percentageChanges.reduce(0, +) / CGFloat(percentageChanges.count)
        return averageChange
    }
    
    
    var body: some View {
        
        ZStack {
            Color.theme.background
                .ignoresSafeArea(.all, edges: .all)
            
            VStack(alignment: .leading, spacing: 30) {
                
                HStack {
                    //TextField("Exercise Name", text: $exercise.name)
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil.circle")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.theme.secondaryText)
                    }
                }
                .padding()
                .padding(.top)
                
                // MARK: - CHART
                if let snapshots, !snapshots.isEmpty {
                    Chart {
                        ForEach(snapshots) { snapshot in
                            LineMark(
                                x: .value("Date", snapshot.timestamp, unit: .day),
                                y: .value("Volume", snapshot.volume)
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartYAxisLabel("Volume (kg)")
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Complete at least 2 workouts containing this exercise to graph your progress over time")
                    )
                    .frame(height: 200)
                }
                
                // MARK: - METRICS
                if let difference = volumeDifference {
                    HStack {
                        Text("Volume Change:")
                            .font(.callout)
                        
                        Spacer()
                        
                        Text("\(difference > 0 ? "+" : "")\(String(format: "%.1f", difference)) kg")
                            .font(.headline)
                            .bold()
                        
                        Image(systemName: difference > 0 ? "arrow.up" : "arrow.down")
                            .foregroundStyle(difference > 0 ? Color.theme.green : Color.theme.red)
                            .frame(height: 50)
                            .fontWeight(.heavy)
                    }
                    .padding(.horizontal)
                }
                
                if let percentage = averagePercentageChange {
                    HStack {
                        Text("Avg. % Change Over Last 5 Records:")
                            .font(.callout)
                        
                        Spacer()
                        
                        Text("\(percentage > 0 ? "+" : "")\(String(format: "%.2f", percentage))%")
                            .font(.headline)
                            .bold()
                        
                        Image(systemName: percentage > 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                            .foregroundStyle(percentage > 0 ? Color.theme.green : Color.theme.red)
                            .frame(height: 50)
                            .fontWeight(.heavy)
                    }
                    .padding(.horizontal)
                }
                
                
                // MARK: - REST TIME
                VStack(alignment: .leading) {
                    Text("REST TIME")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                            .padding(.horizontal)
                    
                    HStack {
                        Text("Rest Time")
                        Spacer()
                        Text("\(minutes) min \(seconds) sec")
                            .foregroundColor(Color.theme.secondaryText)
                            .onTapGesture {
                                withAnimation {
                                    isPickerVisible = true
                                }
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.theme.background)
                            .shadow(color: Color.theme.shadow.opacity(0.35), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    
                    // MARK: - NOTES
                    Text("NOTES")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                            .padding(.horizontal)
                            .padding(.top)
                    
                    TextEditor(text: $notes)
                        .frame(height: 150)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.theme.background)
                                .shadow(color: Color.theme.shadow.opacity(0.35), radius: 5)
                        )
                        .padding(.horizontal)
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
            }
            .blur(radius: isPickerVisible ? 10 : 0)
        }
        
        .onAppear {
            snapshots = exercise.getAllSnapshots(using: modelContext)
            restTimeInSeconds = exercise.restTime
            notes = exercise.notes ?? ""
            
        }
        
        .onDisappear {
            // Save changes back to the model
            exercise.restTime = restTimeInSeconds
            exercise.notes = notes
            try? modelContext.save()
        }
        
        .overlay(
            Group {
                if isPickerVisible {
                    RestTimePickerView(
                        restTimeInSeconds: $restTimeInSeconds,
                        onDone: {
                            isPickerVisible = false
                        }
                    )
                }
            }
        )
    }
}





struct RestTimePickerView: View {
    @Binding var restTimeInSeconds: Int
    var onDone: () -> Void  // Callback to hide the picker
    
    private var minutes: Int {
        Int(restTimeInSeconds) / 60
    }
    
    private var seconds: Int {
        Int(restTimeInSeconds) % 60
    }
    
    var body: some View {
        VStack {
            Text("Select Rest Time")
                .font(.headline)
            
            HStack {
                // Minutes picker
                Picker("Minutes", selection: Binding(
                    get: { minutes },
                    set: { newMinutes in
                        restTimeInSeconds = Int(newMinutes * 60 + seconds)
                    })
                ) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .frame(width: 100)
                .clipped()
                
                Text("min")
                    .padding(.trailing)
                
                // Seconds picker
                Picker("Seconds", selection: Binding(
                    get: { seconds },
                    set: { newSeconds in
                        restTimeInSeconds = Int(minutes * 60 + newSeconds)
                    })
                ) {
                    ForEach(0..<60) { second in
                        Text("\(second)").tag(second)
                    }
                }
                .frame(width: 100)
                .clipped()
                
                Text("sec")
            }
            .pickerStyle(.wheel)
            
            Button("Done") {
                withAnimation {
                    onDone()  // Call the onDone callback to hide the picker
                }
            }
            .padding(.top)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(10)
        .shadow(color: Color.theme.shadow.opacity(0.35), radius: 5)
    }
}
