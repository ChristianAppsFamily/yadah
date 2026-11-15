import SwiftUI
import UserNotifications

@main
struct YadahApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        // Avoid a colored window flash before the CAE launch screen / first SwiftUI frame.
        if let windowScene = application.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.backgroundColor = .black }
        }
        return true
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        if userInfo["showMoment"] as? Bool == true {
            await MainActor.run {
                NotificationCenter.default.post(name: .showMoment, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let showMoment = Notification.Name("showMoment")
}
