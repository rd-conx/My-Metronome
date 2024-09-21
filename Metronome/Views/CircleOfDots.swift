//
//  CircleOfDots.swift
//  Metronome
//
//  Created by Ross Conquer on 05/09/2024.
//

import SwiftUI

struct CircleOfDots: View {
    
    @Binding var angle: Int
    
    @Binding var knobController: KnobController
    let radius: CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    var body: some View {
        
        let tempoNotches = knobController.tempoNotches
        
        
        let foreground: Color = colorScheme == .light ? .black : .white
        
        
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let outerRadius = radius + 10
            
            ForEach(0..<tempoNotches.count, id: \.self) { i in
                
                let circleAngle = CGFloat(i) * (2 * .pi / CGFloat(tempoNotches.count))
                
                let xPosition = center.x + outerRadius * cos(circleAngle)
                let yPosition = center.y + outerRadius * sin(circleAngle)

                Circle()
                    .fill(foreground)
//                    .frame(width: deviceScreen.size.width < 400 ? 2 : deviceScreen.size.width < 600 ? 4 : 5)
                    .frame(width: self.deviceScreen.componentSizing[.circleFrameWidth])
                    .position(x: xPosition, y: yPosition)
                    .opacity(workOutOpacity(Double(circleAngle), i))
            }
        }
    }
    
    /// Returns opacity of dot down to its proximity to the current angle of the main knob. Has a huge side effect of updating the tempoNotch current dot to true which in turn allows for the change of tempo value. in parent view
    private func workOutOpacity(_ circleAngle: Double,_ index: Int) -> Double {
        
        let knobAngle = Double(self.angle) * .pi / 180
        let angleDifference = abs(circleAngle - knobAngle)
        
        // If the angle difference is within a small range, make it more opaque
        if angleDifference < 0.08 {
            // **** SIDE EFFECT ****
            knobController.tempoNotches[index] = true
            return 1.0
        } else {
            knobController.tempoNotches[index] = false
            return 0.2
        }
    }
}

//#Preview {
//    CircleOfDots()
//}

