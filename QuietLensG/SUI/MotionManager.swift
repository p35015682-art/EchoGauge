//
//  MotionManager.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import CoreMotion
import Combine

class MotionManager: ObservableObject {
    @Published var currentAmplitude: Double = 0.0
    @Published var peakAmplitude: Double = 0.0
    @Published var isRecordingSample = false
    @Published var liveDataPoints: [CGFloat] = Array(repeating: 0, count: 100) // Массив для графика
    
    private let motionManager = CMMotionManager()
    private var recordedDataPoints: [Double] = []
    
    func startUpdates() {
        peakAmplitude = 0.0
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1 // Увеличим частоту для плавности графика
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let self = self, let data = data else { return }
                
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                
                let amplitude = sqrt(x*x + y*y + z*z) // Величина вектора в G
                
                self.currentAmplitude = amplitude * 9.81 // Переводим в m/s²
                if self.currentAmplitude > self.peakAmplitude {
                    self.peakAmplitude = self.currentAmplitude
                }
                
                // Обновляем массив для live-графика
                // Нормализуем значение (например, от 0 до 2g)
                let normalizedValue = CGFloat(min(max(amplitude, 0), 2.0) / 2.0)
                self.liveDataPoints.append(normalizedValue)
                if self.liveDataPoints.count > 100 {
                    self.liveDataPoints.removeFirst()
                }
                
                if self.isRecordingSample {
                    self.recordedDataPoints.append(self.currentAmplitude)
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func resetPeak() {
        peakAmplitude = 0
    }
    
    func recordSample(completion: @escaping (MeasurementRecord) -> Void) {
        recordedDataPoints.removeAll()
        isRecordingSample = true
        resetPeak()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.isRecordingSample = false
            let peak = self.peakAmplitude
            let average = self.recordedDataPoints.isEmpty ? 0 : self.recordedDataPoints.reduce(0, +) / Double(self.recordedDataPoints.count)
            
            let record = MeasurementRecord(
                id: UUID(),
                type: .vibration,
                date: Date(),
                averageValue: average,
                peakValue: peak,
                duration: 30,
                dataPoints: self.recordedDataPoints
            )
            self.recordedDataPoints.removeAll()
            completion(record)
        }
    }
}
