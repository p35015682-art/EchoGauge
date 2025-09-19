//
//  Main.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

struct ROOTVIEW: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("colorSchemePreference") private var colorSchemePreference: Int = 0 // 0: System, 1: Light, 2:
    @State private var isOnboardingComplete: Bool = false
    
    var body: some View {
        ContentView()
            .preferredColorScheme(colorScheme)
            .sheet(isPresented: $isOnboardingComplete) {
                OnboardingView(isPresented: $isOnboardingComplete)
            }
            .onAppear {
                if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                    isOnboardingComplete = true
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
            }
    }
    
    
    var colorScheme: ColorScheme? {
        switch colorSchemePreference {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil // nil означает "следовать системе"
        }
    }
}

#Preview {
    ROOTVIEW()
}































