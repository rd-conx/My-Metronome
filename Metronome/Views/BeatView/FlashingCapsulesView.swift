//
//  FlashingCapsules.swift
//  Metronome
//
//  Created by Ross Conquer on 29/08/2024.
//

import SwiftUI

/**
 Use this view to display capsules that flash on the correct beat.
 */
struct FlashingCapsulesView: View {
    
    @EnvironmentObject var metronome: Metronome
    @EnvironmentObject var ticker: MetronomeTicker
    
    @Binding var currentBeat: Int
    @State var defaultOrder = true
    @Binding var beatCapsuleWidth: CGFloat

    var body: some View {
        let beats = metronome.beatsInBar
        // Find value to determine end of first row of beat capsules before wrap
        let firstLimit = metronome.firstLimitWrapper(beats: beats, defaultOrder: defaultOrder)
        VStack {
            HStack(alignment: .bottom) {
                // To stop capsules moving up when biggest gets smaller
                Capsule()
                    .frame(width: 0, height: 42)
                // enables capsule to flash when just one capsule visible - 1/?
                if metronome.ticker.tick {
                    FlashingCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: 0, currentBeat: 0 == currentBeat ? true : false)
                } else {
                    FlashingCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: 0, currentBeat: 0 == currentBeat ? true : false)
                }
                ForEach(1..<firstLimit, id: \.self) { index in
                    if index == currentBeat {
                        FlashingCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: index, currentBeat: true)
                    } else {
                       FlashingCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: index, currentBeat: false)
                    }
                }
            }
            HStack(alignment: .bottom) {
                // these capsule will only show when beats > 5
                if beats > 5 {
                    Capsule()
                        .frame(width: 0, height: 42)
                }
                ForEach(firstLimit..<beats, id: \.self) { index in
                    if index == currentBeat {
                        FlashingCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: index, currentBeat: true)
                    } else {
                        FlashingCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: index, currentBeat: false)
                    }
                }
            }
            .onAppear() {
                beatCapsuleWidth = metronome.beatCapsuleWidth
            }
            .onChange(of: beats) {
                beatCapsuleWidth = metronome.beatCapsuleWidth
            }
        }
    }
}

//#Preview {
//    FlashingCapsules()
//}
