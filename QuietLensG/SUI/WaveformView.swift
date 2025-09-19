//
//  WaveformView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

struct WaveformView: View {
    let values: [CGFloat]
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let step = width / CGFloat(max(values.count - 1, 1))

            Path { path in
                for (i, v) in values.enumerated() {
                    let x = CGFloat(i) * step
                    // Нормализуем значение Y, чтобы 0 был в центре, а пики уходили вверх и вниз
                    let y = height / 2 - (v * height / 2)
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.theme.accent, lineWidth: 2)
        }
        .clipped() // Чтобы график не выходил за границы
    }
}
