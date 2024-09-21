//
//  AccentPresetMenuView.swift
//  Metronome
//
//  Created by Ross Conquer on 08/08/2024.
//
//

import SwiftUI

struct AccentPresetMenuView: View {
    
    @EnvironmentObject var metronome: Metronome
    
    @Binding var showAccentMenu: Bool
    
    @EnvironmentObject var opacities: Opacities
    
    @State private var presentPresetNameChangeAlert = false
    @State private var presentPresetResetAlert = false
    @State private var showPresetAddAlert = false
    @State private var showPresetAlreadyExistsAlert = false
    @State private var presetToEdit = ""
    @State private var givenPresetName = ""
    @State private var nameOfPresetThatExists = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
                
        VStack {
            AccentPresetMenuToolbar(presentPresetResetAlert: $presentPresetResetAlert, showAccentMenu: $showAccentMenu)
            PresetsListView(showAccentMenu: $showAccentMenu, presentPresetNameChangeAlert: $presentPresetNameChangeAlert, showPresetAddAlert: $showPresetAddAlert, showPresetAlreadyExistsAlert: $showPresetAlreadyExistsAlert, presetToEdit: $presetToEdit, givenPresetName: $givenPresetName, nameOfPresetThatExists: $nameOfPresetThatExists)
            // masks for fade at bottom of list. (more blacks tighter the fade)
                .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .black, .black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                .scrollContentBackground(.hidden)
            Spacer()
            .onChange(of: showAccentMenu) {
                    handleAccentMenuChange()
                }
            .alert("Change Preset Name", isPresented: $presentPresetNameChangeAlert, actions: {
                ChangePresetNameAlert(presetToEdit: $presetToEdit, givenPresetName: $givenPresetName, presentPresetNameChangeAlert: $presentPresetNameChangeAlert)
                    .environmentObject(metronome)
            }, message: {
                Text("Renaming '\(presetToEdit)'")
            })
            .alert("Reset current presets", isPresented: $presentPresetResetAlert, actions: {
                ResetCurrentPresetsAlert(presentPresetResetAlert: $presentPresetResetAlert)
            }, message: {
                Text("Reset all presets for this time signature?\nThis action cannot be undone!")
            })
            .alert("Preset '\(nameOfPresetThatExists)' already uses the current beat accent configuration", isPresented: $showPresetAlreadyExistsAlert, actions: {
                Button("Ok") { showPresetAlreadyExistsAlert = false }
            }, message: {
            })
            .alert("Add new preset, using current configuration", isPresented: $showPresetAddAlert, actions: {
                AddNewPresetAlert(showPresetAddAlert: $showPresetAddAlert)
            }, message: {
                Text("Choose a name for your new preset.")
            })
        }
        .tint(colorScheme == .light ? .black : .white)
    }
    
    private func handleAccentMenuChange() {
        if !showAccentMenu {
            opacities.beatView = 1.0
            opacities.presetMenu = 0.0
        }
    }
    
}


//#Preview {
//    AccentPresetMenuView()
//}
