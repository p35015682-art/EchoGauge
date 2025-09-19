//
//  AudioManager.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var decibels: Float = 0.0
    @Published var isRecordingSample = false
    @Published var permissionDenied = false
    
    // Считываем смещение напрямую из UserDefaults
    @AppStorage("noiseCalibrationOffset") private var noiseOffset: Double = 0.0
    
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    private var dataPoints: [Double] = []
    
    override init() {
        super.init()
    }
    
    func startMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
            
            let url = URL(fileURLWithPath: "/dev/null")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.updateDecibels()
            }
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    private func updateDecibels() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        let power = audioRecorder.averagePower(forChannel: 0)
        
        let calibratedPower = power + Float(noiseOffset)
        // Преобразуем из логарифмической шкалы в дБ (0-120)
        let newDecibels = max(0, min(120, 120 + calibratedPower))
        
        DispatchQueue.main.async {
            self.decibels = newDecibels
            if self.isRecordingSample {
                self.dataPoints.append(Double(newDecibels))
            }
        }
    }
    
    func startStopMeasurement(completion: @escaping (MeasurementRecord?) -> Void) {
        if isRecordingSample {
            // Stop
            isRecordingSample = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Даем время на последнее обновление
                let peak = self.dataPoints.max() ?? 0
                let average = self.dataPoints.isEmpty ? 0 : self.dataPoints.reduce(0, +) / Double(self.dataPoints.count)
                
                let record = MeasurementRecord(
                    id: UUID(),
                    type: .noise,
                    date: Date(),
                    averageValue: average,
                    peakValue: peak,
                    duration: 30,
                    dataPoints: self.dataPoints
                )
                self.dataPoints.removeAll()
                completion(record)
            }
        } else {
            // Start
            dataPoints.removeAll()
            isRecordingSample = true
            // Автоматическая остановка через 30 секунд
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.isRecordingSample { // Проверяем, не остановил ли пользователь вручную
                    self.startStopMeasurement(completion: completion)
                }
            }
            completion(nil)
        }
    }
    
    
    func calibrate() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        // Мы хотим, чтобы текущий уровень стал "тишиной" (около 20-30дБ).
        // Для простоты, мы просто сохраним *противоположное* значение текущей мощности
        // чтобы при сложении оно давало 0.
        let currentPower = audioRecorder.averagePower(forChannel: 0)
        self.noiseOffset = Double(-currentPower)
    }
    
    // Метод для сброса
    func resetCalibration() {
        self.noiseOffset = 0.0
    }
    
    func checkPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionDenied = false
            startMonitoring()
        case .denied:
            permissionDenied = true
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionDenied = !granted
                    if granted {
                        self?.startMonitoring()
                    }
                }
            }
        @unknown default:
            permissionDenied = true
        }
    }
}
