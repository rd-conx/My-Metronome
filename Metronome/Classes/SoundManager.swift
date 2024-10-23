//
//  SoundManager.swift
//  Metronome
//
//  Created by Ross Conquer on 02/08/2024.
//

import Foundation

enum SoundOption: String, CaseIterable {
    case block = "block"
    case click = "click"
    static var defaultValue = SoundOption.block
}

class SoundManager: ObservableObject {
    
    func getCurrentClickSound() -> SoundOption {
        // Return stored property
        return settingsManager.clickSound
    }
    
    func setCurrentSound(clickSoundChoice: SoundOption) {
        settingsManager.clickSound = clickSoundChoice
        metronome.currentSound = clickSoundChoice.rawValue
        metronome.initClickSet(clickSetName: clickSoundChoice.rawValue)
    }
}
