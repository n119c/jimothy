//
//  SettingsView.swift
//  jimothy
//
//  Created by Nick van Tilburg on 12/11/2024.
//

import SwiftUI

struct SettingsView: View {
    
    private let colorStrings = ColorStrings()
    
    @AppStorage("mainColor") private var mainColor = "red"

    //var stagedColor = "red"
    
    var body: some View {
        
        ZStack {
            
            Color.theme.background
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                // MARK: - HEADER
                HStack {
                    // cancel button
                    Button {
                        
                    } label: {
                        CircleButtonView(imageName: "multiply", shadowColor: Color.theme.red)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // save button
                    Button {
                        
                    } label: {
                        CircleButtonView(imageName: "checkmark")
                    }
                }
                .padding()
                .padding(.vertical)
                
                
                // MARK: - REST TIMER
                
                
                
                // MARK: - DEFAULT SET COUNT
                
                
                
                // MARK: - WEEKLY STREAK
                
                
                
                // MARK: - COLOUR OPTIONS
                HStack {
                    Text("App Colour Theme")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                    ForEach(colorStrings.colors, id: \.self) { colorString in
                        Button {
                            self.mainColor = colorString
                        } label: {
                            ColorOptionView(colorName: colorString)
                        }
                    }
                }
                .padding()
                
                
                // MARK: - AUTOCAPITALISATION
                
                
                
                Spacer()
            }
        }
    }
}


struct ColorStrings {
    
    static let colorStrings = ColorStrings()
    
    let colors = ["red", "purple"]
}


struct ColorOptionView: View {
    
    let colorName: String
    
    var body: some View {
        
        Circle()
            .frame(width: 40, height: 40)
            .foregroundStyle(Color("\(colorName)Main"))
            .background(
                Circle()
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.theme.shadow, radius: 3)
            )
    }
}
