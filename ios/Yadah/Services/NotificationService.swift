import Foundation
import UserNotifications

@Observable
@MainActor
class NotificationService {
    var isAuthorized = false

    private let center = UNUserNotificationCenter.current()
    private let notificationTitle = "Yadah 🙏🏽"
    private let notificationBody = "STOP what you are doing, take these two seconds and say THANK YOU LORD 🙏🏽 — right now. wherever you are."

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleNotifications(for reminders: [ReminderTime]) {
        center.removeAllPendingNotificationRequests()

        for reminder in reminders where reminder.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = notificationTitle
            content.body = notificationBody
            content.sound = .default
            content.categoryIdentifier = "YADAH_REMINDER"
            content.userInfo = ["showMoment": true]

            var dateComponents = DateComponents()
            dateComponents.hour = reminder.hour
            dateComponents.minute = reminder.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "yadah_\(reminder.id)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }
}
