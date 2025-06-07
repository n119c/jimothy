//
//  Color.swift
//  jimothy
//
//  Created by Nick van Tilburg on 7/11/2024.
//

import Foundation
import SwiftUI

extension Color { static let theme = ColorTheme() }

struct ColorTheme {
    
    let background = Color("backgroundColor")
    let shadow = Color.white.opacity(0.3)
    let primaryText = Color("primaryTextColor")
    //let primaryText = Color("backgroundColor")
    let secondaryText = Color.white.opacity(0.4)
    let placeholderText = Color.white.opacity(0.25)
    
    let red = Color("redMain")
    let green = Color("green")
    
    
    // MAIN COLORS
//    let main = Color("purpleMain")
//    let mainAccent = Color("purpleAccent")
    
    let redMain = Color("redMain")
    let redAccent = Color("redAccent")
    let purpleMain = Color("purpleMain")
    let purpleAccent = Color("purpleAccent")
    
    
    // Dynamic Main Color and Accent
    @AppStorage("mainColor") private var mainColor: String = "red"
    
    var main: Color {
        Color("\(mainColor)Main")
    }
    
    var mainAccent: Color {
        Color("\(mainColor)Accent")
    }

}
