//
//  LiveView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

struct LiveView: View {
    @EnvironmentObject var audioManager: AudioManager
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Фон-градиент
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.gradientTop, Color.theme.gradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.8)
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Круговой индикатор
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 20))
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(audioManager.decibels / 120.0))
                        .stroke(noiseLevelColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: audioManager.decibels)
                    
                    VStack {
                        Text("\(Int(audioManager.decibels))")
                            .font(.system(size: 60, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Text("dB")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(noiseLevelStatus)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                }
                .frame(width: 250, height: 250)
                
                Spacer()
                
                // Кнопка Start/Stop
                Button(action: {
                    audioManager.startStopMeasurement { record in
                        if let record = record {
                            PersistenceManager.shared.save(record: record)
                            showAlert = true
                        }
                    }
                }) {
                    Text(audioManager.isRecordingSample ? "Stop Measurement" : "Start Measurement")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(audioManager.isRecordingSample ? Color.theme.warning : Color.theme.accent)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            audioManager.startMonitoring()
        }
        .onDisappear {
            // audioManager.stopMonitoring() // Раскомментируйте, если хотите останавливать при переключении таба
        }
        .alert("Saved", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Noise measurement has been saved to History.")
        }
        .onAppear {
            audioManager.checkPermission() // Используем новый метод проверки
        }
        .alert("Microphone Access Denied", isPresented: $audioManager.permissionDenied) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                // Открываем настройки приложения
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("EchoGauge needs access to your microphone to measure noise. Please enable it in Settings.")
        }
        //
    }
    
    var noiseLevelStatus: String {
        switch audioManager.decibels {
        case 0...40: return "Quiet"
        case 41...65: return "Normal"
        case 66...85: return "Loud"
        default: return "Very Loud"
        }
    }
    
    var noiseLevelColor: Color {
        switch audioManager.decibels {
        case 0...65: return Color.theme.accent
        case 66...85: return Color.yellow
        default: return Color.theme.warning
        }
    }
}
