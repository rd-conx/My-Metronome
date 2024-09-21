//
//  DeviceScreen.swift
//  Metronome
//
//  Created by Ross Conquer on 04/09/2024.
//

import Foundation

class DeviceScreen: ObservableObject {
    
    @Published var size: CGSize = CGSize(width: 0, height: 0)
    
    // measurements used in app
    var componentSizing: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 0,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 0,
        .tempoTimeSigPickerFrameMaxWidth: 0,
        
        // Preset View
        .presetListMaxHeight: 0,
        .presetMenuMaxWidth: 0,
        
        // Play View
        .playButtonFontsize: 0,
        .playButtonFrameMinHeight: 0,
        
        // Tempo view
        .radius: 0,
        
        // Knob view
        .rectangleFrameHeight: 0,
        
        // circle of dots
        .circleFrameWidth: 0,
    ]
    
    
    func processSize(_ size: CGSize) {
        self.size = size
        print(size)
        
        // decide measurements based on screen height
        self.componentSizing = self.calculateSizing(size.width, size.height)
    }
    
    private func calculateSizing(_ deviceWidth: CGFloat,_ deviceHeight: CGFloat) -> [sizeVariables: CGFloat] {
        
        let oneTenthHeight = deviceHeight * 0.1
        let oneTwentiethHeight = deviceHeight * 0.05
        
        let eightyPercentWidth = deviceWidth * 0.8
        let pickerFrame = eightyPercentWidth > 400 ? 400 : eightyPercentWidth
        
        // ensure tempo wheel is not wider than screen when using ipad split views
        let tempoDiameter = deviceHeight * 0.35
        var radius: CGFloat = 0
        if tempoDiameter > deviceWidth * 0.8 {
            radius = deviceWidth * 0.8 / 2
        } else {
            radius = deviceHeight * 0.35 / 2
        }
        
        let sizing: [sizeVariables: CGFloat] = [
            // Metronome View
            .topScreenBttmPad: 0,
            // Deal with smaller screen on the SE
            .topScreenAndBeatsSpacer: deviceHeight > 700 ? oneTwentiethHeight : 0,
            .beatViewTopPad: 0,
            .accentPresetMenuViewOffsetY: deviceHeight > 700 ? -(oneTwentiethHeight) : 0,
            .accentPresetMenuViewAndPlayViewSpacer: deviceHeight * 0.2,
            .tempoTimeSigPickerFrameMaxWidth: pickerFrame,
            
            // Preset View
            .presetListMaxHeight: deviceHeight > 700 ? deviceHeight * 0.4 : deviceHeight * 0.35,
            .presetMenuMaxWidth: deviceWidth > 400 ? 400 : deviceWidth,
            
            // Play View
            .playButtonFontsize: oneTenthHeight,
            .playButtonFrameMinHeight: oneTenthHeight,
            
            // Tempo view
            .radius: radius,
            
            // Knob view
            .rectangleFrameHeight: deviceHeight * 0.015,
            
            // circle of dots
            .circleFrameWidth: deviceHeight * 0.003,
        ]
        
        return sizing
    }
}
