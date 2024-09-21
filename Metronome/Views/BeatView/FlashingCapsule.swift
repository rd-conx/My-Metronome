//
//  FlashingCapsule.swift
//  Metronome
//
//  Created by Ross Conquer on 29/08/2024.
//

import SwiftUI

struct FlashingCapsule: View {
    
    @Binding var beatCapsuleWidth: CGFloat
    @State var index: Int
    @State var currentBeat: Bool
    
    @EnvironmentObject var metronome: Metronome
    
    @State var padding: CGFloat = 0.1
    
    @State var transitionDuration: TimeInterval?
    @State var opacity: CGFloat = 0.2
    
    var body: some View {
        Capsule()
            .frame(width: beatCapsuleWidth, height: metronome.audioBufferCapsuleHeights[index])
            .animation(.spring(duration: 0.3), value: metronome.audioBufferCapsuleHeights[index])
            .padding(padding * 10)
            .opacity(opacity)
            .onAppear() {
                updateOpacityAndScheduleFade()
            }
            // ensure opacity updates with all else, when tim sig is changed
            .onChange(of: metronome.bufferAccents.settings) {
                updateOpacityAndScheduleFade()
            }
            .onChange(of: metronome.audioBufferCapsuleHeights) {
                updateOpacityAndScheduleFade()
            }
    }
    
    private func updateOpacityAndScheduleFade() {

        guard let accent = metronome.bufferAccents.getAccentAtIndex(index: index) else {
            return
        }
        // Stop flash on beat one when stopping metronome
        if !metronome.isPlaying {
            self.opacity = metronome.bufferAccents.accentToOpacityOtherBeats[accent]!
            return
        }
        self.opacity = getOpacity()
        transitionDuration = {
            return TimeInterval(100 / (metronome.tempoBPM * 10))
        }()
        // Fade that only takes effect when on currentBeat
        DispatchQueue.main.asyncAfter(deadline: .now() + (metronome.secondsPerBeat * 0.1), execute: {
            withAnimation(.easeOut(duration: (transitionDuration ?? 0.1) * 2)) {
                self.opacity = metronome.bufferAccents.accentToOpacityOtherBeats[accent]!
            }
        })
    }
    
    private func getOpacity() -> CGFloat {
        guard let accent = metronome.bufferAccents.getAccentAtIndex(index: index) else {
            return 0.2
        }
        if metronome.isPlaying {
            if currentBeat {
                return metronome.bufferAccents.accentToOpacityCurrentBeat[accent]!
            } else {
                return metronome.bufferAccents.accentToOpacityOtherBeats[accent]!
            }
        } else {
            return metronome.bufferAccents.accentToOpacityOtherBeats[accent]!
        }

    }
}

//#Preview {
//    FlashingCapsule()
//}
