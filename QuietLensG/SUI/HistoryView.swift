//
//  HistoryView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

struct HistoryView: View {
    @State private var records: [MeasurementRecord] = []
    @State private var selectedRecord: MeasurementRecord?
    @State private var shareableURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Показываем заглушку, если массив records пуст
                if records.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(records) { record in
                            HistoryCell(record: record)
                                .onTapGesture {
                                    selectedRecord = record
                                }
                        }
                        .onDelete(perform: deleteRecord)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                // Добавляем условие, чтобы кнопки не показывались на пустом экране
                if !records.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: exportCSV) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .onAppear {
                records = PersistenceManager.shared.load()
            }
            .sheet(item: $selectedRecord) { record in
                MeasurementDetailView(record: record)
            }
            .sheet(item: $shareableURL) { url in
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        // Эта логика требует сохранения всего массива обратно в UserDefaults
        // Для простоты, пока просто удаляем из view.
        // В реальном приложении нужно обновить PersistenceManager
        records.remove(atOffsets: offsets)
        // PersistenceManager.shared.saveAll(records: records) // <-- Такой метод нужно создать
    }
    
    private func exportCSV() {
        let header = "type,date,averageValue,peakValue,duration\n"
        
        let formatter = ISO8601DateFormatter()
        
        let rows = records.map { record -> String in
            let type = record.type.rawValue
            let date = formatter.string(from: record.date)
            let avg = String(format: "%.2f", record.averageValue)
            let peak = String(format: "%.2f", record.peakValue)
            let duration = String(record.duration)
            return "\(type),\(date),\(avg),\(peak),\(duration)"
        }.joined(separator: "\n")
        
        let csvString = header + rows
        
        // Сохраняем во временный файл
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("EchoGauge_export.csv")
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            shareableURL = tempURL
        } catch {
            print("Failed to create CSV file: \(error)")
        }
    }
}

// Новое View для заглушки
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 80))
                .foregroundColor(Color.secondary.opacity(0.5))
            
            Text("No History Yet")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Start a measurement on the 'Live' or 'Vibration' tabs to see your records here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct HistoryCell: View {
    let record: MeasurementRecord
    
    var body: some View {
        HStack {
            Image(systemName: record.type == .noise ? "waveform" : "circle.grid.cross")
                .foregroundColor(Color.theme.accent)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(record.type.rawValue)
                    .font(.system(size: 18, weight: .bold))
                Text("\(record.formattedDate) | Avg: \(String(format: "%.1f", record.averageValue))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Peak: \(String(format: "%.1f", record.peakValue))")
                .font(.footnote)
                .padding(5)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(5)
        }
        .padding(.vertical, 8)
    }
}
