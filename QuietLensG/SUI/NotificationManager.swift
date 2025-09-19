import UserNotifications
import UIKit // Для открытия настроек

class NotificationManager {
    static let shared = NotificationManager()
    
    // Этот enum поможет нам передать результат в View
    enum PermissionStatus {
        case granted
        case denied
        case notDetermined
    }
    
    private init() {}
    
    // Новый умный метод для запроса
    func requestPermissionOrGuideToSettings(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        // 1. Сначала проверяем текущий статус авторизации
        center.getNotificationSettings { settings in
            
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                
                case .authorized, .provisional, .ephemeral:
                    // 2. Разрешение уже есть. Просто говорим "успех".
                    completion(true)
                    
                case .denied:
                    // 3. Пользователь отказал. Говорим "неудача" и даем View возможность показать алерт.
                    completion(false)
                    
                case .notDetermined:
                    // 4. Разрешение еще не запрашивалось. Показываем системный диалог.
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            completion(granted)
                        }
                    }
                
                @unknown default:
                    // 5. На случай будущих изменений в API
                    completion(false)
                }
            }
        }
    }
    
    // Функция для открытия настроек приложения
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }

    // ... остальные методы (scheduleReminders, cancelReminders) остаются без изменений ...
    
    func scheduleReminders(intervalInHours: Int) {
        cancelReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to check the noise"
        content.body = "Let's see how loud your environment is right now."
        content.sound = .default
        
        let timeInterval = TimeInterval(intervalInHours * 3600)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        
        let request = UNNotificationRequest(identifier: "noise-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("Scheduled reminders for every \(intervalInHours) hours.")
    }
    
    func cancelReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["noise-reminder"])
        print("Cancelled all reminders.")
    }
}
