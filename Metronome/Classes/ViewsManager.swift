//
//  ViewsManager.swift
//  Metronome
//
//  Created by Ross Conquer on 04/09/2024.
//

import Foundation
import SwiftUI

class ViewsManager: ObservableObject {
    
    @Published var showAccentMenu: Bool = false
    @Published var newPreset: String = ""
    @Published var tempoVisible = true
    @Published var tempoOrTimeSigSelection: tempoOrTimeSig = .tempo
    
    func performShowAccentMenu() {
        self.showAccentMenu = true
        withAnimation(.easeInOut) {
            opacities.beatView = 0.0
            opacities.presetMenu = 1.0
        }
    }
    
    func performHideAccentMenu() {
        self.showAccentMenu = false
        withAnimation(.easeInOut) {
            opacities.beatView = 1.0
            opacities.presetMenu = 0.0
        }
    }
    
    func switchTempoAndTimeSig() {
        if tempoVisible {
            opacities.tempoView = 0.0
            opacities.timeSigView = 1.0
            tempoVisible = false
        } else {
            opacities.tempoView = 1.0
            opacities.timeSigView = 0.0
            tempoVisible = true
        }
    }
}
