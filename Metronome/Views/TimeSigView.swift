//
//  TimeSigView.swift
//  Metronome
//
//  Created by Ross Conquer on 15/12/2023.
//

import SwiftUI

struct TimeSigView: View {
    
    @EnvironmentObject var metronome: Metronome
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectionUpper: Int = 0
    @State private var selectionLower: Int = 0
    
    @State private var textRotationAngle: Double = 90.0
    @State private var pickerRotationAngle: Double = -90.0
    @State private var pickerVerticalPadding: CGFloat = -50
    @State private var pickerWidth: CGFloat = 50
    @State private var pickerHeight: CGFloat = 150
    
    let lowerValues = [1, 2, 4, 8]
    
    @State private var selectionUpperChangedViaWheel = false
    @State private var selectionUpperChangedViaSwipe = false
    
    @State private var changedManually = false
    @State private var changedThroughMetronome = false
    
    var body: some View {
        
        VStack {
            
            // Upper numerator
            Picker("", selection: $selectionUpper) {
                ForEach(1..<17) {
                    Text(String($0))
                        .rotationEffect(Angle(degrees: textRotationAngle))
                }
            }
            .pickerStyle(.wheel)
            .rotationEffect(Angle(degrees: pickerRotationAngle))
            .frame(width: pickerWidth, height: pickerHeight)
            .padding(.vertical, pickerVerticalPadding)
            .onChange(of: selectionUpper) {
                oldValue, newValue in
                if !changedThroughMetronome {
                    changedManually = true
                    metronome.setTimeSig(timeSigUpper: selectionUpper + 1)
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        changedManually = false
                    }
                }
            }
            .onChange(of: metronome.timeSig[0]) {
                if !changedManually {
                    changedThroughMetronome = true
                    selectionUpper = metronome.timeSig[0] - 1
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        changedThroughMetronome = false
                    }
                }
            }
            
            // lower numerator
            Picker("", selection: $selectionLower) {
                ForEach(lowerValues, id: \.self) {
                    Text(String($0))
                        .rotationEffect(Angle(degrees: textRotationAngle))
                }
            }
            .pickerStyle(.wheel)
            .rotationEffect(Angle(degrees: pickerRotationAngle))
            .frame(width: pickerWidth, height: pickerHeight)
            .padding(.vertical, pickerVerticalPadding)
            
            .onChange(of: selectionLower) {
                oldValue, newValue in
                metronome.setTimeSig(timeSigLower: selectionLower)
            }
            .offset(y: -10)
            
        }
        .onAppear {
            selectionUpper = settingsManager.timeSignature[0] - 1
            selectionLower = settingsManager.timeSignature[1]
        }
        
    }
}

//struct TimeSigViewPreviews: PreviewProvider {
//    
//    static var previews: some View {
//        TimeSigView()
//    }
//}
