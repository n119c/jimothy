//
//  SetView.swift
//  swiftdatatest
//
//  Created by Nick van Tilburg on 23/10/2024.
//

import SwiftUI
import SwiftData

struct SetView: View {
    @Binding var setDatum: SetDatum
    
    @State var repsPlaceholder: Int = 0
    @State var weightPlaceholder: Double = 0.00
    
// later this will probably need to be moved to the actual weight input
    // computed property to format weight placeholder
    var formattedWeightPlaceholder: String {
        if weightPlaceholder.truncatingRemainder(dividingBy: 1) == 0 {
            // it's a whole number
            return String(format: "%.0f", weightPlaceholder)
        } else if weightPlaceholder * 10 == Double(Int(weightPlaceholder * 10)) {
            // one decimal place
            return String(format: "%.1f", weightPlaceholder)
        } else {
            // two decimal places
            return String(format: "%.2f", weightPlaceholder)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("SET \(setDatum.setNumber)")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .padding()
                
                Spacer()
                
                // REPS TEXTFIELD
                TextField("",
                          value: $setDatum.reps,
                          format: .number,
                          prompt: Text("\(repsPlaceholder)")
                                    .foregroundStyle(Color.theme.placeholderText)
                )
                    .fontWeight(.semibold)
                    .padding()
                    .frame(width: 60)
                    .background(Color.theme.mainAccent)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .keyboardType(.numberPad)
                
                Text("reps")
                    .foregroundStyle(Color.theme.secondaryText)
                    .font(.subheadline)
                    .padding(.trailing)
                
                // WEIGHT TEXTFIELD
                TextField("",
                          value: $setDatum.weight,
                          format: .number,
                          prompt: Text(formattedWeightPlaceholder)
                                    .foregroundStyle(Color.theme.placeholderText)
                )
                    .fontWeight(.semibold)
                    .padding()
                    .frame(width: 85)
                    .background(Color.theme.mainAccent)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .keyboardType(.decimalPad)
                
                Text("kg")
                    .foregroundStyle(Color.theme.secondaryText)
                    .font(.subheadline)
                
                Spacer()
                
                // COPY LAST SET BUTTON
                Button {
                    setDatum.reps = repsPlaceholder
                    setDatum.weight = Double(formattedWeightPlaceholder)
                } label: {
                    Image(systemName: "capsule.on.capsule")
                        .foregroundStyle(Color.theme.secondaryText)
                        .font(.headline)
                        .bold()
                }
                .padding(.trailing, 10)
            }
        }
    }
}
