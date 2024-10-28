//
//  SettingsMenu.swift
//  Metronome
//
//  Created by Ross Conquer on 05/08/2024.
//

import SwiftUI

struct SettingsMenuView: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var gradientManager: GradientManager
    @EnvironmentObject var soundManager: SoundManager
    
//    @State var selectedTheme: CustomColorScheme = CustomColorScheme.defaultValue
    @State var selectedTheme: ColorScheme = .light
    @State var selectedGradient: Color = .clear
    @State var selectedSound: SoundOption = .defaultValue
    @State var selectedHelperOption: HideHelperOptions = .show
    @State var selectedTempoChangeSpeedOption: TempoChangeSpeedOptions = .normal
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showResetAlert = false
    
    @State private var selectedSoundChangedViaClick = false
    @State private var selectedSoundChangedViaOnChange = false
    
    let docsLink = "https://www.rossconquer.dev/mymetronome?section=docsSettingsMenu"
    
    var body: some View {
        
        let textColor: Color = colorScheme == .light ? .black : .white
        
        Menu {
            Menu {
                Picker("Theme", selection: $selectedTheme) {
//                    Text("System (default)").tag(CustomColorScheme.system)
                    Text("Light").tag(ColorScheme.light)
                    Text("Dark").tag(ColorScheme.dark)
                }
                .onAppear {
                    guard let theme = settingsManager.chosenColorScheme else {
                        selectedTheme = DEFAULT_THEME
                        return
                    }
                    selectedTheme = theme
                }
                .onChange(of: selectedTheme) { oldValue, newValue in
                    settingsManager.chosenColorScheme = newValue
                    print(newValue)
                    settingsManager.storeColorScheme()
                    
                    // Gradient
                    gradientManager.setGradient(gradient: gradientManager.decideGradient())
//                    print("gradient: \(gradientManager.gradient ?? .clear)")
                    selectedGradient = gradientManager.gradient ?? .clear
                }
            } label: {
                Label("Theme", systemImage: "globe.europe.africa.fill")
            }
            
            Menu {
                Picker("Colour", selection: $selectedGradient) {
                    Text("Clear (default)").tag(Color.clear)
                    ForEach(gradientManager.listToUse, id: \.self) { color in
                        Text("\(settingsManager.colorToTitleCaseString[color] ?? "Null")")
                    }
                }
                .onAppear {
                    selectedGradient = gradientManager.decideGradient()
                }
                .onChange(of: selectedGradient) {
                    gradientManager.setGradient(gradient: selectedGradient)
                }
                .onChange(of: gradientManager.gradient) {
                    if let gradient = gradientManager.gradient {
                        selectedGradient = gradient
                    }
                }
            } label: {
                Label("Colour", systemImage: "paintpalette.fill")
            }

            Menu {
                Picker("Sound", selection: $selectedSound) {
                    Text(MetronomeConstants.DEFAULT_CLICK_DISPLAY_NAME()).tag(SoundOption.block)
                    Text(MetronomeConstants.SECONDARY_CLICK_DISPLAY_NAME()).tag(SoundOption.click)
                }
                .onAppear {
                    selectedSound = soundManager.getCurrentClickSound()
                }
                .onChange(of: selectedSound) {
                    if selectedSound != settingsManager.clickSound && !selectedSoundChangedViaOnChange {
                        print("selected sound")
                        selectedSoundChangedViaClick = true
                        soundManager.setCurrentSound(clickSoundChoice: selectedSound)
                    }
                    
                    // change bool after delay to allow each onChange to detect bools in correct state.
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        selectedSoundChangedViaClick = false
                    }
                }
                .onChange(of: settingsManager.clickSound) {oldValue, newValue in
                    if selectedSound != newValue && !selectedSoundChangedViaClick {
                        selectedSoundChangedViaOnChange = true
                        selectedSound = newValue
                    }
                    
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        selectedSoundChangedViaOnChange = false
                    }
                }
            } label: {
                Label("Sound", systemImage: "metronome.fill")
            }
            
            Menu {
                Picker("Helper", selection: $selectedHelperOption) {
                    Text(HideHelperOptions.show.rawValue).tag(HideHelperOptions.show)
                    Text(HideHelperOptions.hide.rawValue).tag(HideHelperOptions.hide)
                }
            } label: {
                Label("Helper", systemImage: "questionmark.circle")
            }
            .onAppear {
                selectedHelperOption = settingsManager.getStoredHelperOption()
            }
            .onChange(of: selectedHelperOption) {
                settingsManager.setHelperOption(selectedHelperOption)
            }
            .onChange(of: settingsManager.hideHelper) { oldValue, newValue in
                selectedHelperOption = newValue == true ? .hide : .show
            }
            
            Menu {
                Picker("Tempo Change", selection: self.$selectedTempoChangeSpeedOption) {
//                    Text("When increasing from below 120 BPM.").italic()
                    Text(TempoChangeSpeedOptions.normal.rawValue).tag(TempoChangeSpeedOptions.normal)
                    Text(TempoChangeSpeedOptions.fast.rawValue).tag(TempoChangeSpeedOptions.fast)
                }
            } label: {
                Label("Tempo change", systemImage: "gearshift.layout.sixspeed")
            }
            .onAppear {
                self.selectedTempoChangeSpeedOption = settingsManager.getStoredTempoSpeedOption()
            }
            .onChange(of: self.selectedTempoChangeSpeedOption) {
                settingsManager.setTempoChangeSpeedOption(selectedTempoChangeSpeedOption)
            }
            .onChange(of: metronome.quickTempoChangeFromSlow) { oldValue, newValue in
                self.selectedTempoChangeSpeedOption = newValue
            }
            
            Button("Help!", action: {
                if let url = URL(string: docsLink) {
                    UIApplication.shared.open(url)
                }})
            
            
            Button("Reset settings") {
                // Show are you sure popover
                showResetAlert = true
            }
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 21, weight: .light))
                .tint(textColor)
                .frame(width: 30, height: 50) // give larger touchbox
        }
        .alert(
            "Reset settings",
            isPresented: $showResetAlert) {
                Button(role: .destructive) {
                    settingsManager.resetAllToDefaults()
                } label: {
                    Text("Reset")
                }
            } message: {
                Text("Are you sure?\nThis will not remove any saved presets.")
            }
    }
}

#Preview {
    SettingsMenuView()
}
