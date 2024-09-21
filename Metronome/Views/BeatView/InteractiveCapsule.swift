//
//  InteractiveCapsule.swift
//  Metronome
//
//  Created by Ross Conquer on 29/08/2024.
//

import SwiftUI

struct InteractiveCapsule: View {
    
    @EnvironmentObject var metronome: Metronome
    
    @Binding var beatCapsuleWidth: CGFloat
    @State var padding: CGFloat = 0.1
    @State var index: Int
    
    var body: some View {
        Capsule()
            .fill(Color.gray.opacity(0.01)) // Important, makes view invisible but interactive for drag gesture
            .frame(width: beatCapsuleWidth, height: metronome.audioBufferCapsuleHeights[index])
            .animation(.spring(duration: 0.3), value: metronome.audioBufferCapsuleHeights[index])
            .padding(padding * 10)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.height < -20 {
                        // Swiped up
                        toggleAudioBuffer(index: index, metronome: metronome, swipedDown: false)
                    } else if value.translation.height > 20 {
                        // Swiped down
                        toggleAudioBuffer(index: index, metronome: metronome, swipedDown: true)
                    } else if value.translation.width < -20 {

                        
                    } else if value.translation.width > 20 {
                        print("swiped right")

                    }
                }))
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
}

//#Preview {
//    InteractiveCapsule()
//}
