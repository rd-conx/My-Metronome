//
//  DeviceScreen.swift
//  Metronome
//
//  Created by Ross Conquer on 04/09/2024.
//

import Foundation


enum sizeVariables {
    // Metronome view
    case topScreenBttmPad
    case topScreenAndBeatsSpacer
    case beatViewTopPad
    case accentPresetMenuViewOffsetY
    case accentPresetMenuViewAndPlayViewSpacer
    case tempoTimeSigPickerFrameMaxWidth
    
    // Preset list view
    case presetListMaxHeight
    
    // Play View
    case playButtonFontsize
    case playButtonFrameMinHeight
    
    // Tempo view
    case radius
    
    // Knob view
    case rectangleFrameHeight
    
    // Circle of dots
    case circleFrameWidth
}

enum DeviceLabel {
    // iPhones
    case smPhone
    case mdPhone
    case lgPhone
    
    // iPads
    case smPortIpad
    case smLandIpad
    case mdPortIpad
    case mdLandIpad
    case lgPortIpad
    case lgLandIpad
    
    // iPad splits
    
    // Use same split measurements for small and md iPads
    case portSmSplit
    case portLgSplit
    case landSmSplit
    case landMdSplit
    case landLgSplit
    
    // for larger use different measurements
    case lgPortSmSplit
    case lgPortLgSplit
    case lgLandSmSplit
    case lgLandMdSplit
    case lgLandLgSplit
}

class DeviceScreen: ObservableObject {
    @Published var size: CGSize = CGSize(width: 0, height: 0)
    let WIDTH_LIMIT: CGFloat = 600
    let SE_WIDTH_BP: CGFloat = 375
    
    // used for hiding play button on certain devices when opening list view
    let PRESET_LIST_HEIGHT_CUTOFF: CGFloat = 1100
    
    func processSize(_ size: CGSize) {
        self.size = size
//        print(size)
        let device: DeviceLabel = self.findDevice(from: size)
        
        // iPhones
        if device == .smPhone {
//            print("using small phone")
            self.componentSizing = self.SM_PHONE_SIZING
        } else if device == .mdPhone {
//            print("using medium phone")
            self.componentSizing = self.MD_PHONE_SIZING
        } else if device == .lgPhone {
//            print("using large phone")
            self.componentSizing = self.LG_PHONE_SIZING
        }
        
        // ipads
        else if device == .smPortIpad {
//            print("using small ipad in portrait")
            self.componentSizing = self.SM_PORT_IPAD_SIZING
        } else if device == .smLandIpad {
//            print("using small ipad in landscape")
            self.componentSizing = self.SM_LAND_IPAD_SIZING
        }
        
        else if device == .mdPortIpad {
//            print("using medium ipad in portrait")
            self.componentSizing = self.MD_PORT_IPAD_SIZING
        } else if device == .mdLandIpad {
//            print("using medium ipad in landscape")
            self.componentSizing = self.MD_LAND_IPAD_SIZING
        }
        
        else if device == .lgPortIpad {
//            print("using large ipad in portrait")
            self.componentSizing = self.LG_PORT_IPAD_SIZING
        } else if device == .lgLandIpad {
//            print("using large ipad in landscape")
            self.componentSizing = self.LG_LAND_IPAD_SIZING
        }
        
        else if device == .portSmSplit {
//            print("using ipad, portrait small split")
            self.componentSizing = self.SPLIT_PORT_SM
        } else if device == .portLgSplit {
//            print("using ipad, portrait large split")
            self.componentSizing = self.SPLIT_PORT_LG
        } else if device == .landSmSplit {
//            print("using ipad, landscape small split")
            self.componentSizing = self.SPLIT_LAND_SM
        } else if device == .landMdSplit {
//            print("using ipad, landscape half split")
            self.componentSizing = self.SPLIT_LAND_MD
        } else if device == .landLgSplit {
//            print("using ipad, landscape large split")
            self.componentSizing = self.SPLIT_LAND_LG
        }
        
        else if device == .lgPortSmSplit {
//            print("using large ipad, portrait small split")
            self.componentSizing = self.LG_SPLIT_PORT_SM
        } else if device == .lgPortLgSplit {
//            print("using large ipad, portrait large splilit")
            self.componentSizing = self.LG_SPLIT_PORT_LG
        } else if device == .lgLandSmSplit {
//            print("using large ipad, landscape small split")
            self.componentSizing = self.LG_SPLIT_LAND_SM
        } else if device == .lgLandMdSplit {
//            print("using large ipad, landscape half split")
            self.componentSizing = self.LG_SPLIT_LAND_MD
        } else if device == .lgLandLgSplit {
//            print("using alrge ipad, landscape large split")
            self.componentSizing = self.LG_SPLIT_LAND_LG
        }
    }
    
