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
        ZStack {
            Circle()
                .stroke(foreground, lineWidth: 1)
                .fill(.clear)
                .frame(width: radius * 2, alignment: .center)
                .contentShape(Circle()) // Make inside of circle tappable
            Rectangle()
                .fill(foreground)
                .frame(width: 1.5, height: self.deviceScreen.componentSizing[.rectangleFrameHeight])
                .rotationEffect(.degrees(90))
                .offset(x: radius - 20)
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

#Preview {
    KnobView(radius: 100)
}
