//
//  TopScreenView.swift
//  Metronome
//
//  Created by Ross Conquer on 06/08/2024.
//

import SwiftUI

struct TopScreenView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var metronome: Metronome
    @EnvironmentObject private var ticker: MetronomeTicker
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    @State private var showInfoModal: Bool = false
    
    var body: some View {
        
        let textColor: Color = colorScheme == .light ? .black : .white
        
        ZStack {
            HStack {
                SettingsMenuView()
                .padding(.leading, 10)
                Spacer()
            }
            HStack {
                Spacer()
                Image(systemName: "metronome")
                    .font(.system(size: 40, weight: .regular))
                    .padding(10)
                    .onTapGesture {
                        showInfoModal = true
                    }
                    .fullScreenCover(isPresented: $showInfoModal, content: FullScreenModalView.init)
                Spacer()
            }
            HStack {
                Spacer()
                Menu {
                    Button("Tap or rotate the tempo knob to set a tempo") {}
                    Button("Swipe up and down on beats to change accents") {}
                    Button("Double tap any beat to set an accent preset") {}
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 21, weight: .light))
                        .padding(.trailing, 15)
                        .tint(textColor)
                        .opacity(settingsManager.hideHelper == true ? 0.0 : 1.0)
                }
                .disabled(settingsManager.hideHelper)
            }
        }
    }
}


struct FullScreenModalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let webLink = "https://www.rossconquer.dev/home"
    
    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "x.circle")
                            .tint(.red)
                    })
                    .padding(20)
                }
                Spacer()
                Text("My Metronome")
                Text("Version 1.0")
                    .font(.system(size: 13))
                    .padding(.bottom, 10)
                Text("Developed by Ross Conquer")
                Button("Visit my website") {
                    if let url = URL(string: webLink) {
                        UIApplication.shared.open(url)
                    }
                }
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    TopScreenView()
}