    private func findDevice(from size: CGSize) -> DeviceLabel {
        
        // Catch split view iPads first
        let PORT_IPAD_HEIGHTS: [CGFloat] = [1089, 1136, 1166]
        let PORT_IPAD_LG_HEIGHTS: [CGFloat] = [1322, 1332]
        
        // Portrait sm split
        if (size.width == 320) && ((PORT_IPAD_HEIGHTS).contains(size.height)) {
            return .portSmSplit
        // portrait lg split
        } else if (([414, 490, 504]).contains(size.width)) && ((PORT_IPAD_HEIGHTS).contains(size.height)) {
            return .portLgSplit
        }
        
        // lg ipad portrait sm split
        if (size.width == 375) && ((PORT_IPAD_LG_HEIGHTS).contains(size.height)) {
            return .lgPortSmSplit
        // lg ipad portrait lg split
        } else if (([639, 647]).contains(size.width)) && ((PORT_IPAD_LG_HEIGHTS).contains(size.height)) {
            return .lgPortLgSplit
        }
        
        
        let LAND_IPAD_HEIGHTS: [CGFloat] = [700, 776, 790]
        let LAND_IPAD_LG_HEIGHTS: [CGFloat] = [980, 988]
        
        // Landscape sm split
        if (size.width == 375) && ((LAND_IPAD_HEIGHTS).contains(size.height)) {
            return .landSmSplit
        // Landscape md split
        } else if (([561.5, 585, 600]).contains(size.width)) && ((LAND_IPAD_HEIGHTS).contains(size.height)) {
            return .landMdSplit
        // landscape lg split
        } else if (([748, 795, 825]).contains(size.width)) && ((LAND_IPAD_HEIGHTS).contains(size.height)) {
            return .landLgSplit
        }
        
        // lg ipad landscape sm split
        if (size.width == 375) && ((LAND_IPAD_LG_HEIGHTS).contains(size.height)) {
            return .lgLandSmSplit
        // landscape md split
        } else if (([678, 683]).contains(size.width)) && ((LAND_IPAD_LG_HEIGHTS).contains(size.height)) {
            return .lgLandMdSplit
        // landscape lg split
        } else if (([981, 991]).contains(size.width)) && ((LAND_IPAD_LG_HEIGHTS).contains(size.height)) {
            return .lgLandLgSplit
        }
        
        // Phones
        if (size.width <= 375) && (size.height <= 647) {
            return .smPhone
        } else if (size.width <= 393) && (size.height <= 759) {
            return .mdPhone
        } else if (size.width <= 430) && (size.height <= 839) {
            return .lgPhone
        }
        
        
        // sm ipad
        else if (size.width <= 744) && (size.height <= 1089) {
            return .smPortIpad
        } else if (size.width <= 1133) && (size.height <= 700) {
            return .smLandIpad
        }
        
        // md ipad
        else if (size.width <= 834) && (size.height <= 1166) {
            return .mdPortIpad
        } else if (size.width <= 1210) && (size.height <= 790) {
            return .mdLandIpad
        }
        
        // lg ipad
        else if (size.width <= 1032) && (size.height <= 1332) {
            return .lgPortIpad
        } else if (size.width <= 1376) && (size.height <= 988) {
            return .lgLandIpad
        }
        
  
        // If no cases met device is probably large, use largest size
        else {
            print("device not listed")
            // if in portrait
            if (size.width < size.height) {
                print("using large device in portrait")
                return .lgPortIpad
            } else {
                print("using large device in landscape")
                return .lgLandIpad
            }
        }
    }

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
    
    // iPhone
    let SM_PHONE_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 130,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 230,
        
        // Play View
        .playButtonFontsize: 60,
        .playButtonFrameMinHeight: 60,
        
        // Tempo view
        .radius: 115,
        
        // Knob view
        .rectangleFrameHeight: 13,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    let MD_PHONE_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 5,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 130,
        .tempoTimeSigPickerFrameMaxWidth: 330,
        
        // Preset List view
        .presetListMaxHeight: 265,
        
        // Play View
        .playButtonFontsize: 80,
        .playButtonFrameMinHeight: 80,
        
        // Tempo view
        .radius: 140,
        
        // Knob view
        .rectangleFrameHeight: 15,
        
