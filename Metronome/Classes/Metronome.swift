//
//  Metronome.swift
//  Metronome
//
//  Created by Ross Conquer on 05/12/2023.
// Some logic learned/used from https://developer.apple.com/library/archive/samplecode/HelloMetronome/Listings/iOSHelloMetronome_Metronome_swift.html#//apple_ref/doc/uid/TP40017587-iOSHelloMetronome_Metronome_swift-DontLinkElementID_12
//


import AVFoundation
import Foundation
import UIKit

// Give superclass NSObject for some Objective-C functionality
class Metronome: NSObject, ObservableObject {
    
    // Tempo
    @Published var tempoBPM: Double = 0.0
    @Published var tempoMarking = ""
    
    // TimeSig
    var timeSig = [0,0]
    var timeSigType = 0
    @Published var currentDenominator = ""
    @Published var beatsInBar = 0
    var firstLimit: Int = MetronomeConstants.DEFAULT_TIME_SIG[0]
    var beatNumber = 0
    
    // Audio engine & processing
    var audioSession = AVAudioSession()
    var audioEngine = AVAudioEngine()
    var mixerNode = AVAudioMixerNode()
    var playerNode = AVAudioPlayerNode()
//    var outputMixer = AVAudioMixerNode()
    var sampleRate: Double = 0.0
    private let backgroundThread = DispatchQueue.global(qos: .userInitiated)
    
    // Beat scheduling
    var syncQueue = DispatchQueue(label: "Metronome")
    var beatsToScheduleAhead = 0
    var beatsScheduled = 0
    var secondsPerBeat: Double = 0.0
    var samplesPerBeat: Double = 0.0
    var beatSampleValue: AVAudioFramePosition = 0
    var playerBeatSampleValue = AVAudioTime()
    var nextBeatSampleValue: Double = 0.0
     
    // Click sounds
    var currentSound = ""
    var allClickSets: Dictionary<String, Any> = [:]
    
    // Audio buffers & capsules
    var audioBuffers = [AVAudioPCMBuffer]()
    var bufferIndex = 0
    var audioBufferLabels = [String]()
    @Published var audioBufferCapsuleHeights = [CGFloat]()
    @Published var beatCapsuleWidth: CGFloat = 0
    
    // Audio buffer accents
    var userAccentPresets: [Int: [AccentArray.Preset]] = [:]
    var userChosenPresetVariations: [Int: AccentArray.Preset] = [:]
    var userCurrentAccentConfig: [String: [String]] = [:]
    
    // playback state bools
    var isPlaying = false
    var playerStarted = false
    
    // Tempo wheel interfacing
    var quickTempoChangeFromSlow: TempoChangeSpeedOptions = .normal
    var tempoWheelHeld = false
    var awaitTempoWheelRelease = false
    var savedBufferIndex: Int = 0
    var savedBeatNumber: Int = 0
    
    // Closure to handle ticks
    var onTick: ((Int, Int) -> Void)?
    
    // stores and notifies on change current play button type status
    @Published var playButtonType = MetronomeConstants.PLAY_BUTTON
    
    // class to update capsule views when metronome ticks (vital for 1/? time sig - enables capsule to flash)
    /// Seperated from main metronome class to stop whole view from updating (breaks other features)
    let ticker = MetronomeTicker()
    
    // Holds users choice of accents for current time sig.
    @Published var bufferAccents = AccentArray()
    
    @Published var deviceScreenSize: CGSize = CGSize(width: 0, height: 0)
    
    override init() {
        // Initialise Superclass (NSObject)
        super.init()
        
        // for testing purposes
//        UserDefaults.standard.reset()
        
        // Set the audio session type
        backgroundThread.sync {
            self.audioSession = AVAudioSession.sharedInstance()
            do { // .playback category lets app play in silent mode
                try self.audioSession.setCategory(.playback)
                try self.audioSession.setActive(true)
                let desiredBufferDuration = 0.093 // 4096 sample frames at 44.1
                try self.audioSession.setPreferredIOBufferDuration(desiredBufferDuration)
            } catch {
                print("Failed to configure audio session.")
            }
        }
        
        // Choose sample rate and channel number
        guard let format: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: MetronomeConstants.SAMPLE_RATE, channels: 2) else {
            fatalError("Unable to load sample rate: \(MetronomeConstants.SAMPLE_RATE).")
        }
        self.sampleRate = format.sampleRate
        
