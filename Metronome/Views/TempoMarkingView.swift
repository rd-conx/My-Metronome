//
//  TempoMarkingView.swift
//  Metronome
//
//  Created by Ross Conquer on 18/12/2023.
//

import SwiftUI

enum TempoMarking: String, CaseIterable, Identifiable {
    var id: Self { self }
    case grave = "Grave"
    case lento = "Lento"
    case largo = "Largo"
    case larghetto = "Larghetto"
    case adagio = "Adagio"
    case andante = "Andante"
    case moderato = "Moderato"
    case allegroModerato = "Allegro Moderato"
    case allegro = "Allegro"
    case vivace = "Vivace"
    case presto = "Presto"
    case prestissimo = "Prestissimo"
}

struct TempoMarkingView: View {
    
    @EnvironmentObject var metronome: Metronome
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var tempoField: Int = 0
    @State private var tempoFieldChangedManually = true
    
    @State private var tempoUpperBound = Int(MetronomeConstants.BPM_ACC_RANGE.upperBound)
    @State private var tempoLowerBound = Int(MetronomeConstants.BPM_ACC_RANGE.lowerBound)
    
    @FocusState private var isTempoInputActive: Bool
    
    @EnvironmentObject var opacities: Opacities
    @EnvironmentObject var deviceScreen: DeviceScreen
    
    @State private var tempoMarkingSelection: TempoMarking = TempoMarking.adagio
    @State private var markingSelectionChangedManually = false
    
    @State var radius: CGFloat = 0
    
    var body: some View {
        
        let foreground: Color = colorScheme == .light ? .black : .white
        
        VStack {
            TextField("", value: $tempoField, formatter: NumberFormatter())
                .font(.system(size: 20))
                .bold()
                .frame(maxWidth: 80)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($isTempoInputActive)
                .onAppear {
                    self.tempoField = Int(metronome.tempoBPM)
                }
                .onChange(of: metronome.tempoBPM) { oldValue, newValue in
                    tempoFieldChangedManually = false
                    self.tempoField = Int(newValue)
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        tempoFieldChangedManually = true
                    }
                    
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button("Done") {
                            isTempoInputActive = false
                            submitTempoChoice(self.tempoField)
                            withAnimation(.easeInOut(duration: 0.5)) {
//                                opacities.tempoView = 1
                                opacities.tempoOrTimeSigSelector = 1
                            }
                        }
                    }
                }
                .onChange(of: isTempoInputActive) {
                    if isTempoInputActive == true {
                        withAnimation(.easeInOut(duration: 0.3)) {
//                            opacities.tempoView = 0
                            opacities.tempoOrTimeSigSelector = 0
                        }
                    }
                }
//                .ignoresSafeArea(.keyboard, edges: .bottom)
            
            ZStack {
//                TimeSigArrowsView(radius: $radius)
//                    .opacity(opacities.tempoMarkingView)
//                    .onAppear {
//                        self.radius = deviceScreen.componentSizing[.radius]!
//                    }
//                    .onChange(of: deviceScreen.size) {
//                        self.radius = deviceScreen.componentSizing[.radius]!
//                    }
                Menu("\(metronome.tempoMarking)") {
                    ForEach(TempoMarking.allCases) { marking in
                        Button(action: {
                            let tempo = getTempoLowerBound(from: marking.rawValue)
                            if MetronomeConstants.BPM_ACC_RANGE.contains(tempo) {
                                let oldTempo = metronome.tempoBPM
                                metronome.setTempo(bpm: tempo)
                                if metronome.quickTempoChangeFromSlow == .fast && oldTempo <= 120 {
                                    metronome.softStop()
                                    metronome.softStart()
                                }
                            }
                        }) {
                            HStack {
                                Text(marking.rawValue)
                                if marking.rawValue == metronome.tempoMarking {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                .tint(foreground)
            }

            
            DenominatorView(opacity: 1)

        }
    }
    
    private func submitTempoChoice(_ newTempo: Int) {
        var tempoToSubmit = newTempo
        if tempoToSubmit < self.tempoLowerBound {
            tempoToSubmit = self.tempoLowerBound
        } else if tempoToSubmit > tempoUpperBound {
            tempoToSubmit = tempoUpperBound
        }
        self.tempoField = tempoToSubmit
        let oldTempo = metronome.tempoBPM
        metronome.setTempo(bpm: Double(tempoToSubmit))
        if metronome.quickTempoChangeFromSlow == .fast && oldTempo <= 120 {
            metronome.softStop()
            metronome.softStart()
        }
    }
    
    private func getTempoLowerBound(from marking: String) -> Double {
        switch marking {
        case "Grave":
            return 30
        case "Lento":
            return 40
        case "Largo":
            return 50
        case "Larghetto":
            return 60
        case "Adagio":
            return 66
        case "Andante":
            return 76
        case "Moderato":
            return 98
        case "Allegro Moderato":
            return 116
        case "Allegro":
            return 120
        case "Vivace":
            return 156
        case "Presto":
            return 176
        case "Prestissimo":
            return 200
        default:
            return 404 // Return 0 or any value to represent an unknown marking
        }
    }
}

//#Preview {
//    TempoMarkingView()
//}
//
//struct TempoMarkingViewPreviews: PreviewProvider {
//    @ObservedObject var metronome = Metronome()
//    static var previews: some View {
//        TempoMarkingView()
//            .environmentObject(metronome)
//    }
//}
