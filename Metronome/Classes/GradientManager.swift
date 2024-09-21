//
//  GradientManager.swift
//  Metronome
//
//  Created by Ross Conquer on 02/08/2024.
//

import Foundation
import SwiftUI

class GradientManager: ObservableObject {
    
    @Published var gradient: Color?
    
    init() {
        gradient = decideGradient()
    }
    
    private let lightThemeGradients: [Color] = [
        .cyan, .gray, .red, .yellow
    ]
    
    private let darkThemeGradients: [Color] = [
        .blue, .brown, .orange, .pink
    ]
    
    var listToUse: [Color] {
        get {
            var colorScheme: CustomColorScheme = .light
            if settingsManager.customColorScheme == CustomColorScheme.system {
                colorScheme = UITraitCollection.current.userInterfaceStyle == .light ? CustomColorScheme.light : CustomColorScheme.dark
            } else {
                colorScheme = settingsManager.customColorScheme
            }
            return colorScheme == .light ? lightThemeGradients : darkThemeGradients
        }
    }
    
    func decideGradient() -> Color {
        if listToUse == lightThemeGradients {
            // Get gradient from light options saved
            self.gradient = settingsManager.gradientLight
            return self.gradient!
        } else {
            self.gradient = settingsManager.gradientDark
            return self.gradient!
        }
    }
    
    func setGradient(gradient: Color) {
        if listToUse == lightThemeGradients {
            settingsManager.gradientLight = gradient
            self.gradient = gradient
        } else {
            settingsManager.gradientDark = gradient
            self.gradient = gradient
        }
    }
}
