//
//  VibrationView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

struct VibrationView: View {
    @EnvironmentObject var motionManager: MotionManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAlert = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack(spacing: 20) {
                Text("Vibration Analysis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                WaveformView(values: motionManager.liveDataPoints)
                    .frame(height: 200)
                    .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Text(String(format: "Current: %.2f m/s²", motionManager.currentAmplitude))
                        .font(.system(.title2, design: .monospaced))
                    Text(String(format: "Peak: %.2f m/s²", motionManager.peakAmplitude))
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    motionManager.recordSample { record in
                        PersistenceManager.shared.save(record: record)
                        showAlert = true
                    }
                }) {
                    Text(motionManager.isRecordingSample ? "Recording (30s)..." : "Record 30s")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(motionManager.isRecordingSample ? Color.theme.warning : Color.theme.accent)
                        .cornerRadius(25)
                }
                .disabled(motionManager.isRecordingSample)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .onAppear {
                motionManager.startUpdates()
            }
            .onDisappear {
                motionManager.stopUpdates()
            }
            .alert("Saved", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Vibration measurement has been saved to History.")
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
