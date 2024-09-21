//
//  Opacities.swift
//  Metronome
//
//  Created by Ross Conquer on 02/09/2024.
//

import Foundation

class Opacities: ObservableObject {
    @Published var topScreenView: Double = 1
    @Published var beatView: Double = 1
    @Published var presetMenu: Double = 0
    @Published var playView: Double = 1
    @Published var tempoMarkingView: Double = 1
    @Published var tempoView: Double = 1
    @Published var timeSigView: Double = 0
    @Published var tempoOrTimeSigSelector: Double = 1
}
