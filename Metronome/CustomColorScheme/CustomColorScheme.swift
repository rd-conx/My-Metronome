//
//  CustomColorScheme.swift
//  Metronome
//
// Courtesy of ryanlintott - github 2021
//

import SwiftUI

enum CustomColorScheme: Int, CaseIterable, Identifiable, Codable {
    static var defaultKey = "customColorScheme"
    static var defaultValue = CustomColorScheme.system
    
    case system = 0
    case light = 1
    case dark = 2
    
    var id: Int {
        self.rawValue
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var label: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}
