//
//  SettingsManager.swift
//  Metronome
//
//  Created by Ross Conquer on 03/08/2024.
//

import Foundation
import SwiftUI 

class SettingsManager: ObservableObject {
    
    private let backgroundThread = DispatchQueue.global(qos: .userInitiated)
    
    private let defaults = UserDefaults.standard
    private let THEME_KEY = "AppTheme"
    private let GRADIENT_LIGHT_KEY = "GradientLight"
    private let GRADIENT_DARK_KEY = "GradientDark"
    private let SOUND_KEY = "ClickSound"
    private let HELPER_KEY = "Helper"
    private let CURRENT_ACCENTS = "CurrentAccents"
    private let ACCENT_PRESETS_KEY = "AccentPresets"
    private let CHOSEN_PRESETS_KEY = "ChosenPresets"
    private let TIME_SIG_KEY = "TimeSignature"
    private let TEMPO_KEY = "Tempo"
    private let TEMPO_CHANGE_FROM_SLOW = "slowTempoChange"
    
    @Published var customColorScheme: CustomColorScheme = CustomColorScheme.defaultValue
    
    @Published var hideHelper: Bool = false
    @Published var tempoChangeFast: Bool = false
    
    init() {
        getStoredColorScheme()
        hideHelper = getStoredHelperOption() == .hide ? true : false
        tempoChangeFast = getStoredTempoSpeedOption() == .fast ? true : false
    }
    
    func processThemeButton(_ colorScheme: CustomColorScheme) {
        self.customColorScheme = colorScheme
        self.setColorSchemeToStore()
        gradientManager.setGradient(gradient: gradientManager.decideGradient())
    }
    
    func setColorSchemeToStore() {
        defaults.set(customColorScheme.rawValue, forKey: CustomColorScheme.defaultKey)
    }
    
    func getStoredHelperOption() -> HideHelperOptions {
        return HideHelperOptions(rawValue: defaults.string(forKey: HELPER_KEY) ?? HideHelperOptions.show.rawValue) ?? HideHelperOptions.show
    }
    
    func setHelperOption(_ helperOption: HideHelperOptions) {
        self.hideHelper = helperOption == .hide ? true : false
        defaults.set(helperOption.rawValue, forKey: HELPER_KEY)
    }

    
    func getStoredColorScheme() {
        let rawValue: Int = defaults.integer(forKey: CustomColorScheme.defaultKey)
        customColorScheme = CustomColorScheme(rawValue: rawValue) ?? CustomColorScheme.defaultValue
    }
    

   
    var gradientLight: Color {
        get { return stringToColor[defaults.string(forKey: GRADIENT_LIGHT_KEY) ?? "clear"]! }
        set { defaults.set(colorToString[newValue], forKey: GRADIENT_LIGHT_KEY) }
    }
    
    var gradientDark: Color {
        get { return stringToColor[defaults.string(forKey: GRADIENT_DARK_KEY) ?? "clear"]! }
        set { defaults.set(colorToString[newValue], forKey: GRADIENT_DARK_KEY) }
    }
    
    var clickSound: SoundOption {
        get { return SoundOption(rawValue: defaults.string(forKey: SOUND_KEY) ?? "click")! }
        set { defaults.set(newValue.rawValue, forKey: SOUND_KEY) }
    }
    
    var tempo: Double {
        get {
            let storedTempo = defaults.double(forKey: TEMPO_KEY)
            // return value will be 0.0 if nothing stored
            if storedTempo == 0.0 { return MetronomeConstants.DEFAULT_BPM }
            return storedTempo
        }
        set { defaults.set(newValue, forKey: TEMPO_KEY) }
    }
    
    var timeSignature: [Int] {
        get { return defaults.array(forKey: TIME_SIG_KEY) as? [Int] ?? MetronomeConstants.DEFAULT_TIME_SIG }
        set { defaults.set(newValue, forKey: TIME_SIG_KEY) }
    }
    
    var usedDefaultForUserAccentPresets = false
    
    // Store and return regular dictionary, convert into AccentArray.preset
    var userAccentPresets: [Int: [AccentArray.Preset]] {
        get {
            backgroundThread.sync {
                if let storedData = defaults.value(forKey: ACCENT_PRESETS_KEY) {
                    do {
                        let decodedPresets = try JSONDecoder().decode([Int: [AccentArray.Preset]].self, from: storedData as! Data)
                        if decodedPresets.isEmpty {
                            print("Stored user accent presets is empty")
                            usedDefaultForUserAccentPresets = true
                            return AccentArray.ALL_PRESETS
                        } else if decodedPresets.count != 16 {
                            print("Stored user accent presets did not total 16 keys (== number of time sigs)")
                            // Ensure saved dictionary contains all key value pairs
                            usedDefaultForUserAccentPresets = true
                            return AccentArray.ALL_PRESETS
                        }
                        return decodedPresets
                    } catch {
                        print("Failed to decode UserAccentPresets: \(error.localizedDescription)")
                        print("Returning default presets array")
                        usedDefaultForUserAccentPresets = true
                        return AccentArray.ALL_PRESETS
                    }
                }
                print("Stored user accent presets does not exist")
                usedDefaultForUserAccentPresets = true
                return AccentArray.ALL_PRESETS
            }
        }
        set {
            backgroundThread.async {
                do {
                    let encodedPresets = try JSONEncoder().encode(newValue)
                    self.defaults.set(encodedPresets, forKey: self.ACCENT_PRESETS_KEY)
                } catch {
                    print("Failed to encode userAccentPresets: \(error.localizedDescription)")
                }
            }
     
        }
    }
    
