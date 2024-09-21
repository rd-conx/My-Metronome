//
//  TempoViewNew.swift
//  Metronome
//
//  Created by Ross Conquer on 05/09/2024.
//

import SwiftUI

struct TempoView: View {
    
    @State var value: Int = 0
    // Increment size per detected movement
    @State private var tempoNotchCount: Int = 40
    @State var knobController = KnobController()
    
    @State private var prevNotch: Int?
    @State private var currentNotch: Int?
    @State private var valueOutOfBounds = false
    
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    @State private var radius: CGFloat = 0
    
    @StateObject private var tapTempo = TapTempo()
    @State private var valueSetWithKnob = false
    @State private var valueSetThroughMetronome = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var metronome: Metronome
    
    @State private var tapCircleBounds = ObjectBounds()
    
    @State private var tapCircleDiameter: CGFloat = 0
    
    // monitor tap tempo for vibration
    @State private var tapTempoTapped = false
    
    @State var currentAngle: Int = 0
    @State private var prevAngle: Int = 0
    @State private var wheelSpinStarted = false
    
    var body: some View {
        
        let foreground: Color = colorScheme == .light ? .black : .white
        
        ZStack {
//            TimeSigArrowsView(radius: $radius)
//                .opacity(opacities.tempoView)
//                .offset(y: -radius / 1.3)
            CircleOfDots(angle: $currentAngle, knobController: $knobController, radius: self.radius)
            Circle()
                .stroke(foreground, lineWidth: 1)
                .frame(width: tapCircleDiameter)
                .contentShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .onAppear {
                    self.radius = self.deviceScreen.componentSizing[.radius]!
//                    let tapCircle = radius / 1.5
                    self.tapCircleDiameter = radius / 1.5
//                    self.tapCircleDiameter = tapCircle > 120 ? 120 : tapCircle
                }
                .onChange(of: deviceScreen.size) {
                    self.radius = self.deviceScreen.componentSizing[.radius]!
                    self.tapCircleDiameter = radius / 1.5
                }
                .onLongPressGesture(minimumDuration: 0) {
                    tapTempo.tapTempoTapped()
                    tapTempoTapped.toggle()
                    tapCircleDiameter -= 2
                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                        tapCircleDiameter += 2
                    }
                }
                .sensoryFeedback(.impact, trigger: tapTempoTapped)
                .zIndex(1)
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .font(.system(size: 20))
            KnobView(radius: self.radius)
                .rotationEffect(.degrees(Double(currentAngle)))
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .onChanged { dragValue in
//                        if dragInsideTapCircle(dragValue.location, in: tapCircleDiameter) {
//                            return
//                        }
                        
                        let currentAngle = Int(angleForLocation(dragValue.location, in: radius))
                        
                        if metronome.tempoWheelHeld == false {
                            metronome.tempoWheelHeld = true
                        }
                                                
                        self.currentAngle = Int(currentAngle)
//                        self.prevAngle = Int(currentAngle)
                    }
                    .onEnded {dragValue in
                        self.prevNotch = nil
                        metronome.tempoWheelHeld = false
                        if metronome.awaitTempoWheelRelease {
                            metronome.softStart()
                            metronome.awaitTempoWheelRelease = false
                        }
                    }
                )

            }
            .onAppear {
                self.value = Int(metronome.tempoBPM)
            }
            .onChange(of: knobController.tempoNotches) {
                for (notch, value) in knobController.tempoNotches {
                    if value == true {
                        let currentNotch = notch
                        if self.prevNotch == nil {
                            self.prevNotch = notch
                        }
                        let prevNotch = self.prevNotch!
                        
                        let diff = currentNotch - prevNotch
                        if diff > 30 {
                            self.value -= 1
                        } else if diff < -30 {
                            self.value += 1
                        } else {
                            self.value += diff
                        }
                        
                        if self.value < 30 || self.value > 400 {
                            self.valueOutOfBounds = true
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                                self.valueOutOfBounds = false
                            }
                        }
                        
                        if self.value > 400 { self.value = 400 }
                        if self.value < 30 { self.value = 30 }
                        
                        self.prevNotch = currentNotch
                    }
                }
            }
            .onChange(of: value) { oldValue, newValue in
                if !valueSetThroughMetronome {
                    valueSetWithKnob = true
                    if MetronomeConstants.BPM_ACC_RANGE.contains(Double(newValue)) {
                        metronome.setTempo(bpm: Double(value))
                    }
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        valueSetWithKnob = false
                    }
                }
            }
            .sensoryFeedback(.increase, trigger: self.value)
            .sensoryFeedback(.warning, trigger: self.valueOutOfBounds)
            .onChange(of: metronome.tempoBPM) { oldValue, newValue in
                if !valueSetWithKnob {
                    valueSetThroughMetronome = true
                    value = Int(newValue)
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        valueSetThroughMetronome = false
                    }
                }
        }
    }
    
//    private func dragInsideTapCircle(_ location: CGPoint, in diameter: CGFloat) -> Bool {
//        let centerPoint = CGPoint(x: diameter, y: diameter)
////        print("centerPoint: \(centerPoint), location: \(location)")
//        let dx = location.x - centerPoint.x
//        let dy = location.y - centerPoint.y
////        print("diameter: \(diameter), dx: \(dx), dy: \(dy)")
////        if (0...diameter).contains(dx) && (0...diameter).contains(dy) {
////            print("in tap circle")
//////            print("diameter: \(diameter), dx: \(dx), dy: \(dy)")
////            return true
////        }
//        
//    
//        return false
//    }
    
    private func angleForLocation(_ location: CGPoint, in radius: CGFloat, center: CGPoint? = nil) -> Double {
        let centerPoint = center ?? CGPoint(x: radius, y: radius)
        let dx = location.x - centerPoint.x
        let dy = location.y - centerPoint.y
        // atan2(dy, dx) returns an angle in radians between -π and π (i.e., between -180° and 180°).
        let angle = atan2(dy, dx) * 180 / .pi
        return angle < 0 ? angle + 360 : angle
    }
                                     
}

//#Preview {
//    TempoView()
//}
