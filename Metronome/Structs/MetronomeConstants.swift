//
//  MetronomeConstants.swift
//  Metronome
//
//  Created by Ross Conquer on 19/08/2024.
//

import Foundation

struct MetronomeConstants {
    static let DEFAULT_BPM: Double = 120.0
    static let BPM_ACC_RANGE = 30.0...400.0

    static let DEFAULT_TIME_SIG: [Int] = [4, 4]
    static let TIME_SIG_UPPER_ACC_RANGE = 1...16
    static let TIME_SIG_LOWER_ACC_VALUES = [1, 2, 4, 8]
    
    static let SECONDS_PER_MIN: Double = 60.0
    static let SAMPLE_RATE: Double = 44100.0
    static let EXT = "wav"
    // 1 Creates a large buffer (5 at 300 BPM, 1 at 30 BPM) - better for slower devices?
    // 0.250 Creates a smaller buffer of 1 at all tempos - allows tempo to appear to change live
    static let TEMPO_RESPONSIVENESS: Double = 0.250
    
    // For beat capsules
    static let CAPSULE_HEIGHTS: [CGFloat] = [
        40, 30, 20, 10
    ]
    
    static let PLAY_BUTTON = "play.fill"
    static let STOP_BUTTON = "stop.fill"

    static let DEFAULT_CLICK_NAME = "block"
    static let DEFAULT_CLICK_DISPLAY_NAME = {
        let firstLetter = DEFAULT_CLICK_NAME.prefix(1).capitalized
        let remainingLetters = DEFAULT_CLICK_NAME.dropFirst().lowercased()
        return firstLetter + remainingLetters + " (default)"
    }
    static let SECONDARY_CLICK_NAME = "click"
    static let SECONDARY_CLICK_DISPLAY_NAME = {
        let firstLetter = SECONDARY_CLICK_NAME.prefix(1).capitalized
        let remainingLetters = SECONDARY_CLICK_NAME.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
