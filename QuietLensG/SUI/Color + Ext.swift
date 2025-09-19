//
//  Color + Ext.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor") // Используем Asset Catalog для #4ECDC4
    let warning = Color("WarningColor") // Используем Asset Catalog для #FF6B6B
    let backgroundLight = Color(hex: "#F7F7F7")
    let backgroundDark = Color(hex: "#121212")
    let gradientTop = Color(hex: "#4ECDC4")
    let gradientBottom = Color(hex: "#1A535C")
    
    // Добавим в Asset Catalog цвета с именами AccentColor и WarningColor
    // и зададим им значения #4ECDC4 и #FF6B6B соответственно.
    // Это лучший подход для поддержки светлой/темной темы.
}

// Хелпер для использования HEX-цветов
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
