//
//  TopScreenView.swift
//  Metronome
//
//  Created by Ross Conquer on 06/08/2024.
//

import SwiftUI

struct TopScreenView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var metronome: Metronome
    @EnvironmentObject private var ticker: MetronomeTicker
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    var body: some View {
        
        let textColor: Color = colorScheme == .light ? .black : .white
        
        ZStack {
            HStack {
                SettingsMenuView()
                .padding(.leading, 10)
                Spacer()
            }
            HStack {
                Spacer()
                Image(systemName: "metronome")
                    .font(.system(size: 40, weight: .regular))
                    .padding(10)
                Spacer()
            }
            HStack {
                Spacer()
                Menu {
                    Button("Tap or rotate the tempo knob to set a tempo") {}
                    Button("Swipe up and down on beats to change accents") {}
                    Button("Double tap any beat to set an accent preset") {}
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 21, weight: .light))
                        .padding(.trailing, 15)
                        .tint(textColor)
                        .opacity(settingsManager.hideHelper == true ? 0.0 : 1.0)
                }
                .disabled(settingsManager.hideHelper)
            }
        }
    }
}

#Preview {
    TopScreenView()
}
