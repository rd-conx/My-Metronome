//
//  CustomColorSchemeViewModifier.swift
//  Metronome
//
// Courtesy of ryanlintott - github 2021
//

import SwiftUI

struct CustomColorSchemeViewModifier: ViewModifier {
    // This variable holds the currently active colour scheme (changed with calls to preferredColorScheme)
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var customColorScheme: CustomColorScheme
    
    // Temp value used for changing colorScheme when switching customColorScheme to .system
    @State private var tempColorScheme: ColorScheme? = nil
    
    init(_ customColorScheme: Binding<CustomColorScheme>) {
        self._customColorScheme = customColorScheme
    }

    // This function is required to get the system color scheme
    func getSystemColorScheme() -> ColorScheme {
        return UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
    }

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(tempColorScheme ?? customColorScheme.colorScheme)
            .onChange(of: customColorScheme) { oldValue, newValue in
                if newValue == .system {
                    tempColorScheme = getSystemColorScheme()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if customColorScheme == .system {
                    let systemColorScheme = getSystemColorScheme()
                    if systemColorScheme != colorScheme {
                        tempColorScheme = systemColorScheme
                    }
                }
            }
            .onChange(of: tempColorScheme) { oldValue, newValue in
                if newValue != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Resets tempColorScheme back to nil. This occurs after colorScheme has been updated
                        tempColorScheme = nil
                    }
                }
            }
    }
}

extension View {
    func customColorScheme(_ customColorScheme: Binding<CustomColorScheme>) -> some View {
        self.modifier(CustomColorSchemeViewModifier(customColorScheme))
    }
}
