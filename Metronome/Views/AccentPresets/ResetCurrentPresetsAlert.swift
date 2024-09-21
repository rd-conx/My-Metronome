//
//  ResetCurrentPresetsAlert.swift
//  Metronome
//
//  Created by Ross Conquer on 19/08/2024.
//

import SwiftUI

struct ResetCurrentPresetsAlert: View {
    
    @EnvironmentObject var metronome: Metronome
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Binding var presentPresetResetAlert: Bool
    
    var body: some View {
        
        Button("Cancel", action: {
            presentPresetResetAlert = false
        })
        Button("This Time Signature", action: {
            resetCurrentTimeSigPresets()
        })
        Button("For all Time Signatures", action: {
            resetAllTimeSigPresets()
        })
    }
    
    private func resetCurrentTimeSigPresets() {
        // Load default accent presets for current time sig
        metronome.bufferAccents.currentPresets = metronome.loadAllAccentPresetsForTimeSig(timeSig: metronome.timeSig[0], useDefault: true)
        
        // Ensure changes persist
        metronome.storeCurrentPresetsInDefaults()

        // remove users chosen preset for current time sig
        metronome.userChosenPresetVariations[metronome.timeSig[0]] = AccentArray.DEFAULT_PRESET_VARIATION[metronome.timeSig[0]]
        settingsManager.userChosenPresetVariations = metronome.userChosenPresetVariations
        
        // remove users current accent config for current time sig
        metronome.userCurrentAccentConfig[String(metronome.timeSig[0])] = []
        settingsManager.userCurrentAccentConfig = metronome.userCurrentAccentConfig
        
        metronome.initClickSet(clickSetName: metronome.currentSound)
    }
    
    private func resetAllTimeSigPresets() {
        // load default accent presets for all time sigs
        for key in 1...metronome.userAccentPresets.count {
            metronome.userAccentPresets[key] = metronome.loadAllAccentPresetsForTimeSig(timeSig: key, useDefault: true)
        }
        
        // refresh class variable for current presets
        if let currentPresets = metronome.userAccentPresets[metronome.timeSig[0]] {
            metronome.bufferAccents.currentPresets = currentPresets
        }
        
        // ensure all time sig presets persist
        settingsManager.userAccentPresets = metronome.userAccentPresets
        
        // reset to defaults for all time sigs
        metronome.userChosenPresetVariations = AccentArray.DEFAULT_PRESET_VARIATION
        settingsManager.userChosenPresetVariations = metronome.userChosenPresetVariations
        
        // remove for all time sigs
        metronome.userCurrentAccentConfig.removeAll()
        settingsManager.userCurrentAccentConfig = metronome.userCurrentAccentConfig
        
        metronome.initClickSet(clickSetName: metronome.currentSound)
        
    }
}

//#Preview {
//    ResetCurrentPresetsAlert()
//}
