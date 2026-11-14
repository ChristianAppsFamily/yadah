import Foundation
import StoreKit
import UIKit

@MainActor
enum RateAppService {
    private static let visitCountKey = "yadah_visitCount"
    private static let hasRatedKey = "yadah_hasRated"

    static func recordVisitAndMaybePrompt() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: hasRatedKey) { return }

        let visits = defaults.integer(forKey: visitCountKey) + 1
        defaults.set(visits, forKey: visitCountKey)

        guard visits >= 3, visits % 3 == 0 else { return }
        presentPrompt()
    }

    static func openWriteReview() {
        markRated()
        guard let url = URL(string: "https://apps.apple.com/app/id\(AppConstants.appStoreID)?action=write-review") else {
            return
        }
        UIApplication.shared.open(url)
    }

    private static func presentPrompt() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }

        let alert = UIAlertController(
            title: "Enjoying Yadah?",
            message: "Would you mind rating Yadah on the App Store?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
        alert.addAction(UIAlertAction(title: "Rate App", style: .default) { _ in
            markRated()
            AppStore.requestReview(in: scene)
        })

        scene.keyWindow?.rootViewController?.present(alert, animated: true)
    }

    private static func markRated() {
        UserDefaults.standard.set(true, forKey: hasRatedKey)
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first(where: \.isKeyWindow) ?? windows.first
    }
}
