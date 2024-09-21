//
//  PlayerView.swift
//  Metronome
//
//  Created by Ross Conquer on 28/11/2023.
//

import AVFoundation
import SwiftUI

struct PlayerView: View {
    
    // Setup of dark/light mode detector and font color variable
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var metronome: Metronome
    
//    @State private var tempoChoice: Double = DEFAULT_BPM
//    @State private var timeSigChoice:  [Int] = DEFAULT_TIME_SIG
    
    var body: some View {
        // Change textColor depending on current theme
        let textColor = colorScheme == .dark ? Color.white: Color.black
        
        VStack {
            HStack {
                MenuIconView()
                Spacer()
                Text("Metronome")
                    .font(.title)
                    .fontWeight(.light)
                    .padding(10)
                Spacer()
                ThemeChangerView()
                
            }
            
            Spacer()
            ChangeSoundView()
            Spacer()
            BeatView()
            Spacer()
            PlayView()
            TempoMarkingView()
            
            HStack {
                
                Spacer()
                TimeSigView()
                Spacer()
                Spacer()
                TempoView()
                Spacer()

            }
            Spacer()
        }

        .foregroundColor(textColor)
        .background(Color("BackgroundColour"))
    }
}

struct PlayerViewPreviews: PreviewProvider {
    static var previews: some View {
        // Assuming Metronome is an ObservableObject and it is properly initialized here
        let metronome = Metronome()

        PlayerView()
            .environmentObject(metronome) // Provide the Metronome object to the environment
    }
}

