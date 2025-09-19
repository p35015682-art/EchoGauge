//
//  PersistenceManager.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let key = "measurementHistory"
    
    private init() {}
    
    func save(record: MeasurementRecord) {
        var history = load()
        history.insert(record, at: 0) // Добавляем в начало
        
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save record: \(error)")
        }
    }
    
    func load() -> [MeasurementRecord] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        
        do {
            let history = try JSONDecoder().decode([MeasurementRecord].self, from: data)
            return history
        } catch {
            print("Failed to load history: \(error)")
            return []
        }
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}


import SwiftUI

// Хелпер для показа системного окна "Поделиться"
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// Расширение, чтобы URL можно было использовать с .sheet(item: ...)
extension URL: Identifiable {
    public var id: String { self.absoluteString }
}
