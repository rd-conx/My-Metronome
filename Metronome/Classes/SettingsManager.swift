//
//  SettingsManager.swift
//  Metronome
//
//  Created by Ross Conquer on 03/08/2024.
//

import Foundation
import SwiftUI

let DEFAULT_THEME: ColorScheme = .light

extension UserDefaults {
    
    enum Keys: String, CaseIterable {
        
        case appTheme = "AppTheme"
        case gradientLight = "GradientLight"
        case gradientDark = "GradientDark"
        case sound = "ClickSound"
        case helper = "Helper"
        case currentAccents = "CurrentAccents"
        case accentPresets = "AccentPresets"
        case chosenPresets = "ChosenPresets"
        case timeSignature = "TimeSignature"
        case tempo = "Tempo"
        case tempoChangeFromSlow = "TempoChangeFromSlow"
    }
    
    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue)}
    }
}


class SettingsManager: ObservableObject {
    
    private let backgroundThread = DispatchQueue.global(qos: .userInitiated)
    
    private let defaults = UserDefaults.standard
    private let THEME_KEY = UserDefaults.Keys.appTheme.rawValue
    private let GRADIENT_LIGHT_KEY = UserDefaults.Keys.gradientLight.rawValue
    private let GRADIENT_DARK_KEY = UserDefaults.Keys.gradientDark.rawValue
    private let SOUND_KEY = UserDefaults.Keys.sound.rawValue
    private let HELPER_KEY = UserDefaults.Keys.helper.rawValue
    private let CURRENT_ACCENTS = UserDefaults.Keys.currentAccents.rawValue
    private let ACCENT_PRESETS_KEY = UserDefaults.Keys.accentPresets.rawValue
    private let CHOSEN_PRESETS_KEY = UserDefaults.Keys.chosenPresets.rawValue
    private let TIME_SIG_KEY = UserDefaults.Keys.timeSignature.rawValue
    private let TEMPO_KEY = UserDefaults.Keys.tempo.rawValue
    private let TEMPO_CHANGE_FROM_SLOW = UserDefaults.Keys.tempoChangeFromSlow.rawValue
    
    @Published var chosenColorScheme: ColorScheme? = nil
    
    @Published var hideHelper: Bool = false
    @Published var tempoChangeFast: Bool = false
    
    init() {
        getStoredColorScheme()
        hideHelper = getStoredHelperOption() == .hide ? true : false
        tempoChangeFast = getStoredTempoSpeedOption() == .fast ? true : false
    }
    
    func storeColorScheme() {
        defaults.set(chosenColorScheme == .light ? "light" : "dark", forKey: THEME_KEY)
    }
    
    func getStoredColorScheme() {
        guard let rawValue: String = defaults.string(forKey: THEME_KEY) else {
            print("Color Scheme not stored, or error occurred. Defaulting to \(DEFAULT_THEME)")
            chosenColorScheme = DEFAULT_THEME
            return
        }
        chosenColorScheme = rawValue == "dark" ? ColorScheme.dark : ColorScheme.light
    }
    
    func getStoredHelperOption() -> HideHelperOptions {
        return HideHelperOptions(rawValue: defaults.string(forKey: HELPER_KEY) ?? HideHelperOptions.show.rawValue) ?? HideHelperOptions.show
    }
    
    func setHelperOption(_ helperOption: HideHelperOptions) {
        self.hideHelper = helperOption == .hide ? true : false
        defaults.set(helperOption.rawValue, forKey: HELPER_KEY)
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
        get { return SoundOption(rawValue: defaults.string(forKey: SOUND_KEY) ?? SoundOption.defaultValue.rawValue)! }
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
//                    print("set new chosenPresetVariation: \(newValue[12]!.array)")
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
       
        // Reset Colour
        self.gradientLight = .clear
        self.gradientDark = .clear
        gradientManager.gradient = .clear
        
        // Reset Sound
        soundManager.setCurrentSound(clickSoundChoice: SoundOption.defaultValue)
        
        // Reset Helper
        setHelperOption(HideHelperOptions.show)
        
        setTempoChangeSpeedOption(.normal)
        
        // set load default click set
        metronome.initClickSet(clickSetName: MetronomeConstants.DEFAULT_CLICK_NAME)
        
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
