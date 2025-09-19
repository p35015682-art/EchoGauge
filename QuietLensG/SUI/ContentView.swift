//
//  ContentView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        TabView {
            LiveView()
                .tabItem {
                    Label("Live", systemImage: "waveform.circle.fill")
                }
            
            VibrationView()
                .tabItem {
                    Label("Vibration", systemImage: "circle.grid.cross")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(Color.theme.accent)
        // Передаем менеджеры в окружение для доступа из дочерних view
        .environmentObject(audioManager)
        .environmentObject(motionManager)
        .onAppear(perform: requestPermissions)
    }
    
    private func requestPermissions() {
        // Запрос разрешений при первом запуске
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                // Обработать отказ в доступе (показать алерт)
                print("Microphone permission denied.")
            }
        }
        // Здесь можно добавить запрос на уведомления
    }
}
