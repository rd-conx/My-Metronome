//
//  TapTempo.swift
//  Metronome
//
//  Created by Ross Conquer on 01/09/2024.
//

import Foundation

class TapTempo: ObservableObject {
        
    private var date: Date? = nil
    private var tapped = false
    
    private var noTapTimer: Timer? = nil
    private let NO_TAP_TIME_INTERVAL: TimeInterval = 4
    
    @Published var newTempo: Double = 0.0
    
    private let ACC_TEMPO_DIFFERENCE = 15 // (bpm)
    
    private var approxTempos: [Int] = []
    private var approxTemposAverage: Int = 0
    
    func tapTempoTapped() {
        if !self.tapped {
            self.tapped = true
            self.date = Date()
            self.noTapTimer = self.setNoTapTimer()
            return
        }
            
        // invalidate timers as user has tapped again
        self.invalidateNoTapTimer()
        
        // Work out time between taps
        var secondsBetweenTaps: TimeInterval = 0
        if let safeDate = self.date {
            secondsBetweenTaps = abs(safeDate.timeIntervalSinceNow)
        }
        
        // work out approx tempo
        let tempo = Int(MetronomeConstants.SECONDS_PER_MIN / secondsBetweenTaps)
        
        // if approxTempos contains more than one item, find average
        if self.approxTempos.count > 1 {
            // Get average
            self.approxTemposAverage = self.getAverageTempo(self.approxTempos)
            // Check if new tempo is in acceptable range of average
            if self.tempoNotInAcceptableBounds(newTempo: tempo, self.approxTemposAverage) {
                self.resetValues()
                return
            }
            // add new tempo in
            self.approxTempos.append(tempo)
            // get new average
            self.approxTemposAverage = self.getAverageTempo(self.approxTempos)
            // set tempo with average
            self.setTempo(self.approxTemposAverage)

        // if it contains 1 item, check against new tempo to add
        } else if self.approxTempos.count == 1 {
            // check if newTempo is within acceptable bounds
            let storedTempo = self.approxTempos[0]
            if self.tempoNotInAcceptableBounds(newTempo: tempo, storedTempo) {
                // user has likely changed speed, scrap array and reset values, start new
                self.resetValues()
                return
            }
            // new tempo is within acceptable range, we can add to array
            self.approxTempos.append(tempo)
            // Now find average again
            self.approxTemposAverage = getAverageTempo(self.approxTempos)
            // And set tempo
            self.setTempo(self.approxTemposAverage)
            
        } else if self.approxTempos.count < 1 {
            // set tempo with single value
            self.setTempo(tempo)
            // Add tempo to empty array
            self.approxTempos.append(tempo)
        }
        
        // Set new date
        self.date = Date()
        
        // Set no tap timer
        self.noTapTimer = self.setNoTapTimer()
    }
    
    
    private func setNoTapTimer() -> Timer? {
        let timer = Timer.scheduledTimer(withTimeInterval: self.NO_TAP_TIME_INTERVAL, repeats: false) { _ in
            self.resetValues()
        }
        return timer
    }
    
    private func invalidateNoTapTimer() {
        // Remove no tap timer
        if let safeTimer = self.noTapTimer {
           safeTimer.invalidate()
        }
    }
    
    
    private func getAverageTempo(_ tempos: [Int]) -> Int {
        var total = 0
        for tempo in tempos {
            total += tempo
        }
        return total / tempos.count
    }
    
    
    private func tempoNotInAcceptableBounds(newTempo: Int,_ tempo: Int) -> Bool {
        return abs(tempo - newTempo) > self.ACC_TEMPO_DIFFERENCE
    }
    
        
    private func setTempo(_ tempo: Int) {
        let newTempo = Double(tempo)
        if MetronomeConstants.BPM_ACC_RANGE.contains(newTempo) {
            metronome.setTempo(bpm: newTempo)
            self.newTempo = newTempo
        }
    }
    
    
    private func resetValues() {
        self.tapped = false
        self.date = nil
        self.approxTempos.removeAll()
        self.approxTemposAverage = 0
    }
}
