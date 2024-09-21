//
//  AddNewPreset.swift
//  Metronome
//
//  Created by Ross Conquer on 30/08/2024.
//

import Foundation

class NewPresetNamePublisher: ObservableObject {
    
    @Published var newPresetName = ""
    
    init() {
        updateNewPresetName()
    }
    
    func updateNewPresetName() {
        newPresetName = chooseNewPresetName()
    }
    
    private func chooseNewPresetName() -> String {
        // Get orderIndex of last preset in current list
        guard let lastPreset = metronome.bufferAccents.currentPresets.last else {
            print("No preset found for: \(metronome.timeSig)")
            return ""
        }
        let lastIndex = lastPreset.orderIndex
        var newPresetName = "My Preset " + String(lastIndex + 1)
        if metronome.bufferAccents.currentPresets.map( { $0.name }).contains(newPresetName) {
            newPresetName += "_1"
        }
        return newPresetName
    }
}