        // Attach and connect engine and playerNode
        backgroundThread.sync {
            // test
            self.audioEngine.attach(self.mixerNode)
            self.audioEngine.connect(self.mixerNode, to: self.audioEngine.mainMixerNode, format: format)
            
            self.audioEngine.attach(self.playerNode)
//            self.audioEngine.connect(self.playerNode, to: self.audioEngine.outputNode, format: format)
            self.audioEngine.connect(self.playerNode, to: self.mixerNode, format: format)
            

            
        }

        // load all click samples to memory
        self.allClickSets = self.loadAllClickSets()
        // NOTE: click samples need to be shorter than 0.15s
        /// (0.2s - shortest possible seconds per beat - at 300bpm) tempo extension to 400 0.15s shortest
        
        // Load users choice of sound. Defaults if nothing saved
        self.currentSound = settingsManager.clickSound.rawValue
        
        // Get stored accent preset values to limit the amount of accesses to computed properties withing settingsManager
        self.userAccentPresets = settingsManager.userAccentPresets
        // if defaults used, ensure defaults are saved as user presets for next pull
        if settingsManager.usedDefaultForUserAccentPresets {
            settingsManager.userAccentPresets = self.userAccentPresets
            settingsManager.usedDefaultForUserAccentPresets = false
        }
        
        self.userChosenPresetVariations = settingsManager.userChosenPresetVariations
        if settingsManager.usedDefaultsForUserChosenPresetVariations {
            settingsManager.userChosenPresetVariations = self.userChosenPresetVariations
            settingsManager.usedDefaultsForUserChosenPresetVariations = false
        }
        
        self.userCurrentAccentConfig = settingsManager.userCurrentAccentConfig

        // Set tempo to users previous
        let storedTempo = settingsManager.tempo
        self.setTempo(bpm: storedTempo)
        self.quickTempoChangeFromSlow = settingsManager.quickTempoChangeFromSlow == 1 ? .normal : .fast
        
