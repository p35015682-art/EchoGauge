//
//  MeasurementDetailView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI
import Charts

struct MeasurementDetailView: View {
    let record: MeasurementRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(record.type.rawValue) Details")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(record.formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                MetricView(label: "Average", value: String(format: "%.1f", record.averageValue), unit: record.type == .noise ? "dB" : "m/s²")
                Spacer()
                MetricView(label: "Peak", value: String(format: "%.1f", record.peakValue), unit: record.type == .noise ? "dB" : "m/s²")
            }
            
            Text("30-Second Graph")
                .font(.headline)
                .padding(.top)
            
            // Используем новый фреймворк Charts (iOS 16+)
            Chart(Array(record.dataPoints.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Value", value)
                )
            }
            .chartYScale(domain: 0...(record.peakValue * 1.2)) // Динамический масштаб
            .frame(height: 250)
            .foregroundColor(Color.theme.accent)
            
            Spacer()
        }
        .padding()
    }
}


struct MetricView: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.semibold)
            Text(unit)
                .font(.caption)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}
