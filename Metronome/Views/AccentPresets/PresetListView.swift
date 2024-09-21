//
//  PresetsView.swift
//  Metronome
//
//  Created by Ross Conquer on 19/08/2024.
//

import SwiftUI

struct PresetsListView: View {
    
    @EnvironmentObject var metronome: Metronome
    
    @Binding var showAccentMenu: Bool
    @Binding var presentPresetNameChangeAlert: Bool
    @Binding var showPresetAddAlert: Bool
    @Binding var showPresetAlreadyExistsAlert: Bool
    
    @EnvironmentObject var opacities: Opacities
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    @Binding var presetToEdit: String
    @Binding var givenPresetName: String
    @Binding var nameOfPresetThatExists: String
   
    var body: some View {
        
        List {
            Section(header: Spacer(minLength: 0).listRowInsets(EdgeInsets())) {
                // For default presets (one in each time sig. Not changable by user)
                ForEach(metronome.bufferAccents.currentPresets.filter { $0.defaultPreset == true }, id:\.self) { preset in
                    HStack {
                        Button(action: {
                            processPresetTap(preset)
                        }, label: {
                            Text("\(preset.name)")
                                .fontWeight(.bold)
                        })
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(metronome.userChosenPresetVariations[metronome.timeSig[0]]?.array == preset.array ? 1 : 0)
                    }
                    .listRowBackground(Color.clear)
                }
                
                // For all other presets, either user made or system set
                ForEach(metronome.bufferAccents.currentPresets.filter { $0.defaultPreset != true }, id: \.self) { preset in
                    HStack {
                        Button(action: {
                            processPresetTap(preset)
                        }, label: {
                            Text("\(preset.orderIndex). \(preset.name)")
                                .italic()
                        })
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteAccentPreset(item: preset)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            Button(action: {
                                startEditingPresetName(preset)
                            }, label: {
                                Label("Edit", systemImage: "pencil")
                            })
                            .tint(.blue)
                        }
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(metronome.userChosenPresetVariations[metronome.timeSig[0]]?.array == preset.array ? 1 : 0)
                        Image(systemName: "line.3.horizontal")
                    }
                    .listRowBackground(Color.clear)
                }
                .onMove { (source, destination) in
                    // Cater for default existing in 'seperate list'
                    // Increment each value by 1
                    let from = IndexSet(integer: source.first! + 1)
                    moveListItem(from, destination + 1)
                }
                HStack {
                    Spacer()
                    Button(action:  {
                        // stop metronome
                        if metronome.isPlaying {
                            metronome.pressPlayStopButton()
                        }
                        if metronome.bufferAccents.currentPresets.map( { $0.array }).contains(where: { $0 == metronome.bufferAccents.settings }) {
                            if let matchingPreset = metronome.bufferAccents.currentPresets.first(where: { $0.array == metronome.bufferAccents.settings }) {
                                nameOfPresetThatExists = matchingPreset.name
                            }
                            showPresetAlreadyExistsAlert = true
                        } else {
                            showPresetAddAlert = true
                        }
                    }, label : {
                        Image(systemName: "plus")
                    })
                    .moveDisabled(true)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListHeaderHeight, 0)
        .frame(maxHeight: self.deviceScreen.componentSizing[.presetListMaxHeight], alignment: .top)
        
    }
    
    private func processPresetTap(_ preset: AccentArray.Preset) {
        showAccentMenu = false
        withAnimation(.easeInOut) {
            opacities.beatView = 1.0
    //        opacities.playTimeAndTempoView = 1.0
            opacities.presetMenu = 0.0
            opacities.playView = 1.0
            opacities.tempoMarkingView = 1.0
        }
        metronome.changeChosenPreset(preset)
        metronome.initClickSet(clickSetName: metronome.currentSound)
    }
    
    private func deleteAccentPreset(item: AccentArray.Preset) {
        if let index = metronome.bufferAccents.currentPresets.firstIndex(where: { $0.id == item.id }) {
            metronome.bufferAccents.currentPresets.remove(at: index)
            // run through currentPresets and adapt all orderIndex
            resetOrderIndexForCurrentPresets()
            // Ensure changes persist
            metronome.storeCurrentPresetsInDefaults()
        }
    }
    
    private func resetOrderIndexForCurrentPresets() {
        for index in 0..<metronome.bufferAccents.currentPresets.count {
            metronome.bufferAccents.currentPresets[index].orderIndex = index
        }
    }
    
    private func startEditingPresetName(_ preset: AccentArray.Preset) {
        // stop metronome
        if metronome.isPlaying {
            metronome.pressPlayStopButton()
        }
        presetToEdit = preset.name
        givenPresetName = ""
        presentPresetNameChangeAlert = true
    }
    
    private func moveListItem(_ source: IndexSet,_ destination: Int) {
        // Get list of currentPresets
        var updatedList = metronome.bufferAccents.currentPresets
        
        // Move item
        updatedList.move(fromOffsets: source, toOffset: destination)
        
        // update orderIndex
        for index in updatedList.indices {
            updatedList[index].orderIndex = index
        }
        
        // save updated list in currentPresets
        metronome.bufferAccents.currentPresets = updatedList
        // make changes persistant
        metronome.storeCurrentPresetsInDefaults()
    }
    
}


//
//#Preview {
//    PresetsView()
//}
