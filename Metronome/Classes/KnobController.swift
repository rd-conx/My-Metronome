//
//  TempoNotches.swift
//  Metronome
//
//  Created by Ross Conquer on 09/09/2024.
//

import Foundation

class KnobController: ObservableObject {
    @Published var tempoNotches: [Int: Bool] = Dictionary(uniqueKeysWithValues: (0..<40).map { ($0, false) })
}


