//
//  ContentView.swift
//  Metronome
//
//  Created by Ross Conquer on 26/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var metronome: Metronome
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var gradientManager: GradientManager
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        GeometryReader { geo in
            MetronomeView()
                .preferredColorScheme(settingsManager.chosenColorScheme)
            .onAppear {
                self.deviceScreen.processSize(geo.size)
                metronome.deviceScreenSize = geo.size
                metronome.updateCapsuleWidths()
            }
            .onChange(of : geo.size) {
                self.deviceScreen.processSize(geo.size)
                metronome.deviceScreenSize = geo.size
                metronome.updateCapsuleWidths()
            }
        }
        .background(.appBackground)
    }
}


struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        // Assuming Metronome is an ObservableObject and it is properly initialized here
        let metronome = Metronome()
        
        let settingsManager = SettingsManager()
        let gradientManager = GradientManager()
        let soundManager = SoundManager()
        
        let opacities = Opacities()
        let deviceScreen = DeviceScreen()
        
        ContentView()
            .environmentObject(metronome) // Provide the Metronome object to the environment
            .environmentObject(settingsManager)
            .environmentObject(gradientManager)
            .environmentObject(soundManager)
            .environmentObject(opacities)
            .environmentObject(deviceScreen)
    }
}


