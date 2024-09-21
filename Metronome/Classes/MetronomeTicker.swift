//
//  MetronomeTicker.swift
//  Metronome
//
//  Created by Ross Conquer on 06/08/2024.
//

import Foundation

// Seperated from metronome class, so other views did not update when published variable changed
class MetronomeTicker: ObservableObject {
    @Published var tick: Bool = false
}
