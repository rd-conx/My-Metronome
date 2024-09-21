//
//  InteractiveCapsules.swift
//  Metronome
//
//  Created by Ross Conquer on 29/08/2024.
//

import SwiftUI

struct InteractiveCapsulesView: View {
    
    @EnvironmentObject var metronome: Metronome
    
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
                ForEach(0..<firstLimit, id: \.self) { index in
                    InteractiveCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: index)
                }
            }
            HStack(alignment: .bottom) {
                // these capsule will only show when beats > 5
                if beats > 5 {
                    Capsule()
                        .frame(width: 0, height: 42)
                }
                ForEach(firstLimit..<beats, id: \.self) { index in
                    InteractiveCapsule(beatCapsuleWidth: $beatCapsuleWidth, index: index)
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
//    InteractiveCapsules()
//}
