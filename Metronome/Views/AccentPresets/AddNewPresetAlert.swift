//
//  AddNewPresetView.swift
//  Metronome
//
//  Created by Ross Conquer on 20/08/2024.
//

import SwiftUI

struct AddNewPresetAlert: View {
    
    @EnvironmentObject var metronome: Metronome
    
    @ObservedObject var newPresetNamePublisher = NewPresetNamePublisher()

    @Binding var showPresetAddAlert: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        let foregroundColor = colorScheme == .dark ? Color.white : Color.black
        
        VStack {
            TextField("\(newPresetNamePublisher.newPresetName)", text: $newPresetNamePublisher.newPresetName)
                .foregroundStyle(foregroundColor)
            HStack {
                Button("Cancel", action: {
                    showPresetAddAlert = false
                })
                Button("Submit", action: {
                    addNewPreset()
                    showPresetAddAlert = false
                })
                .disabled(newPresetNamePublisher.newPresetName.isEmpty)
                .padding()
            }
        }
        .onChange(of: metronome.bufferAccents.currentPresets) {
            newPresetNamePublisher.updateNewPresetName()
        }
    }
    
    private func addNewPreset() {
        if newPresetNamePublisher.newPresetName.isEmpty {
            print("newPresetName was empty - did not create new preset")
            return
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
        let newPreset = AccentArray.Preset(orderIndex: newIndex, name: newPresetNamePublisher.newPresetName, array: currentBeatAccents)
        
        // Add to list of currentPresets, as a new preset with name
        metronome.bufferAccents.currentPresets.append(newPreset)
        
        // make current prests persistant
        metronome.storeCurrentPresetsInDefaults()
        
        metronome.checkArrayCopyOfSaved()

    }
    
}

//#Preview {
//    AddNewPresetAlert()
//}
