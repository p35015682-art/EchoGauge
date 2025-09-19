//
//  OnboardingView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

// Модель для одного слайда онбординга
struct OnboardingSlide: Identifiable {
    let id = UUID()
    let systemImageName: String
    let title: String
    let description: String
}

// Данные для всех слайдов
private let onboardingSlides: [OnboardingSlide] = [
    .init(systemImageName: "waveform.circle.fill",
          title: "Welcome to EchoGauge",
          description: "Your personal tool to measure and track noise and vibration levels around you."),
    .init(systemImageName: "mic.fill",
          title: "Measure Noise Levels",
          description: "Use the 'Live' tab to see the current sound level in decibels. Save 30-second samples to your history."),
    .init(systemImageName: "circle.grid.cross.fill",
          title: "Analyze Vibrations",
          description: "Switch to the 'Vibration' tab to monitor device vibrations in real-time using the accelerometer."),
    .init(systemImageName: "clock.fill",
          title: "Keep a Record",
          description: "All your saved measurements are stored in the 'History' tab. Review your data anytime and export it to CSV.")
]

struct OnboardingView: View {
    // Эта переменная будет отвечать за закрытие окна
    @Binding var isPresented: Bool
    
    @State private var currentTab = 0

    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                ForEach(onboardingSlides.indices, id: \.self) { index in
                    OnboardingSlideView(slide: onboardingSlides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                if currentTab == onboardingSlides.count - 1 {
                    // Кнопка "Начать" на последнем слайде
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.accent)
                            .cornerRadius(15)
                    }
                } else {
                    // Кнопка "Далее"
                    Button(action: {
                        withAnimation {
                            currentTab += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.accent)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}


struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: slide.systemImageName)
                .font(.system(size: 100))
                .foregroundColor(Color.theme.accent)
                .padding()

            Text(slide.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(slide.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 80)
    }
}