        // Set TimeSig to users previous
        // click set initiated within setTimeSig
        let storedTimeSig = settingsManager.timeSignature
        self.setTimeSig(timeSigUpper: storedTimeSig[0], timeSigLower: storedTimeSig[1])
    }
    
    
    /* *** SECTION ***
     Audio file loading, for click sets */
    
    /**
    Loads all click samples into a dictionary.
     - Returns: A Nested Dictionary for all click types. */
    private func loadAllClickSets() -> Dictionary<String, Any> {
        // create empty dictionary containing dictionaries for all click types
        var allClickSets: [String:Dictionary] = [
            MetronomeConstants.DEFAULT_CLICK_NAME: [:],
            MetronomeConstants.SECONDARY_CLICK_NAME: [:],
        ]
        
        let EXT = MetronomeConstants.EXT
        
        // Load default
        do {
            let defaultSetNames = [
                MetronomeConstants.DEFAULT_CLICK_NAME + "1",
                MetronomeConstants.DEFAULT_CLICK_NAME + "2",
                MetronomeConstants.DEFAULT_CLICK_NAME + "3",
                MetronomeConstants.DEFAULT_CLICK_NAME + "4"
            ]
            allClickSets[MetronomeConstants.DEFAULT_CLICK_NAME] = try self.loadClickSetToMemory(clickSet: defaultSetNames, ext: EXT)
        } catch {
            print("Unable to load default click buffers: \(error)")
        }
        
        // Load Bell
        do {
            let bellSetNames = [
                MetronomeConstants.SECONDARY_CLICK_NAME + "1",
                MetronomeConstants.SECONDARY_CLICK_NAME + "2",
                MetronomeConstants.SECONDARY_CLICK_NAME + "3",
                MetronomeConstants.SECONDARY_CLICK_NAME + "4"
            ]
            allClickSets[MetronomeConstants.SECONDARY_CLICK_NAME] = try self.loadClickSetToMemory(clickSet: bellSetNames, ext: EXT)
        } catch {
            print("unable to load bell click buffers: \(error)")
        }
        
        return allClickSets
    }
    
    /**
     Loads a click set to memory as a dictionary.
     - Parameters:
        - clickSet: An array of strings denoting different file names of samples.
        - ext: The file type extension.
     - Throws: Any error returned from `loadAudioFileToPCMBuffer`.
     - Returns: A dictionary of string keys and `AVAudioPCMBuffer` values, making up a single click set. */
    private func loadClickSetToMemory(clickSet: [String], ext: String) throws -> Dictionary<String, AVAudioPCMBuffer> {
        var clickBuffers: [String: AVAudioPCMBuffer] = [:]
        
        for bufferName in clickSet {
            let result = self.loadAudioFileToPCMBuffer(res: bufferName, ext: ext)
            switch result {
            case .success(let temp):
                clickBuffers[bufferName] = temp
            case .failure(let error):
                throw error
            }
        }
        return clickBuffers
    }
    
    /// Audio error names for loadAudioFileToPCMBuffer
    enum AudioError: Error {
        case fileNotFound
        case fileTooLarge
        case incompatibleFormat
        case fileNotReadable
    }
    
    /**
     This function takes a string identifying the resource (filename) and the relevant extension. It returns a `Result`, containing the loaded buffer if successful, or the accompanying error message if it fails.
     - Parameters:
        - res: The resource (audio file) to load as a PCM buffer.
        - ext: Filetype extension.
     - Returns: A `Result` containing an `AVAudioPCMBuffer` if successful, or an `Error` if a failure occurs. */
    private func loadAudioFileToPCMBuffer(res: String, ext: String) -> Result<AVAudioPCMBuffer, Error> {
        // Load file url
        backgroundThread.sync {
            guard let audioFileURL = Bundle.main.url(forResource: res, withExtension: ext) else {
                // If file not found in Bundle, return a failure and the correct error message
                return .failure(AudioError.fileNotFound)
            }
            do {
                // Load audio file
                let audioFile = try AVAudioFile(forReading: audioFileURL)
                // Check if the file is too large (Unlikely to be necessary)
                if audioFile.length > Int64(Int.max) {
                    return .failure(AudioError.fileTooLarge)
                }
                // Create PCM buffer
                let bufferCapacity = AVAudioFrameCount(audioFile.length)
                guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: bufferCapacity) else {
                    return .failure(AudioError.incompatibleFormat)
                }
                // Read audio file into our newly created buffer
                try audioFile.read(into: audioBuffer)
                // return a sucess message containing our buffer
                return .success(audioBuffer)
            } catch {
                // return a failure if either try failed
                return .failure(AudioError.fileNotReadable)
            }
        }
    }

    
    /*
     *** END SECTION ***
     */
    
    
    /*
     *** SECTION ***
     Tempo and Time Signature setting
     */
    
    /**
     Sets Metronome Tempo.
     Calling this method:
     1. Updates the Metronome class's `tempoBPM` value.
     2. Updates the equivalent string tempo marking.
     3. Updates values related to beat scheduling.
     4. Restarts the metronome if it is playing, enabling the immediate effect of the tempo change.
     - Parameter bpm: The new tempo, as a double measuring beats per minute.
     - Precondition: `bpm` must be within the metronome's acceptable range of 1...400. */
    func setTempo(bpm: Double) {
        precondition(MetronomeConstants.BPM_ACC_RANGE.contains(bpm))
        
        // increasing tempo ? diff > 0
        let diff = bpm - self.tempoBPM
        
        self.updateTempo(bpm)
        self.updateTempoMarking()
        self.updateSchedulingValues()

        if diff > 0 && self.tempoBPM < 120 && self.isPlaying && (self.quickTempoChangeFromSlow == .fast) {
            if self.tempoWheelHeld {
                self.softStop()
                self.awaitTempoWheelRelease = true
            }
        }
    }
    
    /**
     Updates Metronome Tempo.
     - Parameter bpm: The new Tempo - A double measuring beats per minute. */
    private func updateTempo(_ bpm: Double) {
        self.tempoBPM = bpm
        settingsManager.tempo = self.tempoBPM
    }
    
    /// Updates Metronome Tempo Marking
    private func updateTempoMarking() {
        self.tempoMarking = self.getTempoMarking(self.tempoBPM)
    }
    
    /**
     Returns a string depending on the value of the given bpm.
     - Parameter bpm: A Double measuring beats per minute. 
     - Returns: A String which will be the italian word for a tempo range, or a message if the tempo falls out of range.*/
    private func getTempoMarking(_ bpm: Double) -> String {
        switch bpm {
        case 30..<40:
            return "Grave"
        case 40..<50:
            return "Lento"
        case 50..<60:
            return "Largo"
        case 60..<66:
            return "Larghetto"
        case 66..<76:
            return "Adagio"
        case 76..<98:
            return "Andante"
        case 98..<116:
            return "Moderato"
        case 116..<120:
            return "Allegro Moderato"
        case 120..<156:
            return "Allegro"
        case 156..<176:
            return "Vivace"
        case 176..<200:
            return "Presto"
        case 200..<401:
            return "Prestissimo"
        default:
            return "Tempo falls out of range"
        }
    }
    
    /// Updates seconds per beat, and beats to schedule ahead, both values are calculated relative to the chosen tempo.
    private func updateSchedulingValues() {
        self.secondsPerBeat = MetronomeConstants.SECONDS_PER_MIN / self.tempoBPM
//        self.beatsToScheduleAhead = max(Int(MetronomeConstants.TEMPO_RESPONSIVENESS / self.secondsPerBeat), 1)
        self.beatsToScheduleAhead = 1
    }
    
    
    /**
     Sets Metronome Time Signature.
     Calling this method -
     1. Updates the time signature - and makes it persistant.
     2. Updates various other values relating to or affected by the time signature.
        - beatsInBar
        - denominator
        - firstLimit
        - CapsuleWidths
     3. ReInitialises the click set using new values.
     4. Restarts the metronome to allow immediate adoption of new time signature (GCD reset).
     - Parameters:
        - timeSigUpper: An integer to be used to set the numerator if given, defaults to 0.
        - timeSigLower: An integer to be used to set the denominator if given, defaults to 0. 
     - Precondition: After checking for default values, both values checked to be in range. */
    func setTimeSig(timeSigUpper: Int = 0, timeSigLower: Int = 0) {
        // Use pre-existing values if default parameter values used
        let upper = timeSigUpper == 0 ? self.timeSig[0] : timeSigUpper
        let lower = timeSigLower == 0 ? self.timeSig[1] : timeSigLower
        
        precondition((
            MetronomeConstants.TIME_SIG_UPPER_ACC_RANGE.contains(upper)
            &&
            MetronomeConstants.TIME_SIG_LOWER_ACC_VALUES.contains(lower)
        ))
        
        self.updateTimeSig(upper, lower)
        self.makeTimeSigPersistant()
        self.updateBeatsInBar(upper)
        self.updateDenominator(lower)
        self.updateFirstLimit()
        self.updateCapsuleWidths()
        self.initClickSet(clickSetName: self.currentSound)
        self.checkArrayCopyOfSaved()
        self.restartMetronomeIfPlaying()
    }
    
    private func updateTimeSig(_ timeSigUpper: Int,_ timeSigLower: Int) {
        self.timeSig = [timeSigUpper, timeSigLower]
    }
    
    private func makeTimeSigPersistant() {
        settingsManager.timeSignature = self.timeSig
    }
    
    private func updateBeatsInBar(_ timeSigUpper: Int) {
        self.beatsInBar = timeSigUpper
    }
    
    private func updateDenominator(_ timeSigLower: Int) {
        switch timeSigLower {
        case 1:
            currentDenominator = "Semibreve"
        case 2:
            currentDenominator = "Minim"
        case 4:
            currentDenominator = "Crochet"
        case 8:
            currentDenominator = "Quaver"
        default:
            ()
        }
    }
    
    private func updateFirstLimit() {
        self.firstLimit = self.getFirstLimit(beats: self.beatsInBar)
    }
    
    private func getFirstLimit(beats: Int, defaultOrder: Bool = true) -> Int {
        if beats < 6 { return beats
        } else if beats == 6 { return 3
        } else if beats == 7 {
            if defaultOrder { return 3
            } else { return 4 }
        } else if beats == 8 { return 4
        } else if beats == 9 {
            if defaultOrder { return 4
            } else { return 5 }
        } else if beats == 10 { return 5
        } else if beats == 11 {
            if defaultOrder { return 5
            } else { return 6 }
        } else if beats == 12 { return 6
        } else if beats == 13 {
            if defaultOrder { return 6
            } else { return 7 }
        } else if beats == 14 { return 7
        } else if beats == 15 {
            if defaultOrder { return 7
            } else { return 8 }
        } else { return 8 }
    }
    
    /// Used in BeatView to return value and store in class
    func firstLimitWrapper(beats: Int, defaultOrder: Bool) -> Int {
        // Sets metronomes first limit + returns same value from wrapper function
        self.firstLimit = self.getFirstLimit(beats: beats, defaultOrder: defaultOrder)
        return self.firstLimit
    }
    
    func updateCapsuleWidths() {
//        var widthValue: CGFloat = 256
//        let widthValue = UIScreen.main.bounds.maxX * 0.66
//        print("device width: \(deviceScreen.size.width)")
        let twoThirdsWidth = deviceScreen.size.width * 0.66
        let widthValue = twoThirdsWidth > 300 ? 300 : twoThirdsWidth
            
        self.beatCapsuleWidth = {
            if self.beatsInBar < 6 { return widthValue / CGFloat(self.beatsInBar)
            } else if 6...8 ~= self.beatsInBar { return widthValue / 4
            } else if 9...10 ~= self.beatsInBar { return widthValue / 5
            } else if 11...12 ~= self.beatsInBar { return widthValue / 6
            } else if 13...14 ~= self.beatsInBar { return widthValue / 7
            } else if 15...16 ~= self.beatsInBar { return widthValue / 8
            } else { return CGFloat(32.0) }
        }()
    }
    
    /// If the Metronome is playing, class functions stop and start are called. This is to enable an immediate change of  time signature.
    private func restartMetronomeIfPlaying() {
        if !self.isPlaying { return }
        self.stop()
        self.start()
    }
    
    /*
     *** END SECTION ***
     */
    
    
    /*
     *** Section ***
     Click set/buffer accent (presets and users last used) initialisation
     */
    
    /**
     Initiates a click set for immediate use in the metronome.
     */
    func initClickSet(clickSetName: String) {
        // Prepare all presets for current time sig
        self.bufferAccents.currentPresets = self.loadAllAccentPresetsForTimeSig(timeSig: self.timeSig[0])
        // Load users last accent config and chosen preset
        let userCurrentAccentConfigForTimeSig = self.userCurrentAccentConfig[String(self.timeSig[0])]
        let accentArrayPreset = decideAccentArrayPreset()
        self.bufferAccents.settings = chooseUsersLastOrPreset(accentArrayPreset, userCurrentAccentConfigForTimeSig)
        useBufferSettingsToSetAccents(clickSetName)
    }
    
    
    /// Returns either default or saved sorted ($0 < $1) accent presets for the current time sig
    func loadAllAccentPresetsForTimeSig(timeSig: Int, useDefault: Bool = false) -> [AccentArray.Preset] {
        var userPresetsForTimeSig: [AccentArray.Preset] = []
        if useDefault {
            userPresetsForTimeSig = AccentArray.ALL_PRESETS[timeSig]!
        } else {
            userPresetsForTimeSig = self.userAccentPresets[timeSig] ?? [AccentArray.DEFAULT_PRESET_VARIATION[timeSig]!]
        }
       return sortedPresetArray(userPresetsForTimeSig)
    }
        
    /// Sorts and returns a given list of accent array presets and returns
    func sortedPresetArray(_ unsortedPresetArray: [AccentArray.Preset]) -> [AccentArray.Preset] {
        return unsortedPresetArray.sorted(by: { $0.orderIndex < $1.orderIndex })
    }
    
    
    /// Return users chosen preset variation for current time sig - returns empty array if nothing stored
    private func decideAccentArrayPreset() -> [String] {
        let upperNumerator: Int = timeSig[0]
        var presetSettingsToReturn: [String] = []
        // Ensure given numerator is within accepted range (converted to relative index)
        if !AccentArray.ACCEPTABLE_RANGE.contains(upperNumerator - 1) {
            print("Given upper numerator: \(upperNumerator) does not fall within the acceptable range: \(AccentArray.ACCEPTABLE_RANGE)")
            return presetSettingsToReturn
        }
        
        let userChosenPresetVariations = self.userChosenPresetVariations
        // Use safe value - retrieve saved preset
        if let chosenPresetVariationForTimeSig = userChosenPresetVariations[upperNumerator]?.array {
            presetSettingsToReturn = chosenPresetVariationForTimeSig
        } else {
            print("Empty preset chosen in decideAccentArrayPreset")
        }

        return presetSettingsToReturn
    }
   
    
    /// returns the accent array config the user just used, or the given preset retrieved from the previous function
    private func chooseUsersLastOrPreset(_ preset: [String],_ usersLast: [String]?) -> [String] {
        // Use users last if exists
        if let usersLastSafe = usersLast {
            if !usersLastSafe.isEmpty {
                return usersLastSafe
            }
        }
        if preset.isEmpty {
            return AccentArray.ALL_PRESETS[timeSig[0]]![0].array
        }
        return preset
    }
    
    
    ///  Amend all sibling arrays to contain the correct values - corresponding to the current click set
    private func useBufferSettingsToSetAccents(_ clickSetName: String) {
        // Prepare current chosen click set
        let clickSet = self.allClickSets[clickSetName] as! Dictionary<String, AVAudioPCMBuffer>
        // Declare empty local arrays for creation
        var localAudioBuffers: [AVAudioPCMBuffer] = []
        var localAudioBufferLabels: [String] = []
        var localAudioBufferCapsuleHeights: [CGFloat] = []
        
        // set all local array values to values set in bufferAccentSettings
        for i in 0..<AccentArray.LENGTH {
            let accent = self.bufferAccents.settings[i]
            // Set audio buffers themselves
            localAudioBuffers.append(clickSet[clickSetName + accent]!)
            // Set label for use identifying buffers
            localAudioBufferLabels.append(clickSetName + accent)
            // Set heights, for use when displaying capsules in beatview
            localAudioBufferCapsuleHeights.append(MetronomeConstants.CAPSULE_HEIGHTS[Int(accent)! - 1])
        }
        
        // Replace all values in class variables with newly created locals
        self.audioBuffers = localAudioBuffers
        self.audioBufferLabels = localAudioBufferLabels
        self.audioBufferCapsuleHeights = localAudioBufferCapsuleHeights
    }
    
    /*
     *** END SECTION ***
     */
    
    
    /*
     *** Section ***
     Preset, accent, and audio buffer manipulation
     */
    
    /// Sets the given preset as the preset to use, if no match found re-save an empty preset (no preset)
    func changeChosenPreset(_ preset: AccentArray.Preset) {
        if let index = self.bufferAccents.currentPresets.firstIndex(where: { $0 == preset }) {
            self.userCurrentAccentConfig[String(timeSig[0])] = preset.array
            settingsManager.userCurrentAccentConfig[String(timeSig[0])] = preset.array
            self.userChosenPresetVariations[self.timeSig[0]] = self.bufferAccents.currentPresets[index]
            // Store changed presets
            settingsManager.userChosenPresetVariations = self.userChosenPresetVariations
        } else {
            self.userChosenPresetVariations[self.timeSig[0]] = AccentArray.EMPTY_PRESET
        }
    }
    
    /// Saves current userAccentPresets (for all time sigs) in userDefaults
    func storeCurrentPresetsInDefaults() {
        // Get currently stored userAccentPresets
        var userAccentPresets = settingsManager.userAccentPresets
        // Edit current preset to include updated set of presets + default
        userAccentPresets[self.timeSig[0]] = self.bufferAccents.currentPresets
        // Set userAccentPresets
        self.userAccentPresets = userAccentPresets
        settingsManager.userAccentPresets = self.userAccentPresets
    }
    
    /// Chooses a preset, if the user sets up beat accents identical to that preset
    func checkArrayCopyOfSaved() {
        // Get userAccentPresets for current timesig if not possible
//        print("userAccentPresets for \(timeSig): \(String(describing:self.userAccentPresets[self.timeSig[0]]))")
        guard let currentTimeSigUserPresets = self.userAccentPresets[self.timeSig[0]] else {
            print("No user Accents saved after check within 'checkArrayCopyOfSaved()'")
            return
        }
        let userPresetsLength = currentTimeSigUserPresets.count
        let currentSettings = self.bufferAccents.settings
        for i in 0..<userPresetsLength {
            // Compare saved presets.array to current settings
            if currentTimeSigUserPresets[i].array == currentSettings {
                self.userChosenPresetVariations[self.timeSig[0]] = currentTimeSigUserPresets[i]
                settingsManager.userChosenPresetVariations = self.userChosenPresetVariations
                return
            }
        }
        // If we don't return, no arrays were a copy
        self.userChosenPresetVariations[self.timeSig[0]] = AccentArray.EMPTY_PRESET
        settingsManager.userChosenPresetVariations = self.userChosenPresetVariations
    }
    
    /// re-initilises one buffer (used when changing beat accents
    func reInitIndividualBuffer(bufferName: String, bufferIndex: Int, sampleNumber: Int) {
        
        let clickSet = self.allClickSets[self.currentSound] as! Dictionary<String, AVAudioPCMBuffer>
        self.audioBuffers[bufferIndex] = clickSet[bufferName]!

        self.audioBufferLabels[bufferIndex] = bufferName
        self.audioBufferCapsuleHeights[bufferIndex] = MetronomeConstants.CAPSULE_HEIGHTS[sampleNumber]
    }
    
    /// Stores curent beat accent configuration in user defaults
    func saveCurrentAccentConfig() {
        let currentConfig: [String] = self.bufferAccents.settings
        self.userCurrentAccentConfig[String(self.timeSig[0])] = currentConfig
        settingsManager.userCurrentAccentConfig = self.userCurrentAccentConfig
    }
    
    /*
     *** END SECTION ***
     */
    
    /*
     *** Metronome control and beat scheduling ***
     */
    
    // Simulates (programatically) the pressing of the play button
    func pressPlayStopButton() {
        if !self.isPlaying {
            self.playButtonType = MetronomeConstants.STOP_BUTTON
            self.start()
        } else {
            self.playButtonType = MetronomeConstants.PLAY_BUTTON
            self.stop()
        }
    }
    
    /// Starts the metronome
    func start() {
        
        self.backgroundThread.sync{
            do {
                try self.audioEngine.start()
            } catch {
                print("\(error)")
            }
        }

        self.isPlaying = true
        self.beatNumber = 0
        self.nextBeatSampleValue = 0
        self.bufferIndex = 0
        // set/reset output volume
        self.mixerNode.outputVolume = 1.0

        self.syncQueue.sync() {
            self.scheduleBeats()
        }
        

        
    }
    
    /// Starts the metronome without reseting playback values (for use when setting tempo, with .fast enabled in tempo change settings)
    func softStart() {
        
        self.isPlaying = true
        self.nextBeatSampleValue = 0
        
        self.bufferIndex = self.savedBufferIndex
        self.beatNumber = self.savedBeatNumber
        
        self.syncQueue.sync() {
            self.scheduleBeats()
        }
    }
    
    /// Updates playback and scheduling values, inbetween each tick
    func setBeatValues() {
        // Important to allow these values to be calculated for each tick, so that
        // when user is changing tempo, changes take effect.
        self.secondsPerBeat = MetronomeConstants.SECONDS_PER_MIN / self.tempoBPM
        self.samplesPerBeat = self.secondsPerBeat * self.sampleRate
        self.beatSampleValue = AVAudioFramePosition(self.nextBeatSampleValue)
        self.playerBeatSampleValue =  AVAudioTime(sampleTime: self.beatSampleValue, atRate: self.sampleRate)
    }
    
    /// Main beat scheduling function. Beats are scheduled with playerNodes scheduleBuffer, at a designated sample time, calculated with sample rate and seconds per beat.
    func scheduleBeats() {
        
        // First check if metronome is running
        if (!self.isPlaying) { return }

        while (self.beatsScheduled < self.beatsToScheduleAhead) {
            
            self.setBeatValues()
            
            // Schedule audio
            self.playerNode.scheduleBuffer(self.audioBuffers[self.bufferIndex], at: self.playerBeatSampleValue, completionHandler: {
                self.syncQueue.sync() {
                    
                    // decrement beatsScheduled to make condition for loop true
                    self.beatsScheduled -= 1
                    
                    // schedule more beats
                    self.scheduleBeats()
                }
            })
            
            if (!self.playerStarted) {
                self.playerNode.play()
                self.playerStarted = true
            }
            
            // update onTick for visual cues
            let callbackBeat = self.beatNumber - 1
            var bar = 0
            var beat = 0
            if callbackBeat != 0 {
                bar = (callbackBeat / self.beatsInBar) // Keep as Ints to chop deicmal
                beat = (callbackBeat % self.beatsInBar)
            } else {
                bar = 0
                beat = 0
            }
            if self.isPlaying {
                self.onTick?(bar, beat)
            }

            self.beatNumber += 1
            self.beatsScheduled += 1
            
            DispatchQueue.main.async {
                self.ticker.tick.toggle()
            }
            
            // Increment sound buffer to next in array for next beat
            self.bufferIndex += 1
            // Go to start if at end
            if self.bufferIndex > self.beatsInBar - 1 {
                self.bufferIndex = 0
            }
            
            self.nextBeatSampleValue += self.samplesPerBeat
        }
    }
    
    func fadeOut() {
        let volumes: [Float] = [
            0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0
        ]
        // fade volume out
        for volume in volumes {
            self.mixerNode.outputVolume = volume
            usleep(10000)
        }
    }
    
    /// Stops the metronome
    func stop() {
        
        self.isPlaying = false
        self.playerStarted = false
        self.onTick?(0, 0)
        
        fadeOut()

        self.playerNode.stop()
        self.playerNode.reset()
        self.audioEngine.stop()
    }
    
    /// Stops the metronome without stopping audio engine and resetting values. (for use when changing tempo)
    func softStop() {
        
        self.savedBufferIndex = self.bufferIndex
        self.savedBeatNumber = self.beatNumber
        
        self.isPlaying = false
        
        self.playerNode.stop()
        
        self.playerStarted = false
    }
    
    /*
     *** END SECTION ***
     */
    
    
    /// Deinitialise class
    deinit {
        self.stop()
        
        do {
            try self.audioSession.setActive(false)
        } catch {
            print("\(error)")
        }
        
        self.audioEngine.detach(self.playerNode)
    }
}
