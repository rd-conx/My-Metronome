//
//  AddNewPresetView.swift
//  Metronome
//
//  Created by Ross Conquer on 20/08/2024.
//

import Foundation
import SwiftUI

struct AddNewPresetAlert: View {
    
    @EnvironmentObject var metronome: Metronome
    @Binding var showPresetAddAlert: Bool
    @Environment(\.colorScheme) var colorScheme
    
    @State var newPresetName: String = ""
    @State var givenPresetName: String = ""
    
    var body: some View {
        
        let foregroundColor = colorScheme == .dark ? Color.white : Color.black
        
        VStack {
            TextField("\(createNewPresetName())", text: $givenPresetName)
                .foregroundStyle(foregroundColor)
            HStack {
                Button("Cancel", action: {
                    showPresetAddAlert = false
                })
                Button("Submit", action: {
                    addNewPreset(givenPresetName)
                    showPresetAddAlert = false
                })
                .padding()
            }
        }
    }
    
    private func createNewPresetName() -> String {
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
    
    private func addNewPreset(_ name: String) {
        var newPresetName: String = ""
        
        if (name.isEmpty) {
            newPresetName = createNewPresetName()
        } else {
            newPresetName = name
        }
        
        // Record current config of beat accents
        let currentBeatAccents = metronome.bufferAccents.settings
        
        // get orderIndex of last preset in users saved presets
        var newIndex = 0
        if let lastPreset = metronome.bufferAccents.currentPresets.last {
            let lastOrderIndex = lastPreset.orderIndex
            newIndex = lastOrderIndex + 1
        }
        
        //  Create preset with new settings
        let newPreset = AccentArray.Preset(orderIndex: newIndex, name: newPresetName, array: currentBeatAccents)
        
        // Add to list of currentPresets, as a new preset with name
        metronome.bufferAccents.currentPresets.append(newPreset)
        
        // make current prests persistant
        metronome.storeCurrentPresetsInDefaults()
        
        metronome.checkArrayCopyOfSaved()
        
        // Ensure buffers are cleared for next invocation
        clearNames()
    }
    
    private func clearNames() {
        newPresetName = ""
        givenPresetName = ""
    }
    
}

