//
//  MetronomeApp.swift
//  Metronome
//
//  Created by Ross Conquer on 28/11/2023.
//

import SwiftUI

let metronome = Metronome()

let settingsManager = SettingsManager()
let gradientManager = GradientManager()
let soundManager = SoundManager()
let opacities = Opacities()
let deviceScreen = DeviceScreen()

let BUILD_NUMBER = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

@main
struct MetronomeApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(metronome)
                .environmentObject(settingsManager)
                .environmentObject(gradientManager)
                .environmentObject(soundManager)
                .environmentObject(opacities)
                .environmentObject(deviceScreen)
        }
    }
}
