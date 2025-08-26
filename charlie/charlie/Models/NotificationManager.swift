//
//  NotificationManager.swift
//  charlie
//
//  Manages local notifications for Charlie reminders
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        await MainActor.run {
            self.isAuthorized = granted
            if granted {
                self.scheduleNotifications()
            }
        }
    }
    
    func scheduleNotifications() {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Morning reminder - 9 AM
        scheduleDailyNotification(
            identifier: "morning_walk",
            title: "Good morning! 🌅",
            body: "Charlie needs his walk today! Let's get those 10,000 steps together.",
            hour: 9,
            minute: 0
        )
        
        // Evening check-in - 7 PM
        scheduleDailyNotification(
            identifier: "evening_check",
            title: "Evening check-in 🌙",
            body: "Don't forget to walk Charlie before bed! He's waiting for you.",
            hour: 19,
            minute: 0
        )
    }
    
    private func scheduleDailyNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func sendCelebrationNotification(steps: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Reached!"
        content.body = "You walked Charlie with \(steps) steps today! Here's your reward photo."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "goal_reached", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendStreakNotification(days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Alert!"
        content.body = "Amazing! You've walked Charlie for \(days) days in a row!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_\(days)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}