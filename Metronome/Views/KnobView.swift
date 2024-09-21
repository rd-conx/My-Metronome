//
//  KnobView.swift
//  Metronome
//
//  Created by Ross Conquer on 01/09/2024.
//

import SwiftUI

struct KnobView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var deviceScreen: DeviceScreen
    let radius: CGFloat

    var body: some View {
        let foreground: Color = colorScheme == .light ? .black : .white
//        let background: Color = colorScheme == .light ? .white : .black
        ZStack {
            Circle()
                .stroke(foreground, lineWidth: 2)
                .fill(.clear)
                .frame(width: radius * 2, alignment: .center)
                .contentShape(Circle()) // Make inside of circle tappable
            Rectangle()
                .fill(foreground)
//                .frame(width: 1.8, height: deviceScreen.size.width > 600 ? deviceScreen.size.width * 0.015 : deviceScreen.size.width * 0.03)
                .frame(width: 1.5, height: self.deviceScreen.componentSizing[.rectangleFrameHeight])
                .rotationEffect(.degrees(90))
                .offset(x: radius - 20)
//            Circle()
//                .stroke(foreground, lineWidth: 2)
//                .frame(width: deviceScreen.size.width < 400 ? 2 : deviceScreen.size.width < 600 ? 4 : 15)
//                .offset(x: radius - 20)
//                .opacity(1)
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

#Preview {
    KnobView(radius: 100)
}
