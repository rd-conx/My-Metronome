//
//  ContentView.swift
//  Metronome
//
//  Created by Ross Conquer on 28/11/2023.
//

import SwiftUI

struct MetronomeView: View {
    
    @EnvironmentObject var metronome: Metronome
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var gradientManager: GradientManager
    @EnvironmentObject var opacities: Opacities
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    // To get visual ticks
    @State private var currentBar: Int = 0
    @State private var currentBeat: Int = 0
    
    @State private var showAccentMenu: Bool = false
    @State private var newPreset: String = ""
    @State private var tempoVisible = true
    @State private var tempoOrTimeSigSelection: tempoOrTimeSig = .tempo
    
    var body: some View {
        
        
        VStack {
            TopScreenView()
                .environmentObject(metronome.ticker)
                .opacity(opacities.topScreenView)
                .padding(.bottom, self.deviceScreen.componentSizing[.topScreenBttmPad])
            Spacer(minLength: self.deviceScreen.componentSizing[.topScreenAndBeatsSpacer])
            ZStack {
                BeatView(currentBeat: $currentBeat)
                    .environmentObject(metronome.ticker)
                    .simultaneousGesture(TapGesture(count: 2).onEnded {
                        self.performShowAccentMenu()
                    })
                    .opacity(opacities.beatView)
                    .animation(.default, value: opacities.beatView)
//                    .padding(.top, deviceScreen.size.height * 0.04)
                    .padding(.top, self.deviceScreen.componentSizing[.beatViewTopPad])
                AccentPresetMenuView(showAccentMenu: $showAccentMenu)
                    .opacity(opacities.presetMenu)
                    .animation(.default, value: opacities.presetMenu)
                    .offset(y: self.deviceScreen.componentSizing[.accentPresetMenuViewOffsetY]!)
                    .frame(maxWidth: self.deviceScreen.componentSizing[.presetMenuMaxWidth])
                
                VStack {
                    
                    Spacer(minLength: self.deviceScreen.componentSizing[.accentPresetMenuViewAndPlayViewSpacer])
                    PlayView(currentBar: $currentBar, currentBeat: $currentBeat)
                        .opacity(opacities.playView)

                    TempoMarkingView()
                        .opacity(opacities.tempoMarkingView)
                    
                    ZStack {
                        TempoView()
                            .opacity(opacities.tempoView)
                        TimeSigView()
                            .opacity(opacities.timeSigView)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                    Picker("", selection: $tempoOrTimeSigSelection) {
                        Text("Tempo").tag(tempoOrTimeSig.tempo)
                        Text("Time Signature").tag(tempoOrTimeSig.timeSig)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: tempoOrTimeSigSelection) {
                        self.switchTempoAndTimeSig()
                    }
                    .frame(maxWidth: self.deviceScreen.componentSizing[.tempoTimeSigPickerFrameMaxWidth])
                    .padding(.bottom, 5)
                    .opacity(opacities.tempoOrTimeSigSelector)
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [gradientManager.gradient ?? .clear, .clear]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
                .opacity(0.8)
        )
    }
    
    private func performShowAccentMenu() {
        self.showAccentMenu = true
        withAnimation(.easeInOut) {
            opacities.beatView = 0.0
            opacities.presetMenu = 1.0
            opacities.playView = 0.0
            opacities.tempoMarkingView = 0.0
        }
    }
    
    private func performHideAccentMenu() {
        self.showAccentMenu = false
        withAnimation(.easeInOut) {
            opacities.beatView = 1.0
            opacities.presetMenu = 0.0
            opacities.playView = 1.0
            opacities.tempoMarkingView = 1.0
        }
    }
    
    private func switchTempoAndTimeSig() {
        if tempoVisible {
            opacities.tempoView = 0.0
            opacities.timeSigView = 1.0
            tempoVisible = false
        } else {
            opacities.tempoView = 1.0
            opacities.timeSigView = 0.0
            tempoVisible = true
        }
    }
}


struct MetronomeViewPreviews: PreviewProvider {
    static var previews: some View {
        // Assuming Metronome is an ObservableObject and it is properly initialized here
        let metronome = Metronome()
        
        let settingsManager = SettingsManager()
        let gradientManager = GradientManager()
        let soundManager = SoundManager()
        
        let opacities = Opacities()
        
        let deviceScreen = DeviceScreen()

        MetronomeView()
            .environmentObject(metronome) // Provide the Metronome object to the environment
            .environmentObject(settingsManager)
            .environmentObject(gradientManager)
            .environmentObject(soundManager)
            .environmentObject(opacities)
            .environmentObject(deviceScreen)
    }
}
