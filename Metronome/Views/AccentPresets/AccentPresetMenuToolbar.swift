//
//  AccentPresetMenuToolbar.swift
//  Metronome
//
//  Created by Ross Conquer on 19/08/2024.
//

import SwiftUI

struct AccentPresetMenuToolbar: View {
    @Binding var presentPresetResetAlert: Bool
    @Binding var showAccentMenu: Bool
    
    @EnvironmentObject var opacities: Opacities
    
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    var body: some View {
        
        HStack {
            Button(action: {
                presentPresetResetAlert = true
            }, label: {
                Image(systemName: "slider.horizontal.2.gobackward")
                    .frame(width: 40, height: 40)
                // Frame to make tap zones bigger
            })
            .padding(.leading, 25)
            Spacer()
            Button(action: {
                showAccentMenu = false
                withAnimation(.easeInOut) {
                    opacities.beatView = 1.0
                    opacities.presetMenu = 0.0
                    opacities.playView = 1.0
                    opacities.tempoMarkingView = 1.0
                }
            }, label: {
                Image(systemName: "x.circle")
                    .frame(width: 40, height: 40)
            })
            .padding(.trailing, 25)
        }
    }
    
}

//#Preview {
//    AccentPresetMenuToolbar()
//}
