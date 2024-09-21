//
//  BeatView.swift
//  Metronome
//
//  Created by Ross Conquer on 16/12/2023.
//

import SwiftUI

struct BeatView: View {
    
    @Binding var currentBeat: Int
    
    @State var beatCapsuleWidth: CGFloat = 0
    
    @EnvironmentObject private var deviceScreen: DeviceScreen
    
    @EnvironmentObject private var metronome: Metronome
    
    var body: some View {
        
        VStack {
            // HStack and enclosing Spacers to center the vstack
            HStack {
                VStack {
                    ZStack {
                        InteractiveCapsulesView(beatCapsuleWidth: $beatCapsuleWidth)
                        FlashingCapsulesView(currentBeat: $currentBeat, beatCapsuleWidth: $beatCapsuleWidth)
                            .onChange(of: deviceScreen.size.width) { oldValue, newValue in
                                self.beatCapsuleWidth = metronome.beatCapsuleWidth
                            }
                    }
                }
            }
            Spacer()
        }
        .offset(y: metronome.beatsInBar < 6 ? 25 : 0)
        .frame(maxWidth: 600)
    }
}

struct BeatViewPreviews: PreviewProvider {
    static var previews: some View {
        // Assuming Metronome is an ObservableObject and it is properly initialized here
        let metronome = Metronome()
        
        @State var currentBeat = 0
        
        BeatView(currentBeat: $currentBeat)
            .environmentObject(metronome) // Provide the Metronome object to the environment
            .environmentObject(DeviceScreen())
    }
}
