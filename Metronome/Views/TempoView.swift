//
//  TempoViewNew.swift
//  Metronome
//
//  Created by Ross Conquer on 05/09/2024.
//

import SwiftUI

struct TempoView: View {
    
    @State var value: Int = 0 // bpm

    @State var knobController = KnobController() // records and publishes active notches
    @State private var prevNotch: Int?
    @State private var valueOutOfBounds = false
    
    @EnvironmentObject var deviceScreen: DeviceScreen
    @State private var radius: CGFloat = 0
    @State private var tapCircleDiameter: CGFloat = 0
    
    @StateObject private var tapTempo = TapTempo()
    @State private var tapTempoTapped = false // for haptic feedback
    @State private var valueSetWithKnob = false
    @State private var valueSetThroughMetronome = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var metronome: Metronome
    
    @State var currentAngle: Int = 0
    
    var body: some View {
        
        let foreground: Color = colorScheme == .light ? .black : .white
        
        ZStack {
            CircleOfDots(angle: $currentAngle, knobController: $knobController, radius: self.radius)
            
            Circle()
                .stroke(foreground, lineWidth: 1)
                .frame(width: tapCircleDiameter)
                .contentShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .onAppear { resizeTempoDial() }
                .onChange(of: deviceScreen.size) { resizeTempoDial() }
                .onLongPressGesture(minimumDuration: 0) { recordTapTempoTap() }
                .sensoryFeedback(.impact, trigger: tapTempoTapped)
                .zIndex(1)
            
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(foreground)
                .font(.system(size: 20))
            
            KnobView(radius: self.radius)
                .rotationEffect(.degrees(Double(currentAngle)))
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .onChanged { dragValue in recordCurrentAngle(dragValue: dragValue) }
                    .onEnded { _ in resetDragDependencies() }
                )
        }
        .onAppear { recordTempoBPMValue() }
        .onChange(of: knobController.tempoNotches) { updateValueWhenKnobMovesPastNotch() }
        .onChange(of: value) { _, newValue in setTempoIfValueChangedWithKnob(newValue) }
        .sensoryFeedback(.increase, trigger: self.value)
        .sensoryFeedback(.warning, trigger: self.valueOutOfBounds)
        .onChange(of: metronome.tempoBPM) { _, newValue in setValueIfTempoChangedThroughMetronome(newValue) }
    }
    
    private func resizeTempoDial() {
        self.radius = self.deviceScreen.componentSizing[.radius]!
        self.tapCircleDiameter = radius / 1.5
    }
    
    private func recordTapTempoTap() {
        tapTempo.tapTempoTapped()
        tapTempoTapped.toggle()
        tapCircleDiameter -= 2
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
            tapCircleDiameter += 2
        }
    }
    
    private func recordCurrentAngle(dragValue: DragGesture.Value) {
        let currentAngle = Int(angleForLocation(dragValue.location, in: radius))
        if metronome.tempoWheelHeld == false {
            metronome.tempoWheelHeld = true
        }
        self.currentAngle = Int(currentAngle)
    }
    
    private func angleForLocation(_ location: CGPoint, in radius: CGFloat, center: CGPoint? = nil) -> Double {
        let centerPoint = center ?? CGPoint(x: radius, y: radius)
        let dx = location.x - centerPoint.x
        let dy = location.y - centerPoint.y
        // atan2(dy, dx) returns an angle in radians between -π and π (i.e., between -180° and 180°).
        let angle = atan2(dy, dx) * 180 / .pi
        return angle < 0 ? angle + 360 : angle
    }
    
    private func resetDragDependencies() {
        self.prevNotch = nil
        metronome.tempoWheelHeld = false
        if metronome.awaitTempoWheelRelease {
            metronome.softStart()
            metronome.awaitTempoWheelRelease = false
        }
    }
    
    private func recordTempoBPMValue() {
        self.value = Int(metronome.tempoBPM)
    }
    
    private func updateValueWhenKnobMovesPastNotch() {
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
                
                let lowerBound = Int(MetronomeConstants.BPM_ACC_RANGE.lowerBound)
                let upperBound = Int(MetronomeConstants.BPM_ACC_RANGE.upperBound)
                if self.value < lowerBound || self.value > upperBound {
                    self.valueOutOfBounds = true
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        self.valueOutOfBounds = false
                    }
                }
                
                if self.value > upperBound { self.value = upperBound }
                if self.value < lowerBound { self.value = lowerBound }
                
                self.prevNotch = currentNotch
            }
        }
    }
    
    private func setTempoIfValueChangedWithKnob(_ newValue: Int) {
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
    
    private func setValueIfTempoChangedThroughMetronome(_ newValue: Double) {
        if !valueSetWithKnob {
            valueSetThroughMetronome = true
            value = Int(newValue)
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                valueSetThroughMetronome = false
            }
        }
    }
}
