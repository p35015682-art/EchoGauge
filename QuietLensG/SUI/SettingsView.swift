//
//  SettingsView.swift
//  QuietLensG
//
//  Created by D K on 19.09.2025.
//

import SwiftUI

struct SettingsView: View {
    // Доступ к менеджеру аудио для калибровки
    @EnvironmentObject var audioManager: AudioManager
    
    // Переменные, которые сохраняются между запусками приложения
    @AppStorage("colorSchemePreference") private var colorSchemePreference: Int = 0
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = false
    @AppStorage("reminderInterval") private var reminderInterval: Double = 4.0

    // Состояния для управления алертами
    @State private var showCalibrationAlert = false
    @State private var calibrationAlertTitle = ""
    @State private var calibrationAlertMessage = ""

    @State private var showPermissionDeniedAlert = false

    var body: some View {
        NavigationView {
            Form {
                
                // MARK: - Calibration Section
                Section(header: Text("Calibration")) {
                    Button("Calibrate to Current Environment") {
                        audioManager.calibrate()
                        setCalibrationAlert(title: "Calibrated", message: "The current noise level is now set as the baseline offset.")
                    }
                    
                    Button("Reset Calibration", role: .destructive) {
                        audioManager.resetCalibration()
                        setCalibrationAlert(title: "Reset Complete", message: "Calibration has been reset to default values.")
                    }
                }
                
                // MARK: - Notifications Section
                Section(header: Text("Notifications")) {
                    // Используем Binding с кастомной логикой set
                    Toggle("Enable Reminders", isOn: Binding<Bool>(
                        get: { self.remindersEnabled },
                        set: { isEnabled in
                            if isEnabled {
                                // Если пользователь пытается включить, запускаем процесс запроса разрешения
                                requestNotificationPermission()
                            } else {
                                // Если выключает, просто отменяем уведомления
                                NotificationManager.shared.cancelReminders()
                                self.remindersEnabled = false
                            }
                        }
                    ))

                    // Слайдер показывается только если уведомления включены
                    if remindersEnabled {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Remind me every \(Int(reminderInterval)) hours")
                            Slider(value: $reminderInterval, in: 1...24, step: 1)
                                .onChange(of: reminderInterval) { _ in
                                    // Немедленно обновляем расписание при изменении слайдера
                                    if remindersEnabled {
                                        NotificationManager.shared.scheduleReminders(intervalInHours: Int(reminderInterval))
                                    }
                                }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    Link("Privacy Policy", destination: URL(string: "https://github.com")!)
                }
            }
            .navigationTitle("Settings")
            // Алерт для калибровки
            .alert(calibrationAlertTitle, isPresented: $showCalibrationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(calibrationAlertMessage)
            }
            // Алерт для случая, когда доступ к уведомлениям запрещен
            .alert("Permission Denied", isPresented: $showPermissionDeniedAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Open Settings") {
                    NotificationManager.shared.openAppSettings()
                }
            } message: {
                Text("To enable reminders, please allow notifications for EchoGauge in your device's Settings.")
            }
        }
        .accentColor(Color.theme.accent)
    }
    
    /// Запускает процесс запроса разрешений на уведомления.
    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermissionOrGuideToSettings { granted in
            if granted {
                // Если разрешение получено, включаем тумблер и планируем уведомления
                self.remindersEnabled = true
                NotificationManager.shared.scheduleReminders(intervalInHours: Int(self.reminderInterval))
            } else {
                // Если разрешение не получено (было отказано ранее),
                // оставляем тумблер выключенным и показываем алерт
                self.remindersEnabled = false
                self.showPermissionDeniedAlert = true
            }
        }
    }

    /// Устанавливает текст и показывает алерт для калибровки.
    private func setCalibrationAlert(title: String, message: String) {
        self.calibrationAlertTitle = title
        self.calibrationAlertMessage = message
        self.showCalibrationAlert = true
    }
}
