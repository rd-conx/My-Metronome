//
//  DenominatorView.swift
//  Metronome
//
//  Created by Ross Conquer on 03/04/2024.
//

import SwiftUI

struct DenominatorView: View {
    
    @EnvironmentObject var metronome: Metronome
    @State var opacity: CGFloat
    
    var body: some View {
        
        let denominator: String = metronome.currentDenominator
        HStack {
            Text(denominator)
                .font(.system(size: 10))
                .italic()
            //            Image(denominator)
            //                .resizable()
            //                .aspectRatio(contentMode: .fit)
            //                .frame(maxWidth: 10, maxHeight: 10)
            //                .opacity(opacity)
        }
    }
}

struct DenominatorViewPreviews: PreviewProvider {
    static var previews: some View {
        let metronome = Metronome()
        DenominatorView(opacity: 1.0)
            .environmentObject(metronome)
    }
}
