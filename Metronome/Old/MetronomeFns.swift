//
//  MetronomeFns.swift
//  Metronome
//
//  Created by Ross Conquer on 04/12/2024.
//

/// Main beat scheduling function. Beats are scheduled with playerNodes scheduleBuffer, at a designated sample time, calculated with sample rate and seconds per beat.
//    func scheduleBeats() {
//
//        // First check if metronome is running
//        if (!self.isPlaying) { return }
//
//        while (self.beatsScheduled < self.beatsToScheduleAhead) {
//
//            self.setBeatValues()
//
//            // Schedule audio
//            self.playerNode.scheduleBuffer(self.audioBuffers[self.bufferIndex], at: self.playerBeatSampleValue, completionHandler: {
//                self.syncQueue.sync() {
//
//                    // decrement beatsScheduled to make condition for loop true
//                    self.beatsScheduled -= 1
//
//                    // schedule more beats
//                    self.scheduleBeats()
//                }
//            })
//
//            if (!self.playerStarted) {
//                self.playerNode.play()
//                self.playerStarted = true
//            }
//
//            // update onTick for visual cues
//            let callbackBeat = self.beatNumber - 1
//            var bar = 0
//            var beat = 0
//            if callbackBeat != 0 {
//                bar = (callbackBeat / self.beatsInBar) // Keep as Ints to chop deicmal
//                beat = (callbackBeat % self.beatsInBar)
//            } else {
//                bar = 0
//                beat = 0
//            }
//            if self.isPlaying {
//                self.onTick?(bar, beat)
//            }
//
//            self.beatNumber += 1
//            self.beatsScheduled += 1
//
//            DispatchQueue.main.async {
//                self.ticker.tick.toggle()
//            }
//
//            // Increment sound buffer to next in array for next beat
//            self.bufferIndex += 1
//            // Go to start if at end
//            if self.bufferIndex > self.beatsInBar - 1 {
//                self.bufferIndex = 0
//            }
//
//            self.nextBeatSampleValue += self.samplesPerBeat
//        }
//    }
