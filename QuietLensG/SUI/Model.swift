//
//  Model.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import Foundation

// Тип измерения
enum MeasurementType: String, Codable {
    case noise = "Noise"
    case vibration = "Vibration"
}

// Модель для одного измерения
struct MeasurementRecord: Identifiable, Codable {
    let id: UUID
    let type: MeasurementType
    let date: Date
    let averageValue: Double
    let peakValue: Double
    let duration: TimeInterval
    let dataPoints: [Double] // Сохраняем все точки для построения графика
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