        // circle of dots
        .circleFrameWidth: 2.5,
    ]
    
    let LG_PHONE_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 18,
        .topScreenAndBeatsSpacer: 20,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -18,
        .accentPresetMenuViewAndPlayViewSpacer: 150,
        .tempoTimeSigPickerFrameMaxWidth: 360,
        
        // Preset List view
        .presetListMaxHeight: 320,
        
        // Play View
        .playButtonFontsize: 85,
        .playButtonFrameMinHeight: 85,
        
        // Tempo view
        .radius: 150,
        
        // Knob view
        .rectangleFrameHeight: 16,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    
    
    // iPad
    let SM_PORT_IPAD_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 18,
        .topScreenAndBeatsSpacer: 40,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -38,
        .accentPresetMenuViewAndPlayViewSpacer: 180,
        .tempoTimeSigPickerFrameMaxWidth: 600,
        
        // Preset List view
        .presetListMaxHeight: 350,
        
        // Play View
        .playButtonFontsize: 100,
        .playButtonFrameMinHeight: 100,
        
        // Tempo view
        .radius: 210,
        
        // Knob view
        .rectangleFrameHeight: 20,
        
        // circle of dots
        .circleFrameWidth: 3,
    ]
    
    let SM_LAND_IPAD_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 120,
        .tempoTimeSigPickerFrameMaxWidth: 400,
        
        // Preset List view
        .presetListMaxHeight: 150,
        
        // Play View
        .playButtonFontsize: 50,
        .playButtonFrameMinHeight: 50,
        
        // Tempo view
        .radius: 150,
        
        // Knob view
        .rectangleFrameHeight: 10,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    let SM_PORT_IPAD_NARROW_SPLIT: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 18,
        .topScreenAndBeatsSpacer: 40,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -38,
        .accentPresetMenuViewAndPlayViewSpacer: 180,
        .tempoTimeSigPickerFrameMaxWidth: 600,
        
        // Preset List view
        .presetListMaxHeight: 350,
        
        // Play View
        .playButtonFontsize: 100,
        .playButtonFrameMinHeight: 100,
        
        // Tempo view
        .radius: 210,
        
        // Knob view
        .rectangleFrameHeight: 20,
        
        // circle of dots
        .circleFrameWidth: 3,
    ]
   
    let MD_PORT_IPAD_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 18,
        .topScreenAndBeatsSpacer: 50,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -48,
        .accentPresetMenuViewAndPlayViewSpacer: 180,
        .tempoTimeSigPickerFrameMaxWidth: 500,
        
        // Preset List view
        .presetListMaxHeight: 400,
        
        // Play View
        .playButtonFontsize: 100,
        .playButtonFrameMinHeight: 100,
        
        // Tempo view
        .radius: 210,
        
        // Knob view
        .rectangleFrameHeight: 20,
        
        // circle of dots
        .circleFrameWidth: 3,
    ]
    
    let MD_LAND_IPAD_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 120,
        .tempoTimeSigPickerFrameMaxWidth: 400,
        
        // Preset List view
        .presetListMaxHeight: 240,
        
        // Play View
        .playButtonFontsize: 70,
        .playButtonFrameMinHeight: 70,
        
        // Tempo view
        .radius: 160,
        
        // Knob view
        .rectangleFrameHeight: 10,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    let LG_PORT_IPAD_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 25,
        .topScreenAndBeatsSpacer: 60,
        .beatViewTopPad: 20,
        .accentPresetMenuViewOffsetY: -58,
        .accentPresetMenuViewAndPlayViewSpacer: 200,
        .tempoTimeSigPickerFrameMaxWidth: 600,
        
        // Preset List view
        .presetListMaxHeight: 500,
        
        // Play View
        .playButtonFontsize: 120,
        .playButtonFrameMinHeight: 120,
        
        // Tempo view
        .radius: 250,
        
        // Knob view
        .rectangleFrameHeight: 20,
        
        // circle of dots
        .circleFrameWidth: 3.5,
    ]
    
    let LG_LAND_IPAD_SIZING: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 5,
        .topScreenAndBeatsSpacer: 15,
        .beatViewTopPad: 15,
        .accentPresetMenuViewOffsetY: 10,
        .accentPresetMenuViewAndPlayViewSpacer: 150,
        .tempoTimeSigPickerFrameMaxWidth: 400,
        
        // Preset List view
        .presetListMaxHeight: 300,
        
        // Play View
        .playButtonFontsize: 80,
        .playButtonFrameMinHeight: 80,
        
        // Tempo view
        .radius: 200,
        
        // Knob view
        .rectangleFrameHeight: 15,
        
        // circle of dots
        .circleFrameWidth: 3,
    ]
    
    
    // ipad splits
    let SPLIT_PORT_SM: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 20,
        .topScreenAndBeatsSpacer: 30,
        .beatViewTopPad: 20,
        .accentPresetMenuViewOffsetY: -50,
        .accentPresetMenuViewAndPlayViewSpacer: 250,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 400,
        
        // Play View
        .playButtonFontsize: 80,
        .playButtonFrameMinHeight: 80,
        
        // Tempo view
        .radius: 120,
        
        // Knob view
        .rectangleFrameHeight: 13,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    let SPLIT_PORT_LG: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 20,
        .topScreenAndBeatsSpacer: 30,
        .beatViewTopPad: 20,
        .accentPresetMenuViewOffsetY: -50,
        .accentPresetMenuViewAndPlayViewSpacer: 250,
        .tempoTimeSigPickerFrameMaxWidth: 370,
        
        // Preset List view
        .presetListMaxHeight: 400,
        
        // Play View
        .playButtonFontsize: 90,
        .playButtonFrameMinHeight: 90,
        
        // Tempo view
        .radius: 150,
        
        // Knob view
        .rectangleFrameHeight: 14,
        
        // circle of dots
        .circleFrameWidth: 2.5,
    ]
    let SPLIT_LAND_SM: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 130,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 230,
        
        // Play View
        .playButtonFontsize: 60,
        .playButtonFrameMinHeight: 60,
        
        // Tempo view
        .radius: 115,
        
        // Knob view
        .rectangleFrameHeight: 13,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    let SPLIT_LAND_MD: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 130,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 230,
        
        // Play View
        .playButtonFontsize: 60,
        .playButtonFrameMinHeight: 60,
        
        // Tempo view
        .radius: 130,
        
        // Knob view
        .rectangleFrameHeight: 13,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    let SPLIT_LAND_LG: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 0,
        .topScreenAndBeatsSpacer: 0,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: 0,
        .accentPresetMenuViewAndPlayViewSpacer: 130,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 230,
        
        // Play View
        .playButtonFontsize: 60,
        .playButtonFrameMinHeight: 60,
        
        // Tempo view
        .radius: 140,
        
        // Knob view
        .rectangleFrameHeight: 13,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    
    let LG_SPLIT_PORT_SM: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 30,
        .topScreenAndBeatsSpacer: 70,
        .beatViewTopPad: 30,
        .accentPresetMenuViewOffsetY: -90,
        .accentPresetMenuViewAndPlayViewSpacer: 270,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 500,
        
        // Play View
        .playButtonFontsize: 80,
        .playButtonFrameMinHeight: 80,
        
        // Tempo view
        .radius: 150,
        
        // Knob view
        .rectangleFrameHeight: 13,
        
        // circle of dots
        .circleFrameWidth: 2,
    ]
    
    let LG_SPLIT_PORT_LG: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 30,
        .topScreenAndBeatsSpacer: 70,
        .beatViewTopPad: 30,
        .accentPresetMenuViewOffsetY: -90,
        .accentPresetMenuViewAndPlayViewSpacer: 270,
        .tempoTimeSigPickerFrameMaxWidth: 400,
        
        // Preset List view
        .presetListMaxHeight: 500,
        
        // Play View
        .playButtonFontsize: 90,
        .playButtonFrameMinHeight: 90,
        
        // Tempo view
        .radius: 200,
        
        // Knob view
        .rectangleFrameHeight: 17,
        
        // circle of dots
        .circleFrameWidth: 3,
    ]
    let LG_SPLIT_LAND_SM: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 10,
        .topScreenAndBeatsSpacer: 40,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -40,
        .accentPresetMenuViewAndPlayViewSpacer: 170,
        .tempoTimeSigPickerFrameMaxWidth: 300,
        
        // Preset List view
        .presetListMaxHeight: 400,
        
        // Play View
        .playButtonFontsize: 80,
        .playButtonFrameMinHeight: 80,
        
        // Tempo view
        .radius: 140,
        
        // Knob view
        .rectangleFrameHeight: 14,
        
        // circle of dots
        .circleFrameWidth: 3,
    ]
    let LG_SPLIT_LAND_MD: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 10,
        .topScreenAndBeatsSpacer: 40,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -40,
        .accentPresetMenuViewAndPlayViewSpacer: 170,
        .tempoTimeSigPickerFrameMaxWidth: 450,
        
        // Preset List view
        .presetListMaxHeight: 400,
        
        // Play View
        .playButtonFontsize: 90,
        .playButtonFrameMinHeight: 90,
        
        // Tempo view
        .radius: 200,
        
        // Knob view
        .rectangleFrameHeight: 16,
        
        // circle of dots
        .circleFrameWidth: 3.5,
    ]
    
    let LG_SPLIT_LAND_LG: [sizeVariables: CGFloat] = [
        // Metronome View
        .topScreenBttmPad: 10,
        .topScreenAndBeatsSpacer: 40,
        .beatViewTopPad: 10,
        .accentPresetMenuViewOffsetY: -40,
        .accentPresetMenuViewAndPlayViewSpacer: 170,
        .tempoTimeSigPickerFrameMaxWidth: 450,
        
        // Preset List view
        .presetListMaxHeight: 400,
        
        // Play View
        .playButtonFontsize: 90,
        .playButtonFrameMinHeight: 90,
        
        // Tempo view
        .radius: 200,
        
        // Knob view
        .rectangleFrameHeight: 16,
        
        // circle of dots
        .circleFrameWidth: 3.5,
    ]
}
