//
//  PlayView.swift
//  Metronome
//
//  Created by Ross Conquer on 15/12/2023.
//

import SwiftUI
import MediaPlayer

struct PlayView: View {
    
    @EnvironmentObject var metronome: Metronome
    
    // To change playback icon when button pressed
    @State var playButtonType = MetronomeConstants.PLAY_BUTTON
    
    @Binding var currentBar: Int
    @Binding var currentBeat: Int
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    @State private var showVolumeDownAlert: Bool = false
    
    var body: some View {
        
        let tintColor: Color = colorScheme == .light ? .black: .white
        
        Image(systemName: playButtonType)
//            .font(.system(size: deviceScreen.size.width > deviceScreen.SE_WIDTH_BP ? 80 : 60))
            .font(.system(size: self.deviceScreen.componentSizing[.playButtonFontsize]!))
//            .frame(minWidth: 50, minHeight: deviceScreen.size.width > deviceScreen.SE_WIDTH_BP ? 100 : 70)
            .frame(minWidth: 50, minHeight: self.deviceScreen.componentSizing[.playButtonFrameMinHeight])
            .tint(tintColor)
            .onTapGesture {
                if (!metronome.isPlaying) {
                    if (metronome.volumeIsDown()) {
                        showVolumeDownAlert = true
                    }
                }
                metronome.pressPlayStopButton()
                   metronome.onTick = { bar, beat in
                       self.currentBar = bar
                       self.currentBeat = beat
                   }
                playButtonType = metronome.playButtonType
            }
            .onChange(of: metronome.playButtonType) { oldValue, newValue in
                playButtonType = newValue
            }
            .sensoryFeedback(.impact, trigger: playButtonType)
            .sheet(isPresented: $showVolumeDownAlert) {
                VStack {
                    Text("Volume is set to zero. Increase it to hear the metronome.")
                        .padding(.vertical)
                        .multilineTextAlignment(.center)
                    MPVolumeViewWrapper()
                        .frame(width: deviceScreen.size.width * 0.7, height: 50)
                        .padding(.top)
                    Button("Ok") {
                        showVolumeDownAlert = false
                    }
                    .padding()
                }
                .presentationDetents([.fraction(0.3)])
            }
    }
}

struct MPVolumeViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView()
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}


struct PlayViewPreviews: PreviewProvider {
    

    static var previews: some View {
        let metronome = Metronome()
        let deviceScreen = DeviceScreen()
        
        @State var currentBar = 0
        @State var currentBeat = 0
        
        PlayView(currentBar: $currentBar, currentBeat: $currentBeat)
            .environmentObject(metronome)
            .environmentObject(deviceScreen)
//            .environmentObject(userSettings)
    }
}
