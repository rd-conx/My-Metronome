//
//  CapsuleView.swift
//  Metronome
//
//  Created by Ross Conquer on 23/04/2024.
//

import SwiftUI

struct CapsuleView: View {

    @Binding var beatCapsuleWidth: CGFloat
    @State var index: Int
    @State var currentBeat: Bool
    
    @EnvironmentObject var metronome: Metronome
    
    @State var padding: CGFloat = 0.1
    
    @State var transitionDuration: TimeInterval?
    @State var opacity: CGFloat = 0.2
    
    var body: some View {
        
        ZStack {
            Capsule()
                .frame(width: beatCapsuleWidth, height: metronome.audioBufferCapsuleHeights[index])
                .animation(.spring(duration: 0.3), value: metronome.audioBufferCapsuleHeights[index])
                .padding(padding * 10)
                .opacity(opacity)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.height < -20 {
                            // Swiped up
                            toggleAudioBuffer(index: index, metronome: metronome, swipedDown: false)
                        } else if value.translation.height > 20 {
                            // Swiped down
                            toggleAudioBuffer(index: index, metronome: metronome, swipedDown: true)
                        } else if value.translation.width < -100 {
                        } else if value.translation.width > 100 {
                        }
                        updateOpacityAndScheduleFade()
                    }))
                .onAppear() {
                    updateOpacityAndScheduleFade()
                }
                // ensure opacity updates with all else, when tim sig is changed
                .onChange(of: metronome.bufferAccents.settings) {
                    updateOpacityAndScheduleFade()
                }
            }
    }
    
    private func toggleAudioBuffer(index: Int, metronome: Metronome, swipedDown: Bool) {
        
        // Get name of buffer loaded at current index
        let currentLoadedBuffer: String = metronome.audioBufferLabels[index]
     
        // Store number at end of file name
        guard var sampleNumberToToggle: Int = Int(currentLoadedBuffer.suffix(1)) else {
            print("Could not convert \(currentLoadedBuffer.suffix(1)) to an integer.")
            return
        }
        
        // Get value to access next sample in collection
        if swipedDown {
            sampleNumberToToggle += 1
            // reset if above acceptable range
            if sampleNumberToToggle > 4 { return }
        } else {
            sampleNumberToToggle -= 1
            if sampleNumberToToggle < 1 { return }
        }
        
        // get length of name of buffer excluding final character
        let oldBufferAdaptedLength = currentLoadedBuffer.count - 1
        
        // slice old string to remove last char (number) and add new number to end
        let newBufferToLoad = String(currentLoadedBuffer.slice(0, oldBufferAdaptedLength) + String(sampleNumberToToggle))
        
        // Change buffer at capsule that was tapped
        metronome.reInitIndividualBuffer(bufferName: newBufferToLoad, bufferIndex: index, sampleNumber: sampleNumberToToggle - 1)
        
        // Save choice in persistent array
    //    metronome.bufferAccentSettings[index] = String(sampleNumberToToggle)
        metronome.bufferAccents.updateSettings(index: index, option: String(sampleNumberToToggle))
        
        // Final check - if current settings reflect a preset within userAccentPresets, set that preset to be the chosen Preset variation
        // Otherwise remove the chosen preset variation
        metronome.checkArrayCopyOfSaved()
        
        metronome.saveCurrentAccentConfig()
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


extension StringProtocol {
    func slice(_ start: Int, _ end: Int) -> SubSequence {
        let lower = index(self.startIndex, offsetBy: start)
        let upper = index(lower, offsetBy: end - start)
        return self[lower..<upper]
    }
}



//struct CapsuleViewPreviews: PreviewProvider {
//    @State var beatCapsuleWidth: CGFloat = 0
//    static var previews: some View {
//        // Assuming Metronome is an ObservableObject and it is properly initialized here
//        let metronome = Metronome()
//        let beats = metronome.beatsInBar
//        let beatCapsuleWidth = {
//            if beats < 6 { return CGFloat(256 / beats)
//            } else if 6...8 ~= beats { return CGFloat(256 / 4)
//            } else if 9...10 ~= beats { return CGFloat(256 / 5)
//            } else if 11...12 ~= beats { return CGFloat(256 / 6)
//            } else if 13...14 ~= beats { return CGFloat(256 / 7)
//            } else if 15...16 ~= beats { return CGFloat(256 / 8)
//            } else { return CGFloat(32.0) }
//        }
//        
//        CapsuleView(beatCapsuleWidth: $beatCapsuleWidth, index: 0, currentBeat: true)
//            .environmentObject(metronome)
//    }
//}
