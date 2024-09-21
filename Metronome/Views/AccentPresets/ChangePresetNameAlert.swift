//
//  ChangePresetNameView.swift
//  Metronome
//
//  Created by Ross Conquer on 19/08/2024.
//

import SwiftUI

struct ChangePresetNameAlert: View {
    
    @EnvironmentObject var metronome: Metronome

    @Binding var presetToEdit: String
    @Binding var givenPresetName: String
    @Binding var presentPresetNameChangeAlert: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ScrollView {
            TextField("\(presetToEdit)", text: Binding<String>(
                get: {
                    return givenPresetName
                },
                set: { (newValue: String) in
                    givenPresetName = newValue
                }
                ))
            .foregroundStyle(.black)
            Button("Cancel", action: {
                resetEditingState()
            })
            Button("Submit", action: {
                submitPresetNameChange()
                resetEditingState()
            })
        }
    }
    
    private func resetEditingState() {
        presetToEdit = ""
        givenPresetName = ""
        presentPresetNameChangeAlert = false
    }
    
    private func submitPresetNameChange() {
        if let indexOfPresetUserIsEditing = metronome.bufferAccents.currentPresets.firstIndex(where: { $0.name == presetToEdit }) {
            // Check if given name is same as pre-existing preset
            if let identicalPresetIndex = metronome.bufferAccents.currentPresets.firstIndex(where: { $0.name == givenPresetName }) {
                print("Name is identical to preset: \(metronome.bufferAccents.currentPresets[identicalPresetIndex])")
                return
            } else {
                print("Name is unique")
            }
            
            metronome.bufferAccents.currentPresets[indexOfPresetUserIsEditing].name = givenPresetName
            metronome.storeCurrentPresetsInDefaults()
        } else {
            print("No name change submited. No match found for '\(presetToEdit)'")
        }
        resetEditingState()
    }
}

//#Preview {
//    ChangePresetNameView()
//}
