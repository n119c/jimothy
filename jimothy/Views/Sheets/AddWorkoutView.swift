//
//  AddWorkoutView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 18/10/2024.
//

import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @State var nameText = ""
    
    
    var body: some View {

        ZStack {
            Color.theme.background
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                
                // TITLE
                Text("Add New Workout")
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding()
                
                // TEXTFIELD
                HStack {
                    Text("NAME")
                        .fontWeight(.heavy)
                    
                    TextField("name", text: $nameText)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.theme.mainAccent)
                        .cornerRadius(5)

                }
                .padding()
                .background(Color.theme.main)
                .cornerRadius(15)
                .shadow(color: Color.theme.shadow, radius: 5)
                .padding(.horizontal)
                
                // SAVE BUTTON
                Button {
                    if !self.nameText.isEmpty {
                        addWorkout(named: nameText)
                        nameText = ""
                        dismiss()
                    }
                } label: {
                    CircleButtonView(imageName: "checkmark", isBig: true)
                        .padding(.top, 25)
                }
            }
        }
    }
}


// MARK: - VIEW MODEL
extension AddWorkoutView {
    
    func addWorkout(named name: String) {
        
        let workout = Workout(name: nameText)
        context.insert(workout)
    }
}
