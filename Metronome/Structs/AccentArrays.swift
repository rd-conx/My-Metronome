//
//  AccentPresets.swift
//  Metronome
//
//  Created by Ross Conquer on 06/08/2024.
//

import Foundation

struct AccentArray {
    static let LENGTH = 16
    static let ACCEPTABLE_RANGE: Range = 0..<16
    static let OPTIONS = ["1": "1", "2": "2", "3": "3", "4": "4"]
    static let DEFAULT_SETTINGS = [
        "1","3","3","3",
        "3","3","3","3",
        "3","3","3","3",
        "3","3","3","3",
    ]
    
    var chosenPreset: Int = 0
    var settings: [String] = []
    
    struct Preset: Identifiable, Hashable, Codable {
        var defaultPreset = false
        var orderIndex = 0
//        var chosen = false
        var id = UUID()

        var name: String
        let array: [String]
    }
    
    static let OPTIONAL_ERROR_PRESET = Preset(name: "No Presets saved...", array: [])
    static let EMPTY_PRESET = Preset(name: "Empty", array: [])
    
    var currentPresets: [Preset] = []
    var currentDefault: Preset = EMPTY_PRESET
    
    init(settings: [String] = DEFAULT_SETTINGS) {
        self.settings = settings
    }

    var accentToOpacityCurrentBeat: [String: CGFloat] = [
        "1": 0.7,
        "2": 0.7,
        "3": 0.7,
        "4": 0.3
    ]
    
    var accentToOpacityOtherBeats: [String: CGFloat] = [
        "1": 0.4,
        "2": 0.3,
        "3": 0.2,
        "4": 0.1
    ]
    
    func getAccentAtIndex(index: Int) -> String? {
        // Safely retrieves accent at given index
        if !AccentArray.ACCEPTABLE_RANGE.contains(index) {
            print("Index: '\(index)' is out of range. Acceptable range: '\(AccentArray.ACCEPTABLE_RANGE)'")
            return nil
        }
        return self.settings[index]
    }
    
    mutating func updateSettings(index: Int, option: String) {
        guard let accent = AccentArray.OPTIONS[option] else {
            print("option: '\(option)' not valid. Choice: '\(AccentArray.OPTIONS)'." )
            return
        }
        if !AccentArray.ACCEPTABLE_RANGE.contains(index) {
            print("Index: '\(index)' is out of range. Acceptable range: '\(AccentArray.ACCEPTABLE_RANGE)'")
            return
        }
        
        // values safe to use
        self.settings[index] = accent
    }
    
    static let ALL_PRESETS: [Int: [Preset]] = [
        1: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        2: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        3: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Descending", array: ["1", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Ascending", array: ["1", "3", "2", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        4: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "One & Three", array: ["1", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Two & Four", array: ["3", "2", "3", "2", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Two & Four alt", array: ["4", "2", "4", "2", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        5: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Three-Two", array: ["1", "3", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Two-Three", array: ["1", "3", "2", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        6: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Three-Three", array: ["1", "3", "3", "2", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "4", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        7: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Three-Four", array: ["1", "3", "3", "2", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Four-Three", array: ["1", "3", "3", "3", "2", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "4", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        8: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "On Four", array: ["1", "3", "3", "3", "2", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "4", "4", "4", "4", "4", "4", "4", "4"])
        ],
        9: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Every Three", array: ["1", "3", "3", "2", "3", "3", "2", "3", "3", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Four-Five", array: ["1", "3", "3", "3", "2", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Five-Four", array: ["1", "3", "3", "3", "3", "2", "3", "3", "3", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 4, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "4", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 5, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4", "4", "4", "4", "4", "4"])
        ],
        10: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "On Five", array: ["1", "3", "3", "3", "3", "2", "3", "3", "3", "3", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "4", "4", "4", "4", "4", "4"])
        ],
        11: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Five-Six", array: ["1", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Six-Five", array: ["1", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "4", "4", "4", "4", "4"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4", "4", "4", "4"])
        ],
        12: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "On Six", array: ["1", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "4", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Every Three", array: ["1", "3", "3", "2", "3", "3", "2", "3", "3", "2", "3", "3", "4", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4", "4", "4"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "4", "4", "4", "4"])
        ],
        13: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4", "4"]),
            Preset(orderIndex: 1, name: "Six-Seven", array: ["1", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "3", "4", "4", "4"]),
            Preset(orderIndex: 2, name: "Seven-Six", array: ["1", "3", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "4", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "4", "4", "4"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4", "4"])
        ],
        14: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "4", "4"]),
            Preset(orderIndex: 1, name: "On Seven", array: ["1", "3", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "3", "4", "4"]),
            Preset(orderIndex: 2, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4"]),
            Preset(orderIndex: 3, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4", "4"])
        ],
        15: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "4"]),
            Preset(orderIndex: 1, name: "Seven-Eight", array: ["1", "3", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "3", "3", "4"]),
            Preset(orderIndex: 2, name: "Eight-Seven", array: ["1", "3", "3", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "3", "4"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "4"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "4"])
        ],
        16: [
            Preset(defaultPreset: true, orderIndex: 0, name: "Default", array: ["1", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3"]),
            Preset(orderIndex: 1, name: "On Eight", array: ["1", "3", "3", "3", "3", "3", "3", "3", "2", "3", "3", "3", "3", "3", "3", "3"]),
            Preset(orderIndex: 2, name: "Every Four", array: ["1", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3", "2", "3", "3", "3"]),
            Preset(orderIndex: 3, name: "Every Two", array: ["1", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3"]),
            Preset(orderIndex: 4, name: "Every Two alt", array: ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "3"])
        ]
    ]
    
    static let DEFAULT_PRESET_VARIATION: [Int: Preset] = [
          1: ALL_PRESETS[1]![0],
          2: ALL_PRESETS[2]![0],
          3: ALL_PRESETS[3]![0],
          4: ALL_PRESETS[4]![0],
          5: ALL_PRESETS[5]![0],
          6: ALL_PRESETS[6]![0],
          7: ALL_PRESETS[7]![0],
          8: ALL_PRESETS[8]![0],
          9: ALL_PRESETS[9]![0],
          10: ALL_PRESETS[10]![0],
          11: ALL_PRESETS[11]![0],
          12: ALL_PRESETS[12]![0],
          13: ALL_PRESETS[13]![0],
          14: ALL_PRESETS[14]![0],
          15: ALL_PRESETS[15]![0],
          16: ALL_PRESETS[16]![0]
    ]
}