    var usedDefaultsForUserChosenPresetVariations = false
    
    var userChosenPresetVariations: [Int: AccentArray.Preset] {
        get {
            backgroundThread.sync {
                if let storedData = defaults.value(forKey: CHOSEN_PRESETS_KEY) {
                    do {
                        let decodedPresets = try JSONDecoder().decode([Int: AccentArray.Preset].self, from: storedData as! Data)
                        if decodedPresets.isEmpty {
                            print("stored presets is empty, returning default preset variations")
                            usedDefaultsForUserChosenPresetVariations = true
                            return AccentArray.DEFAULT_PRESET_VARIATION
                        }
                        return decodedPresets
                    } catch {
                        print("Failed to decode chosenPresetVariation: \(error.localizedDescription)")
                        print("Returning all default preset variations.")
                        usedDefaultsForUserChosenPresetVariations = true
                        return AccentArray.DEFAULT_PRESET_VARIATION
                    }
                }
                print("stored chosenPresetVariation data does not exist, returning default preset variations.")
                usedDefaultsForUserChosenPresetVariations = true
                return AccentArray.DEFAULT_PRESET_VARIATION
            }
        }
        set {
            backgroundThread.async {
                do {
                    let encodedPresets = try JSONEncoder().encode(newValue)
                    self.defaults.set(encodedPresets, forKey: self.CHOSEN_PRESETS_KEY)
                } catch {
                    print("Failed to encode chosenPresetVariation.")
                }
            }
        }
    }
    
    var userCurrentAccentConfig: [String: [String]] {
        get {
            if let storedData = defaults.dictionary(forKey: CURRENT_ACCENTS) as? [String: [String]] {
                return storedData
            }
            return [:]
        }
        set { defaults.set(newValue, forKey: CURRENT_ACCENTS) }
    }
    
    func getStoredTempoSpeedOption() -> TempoChangeSpeedOptions {
        return quickTempoChangeFromSlow == 1 ? .normal : .fast
    }
    
    func setTempoChangeSpeedOption(_ selectedTempoChangeSpeedOption: TempoChangeSpeedOptions) {
        self.tempoChangeFast = selectedTempoChangeSpeedOption == .normal ? false : true
        metronome.quickTempoChangeFromSlow = selectedTempoChangeSpeedOption
        self.quickTempoChangeFromSlow = selectedTempoChangeSpeedOption == .normal ? 1 : 2
    }
    
    var quickTempoChangeFromSlow: Int {
        get {
            let storedValue = defaults.integer(forKey: TEMPO_CHANGE_FROM_SLOW)
            if storedValue == 0 {
                return 1
            } else {
                return storedValue
            }
        }
        set { defaults.set(newValue, forKey: TEMPO_CHANGE_FROM_SLOW) }
    }
   
    func resetAllToDefaults() {
        // Stop metronome
        if metronome.isPlaying {
            metronome.pressPlayStopButton()
        }
                
        // Reset theme
        customColorScheme = CustomColorScheme.defaultValue
        setColorSchemeToStore()
        
        // Reset Colour
        self.gradientLight = .clear
        self.gradientDark = .clear
        gradientManager.gradient = .clear
        
        // Reset Sound
        soundManager.setCurrentSound(clickSoundChoice: SoundOption.defaultValue)
        
        // Reset Helper
//        self.hideHelper = false
        setHelperOption(HideHelperOptions.show)
//        setHelperOption()
        
        setTempoChangeSpeedOption(.normal)
        
        // set load default click set
        metronome.initClickSet(clickSetName: MetronomeConstants.DEFAULT_CLICK_NAME)
        
        // check 
        metronome.checkArrayCopyOfSaved()
        
    }
    
    private let colorToString: [Color: String] = [
        .blue: "blue",
        .brown: "brown",
        .clear: "clear",
        .cyan: "cyan",
        .gray: "gray",
        .green: "green",
        .indigo: "indigo",
        .mint: "mint",
        .orange: "orange",
        .pink: "pink",
        .purple: "purple",
        .red: "red",
        .teal: "teal",
        .yellow: "yellow"
    ]
    
    let colorToTitleCaseString: [Color: String] = [
        .blue: "Blue",
        .brown: "Brown",
        .clear: "Clear",
        .cyan: "Cyan",
        .gray: "Gray",
        .green: "Green",
        .indigo: "Indigo",
        .mint: "Mint",
        .orange: "Orange",
        .pink: "Pink",
        .purple: "Purple",
        .red: "Red",
        .teal: "Teal",
        .yellow: "Yellow"
    ]

    private let stringToColor: [String: Color] = [
        "blue": .blue,
        "brown": .brown,
        "clear": .clear,
        "cyan": .cyan,
        "gray": .gray,
        "green": .green,
        "indigo": .indigo,
        "mint": .mint,
        "orange": .orange,
        "pink": .pink,
        "purple": .purple,
        "red": .red,
        "teal": .teal,
        "yellow": .yellow
    ]
}
