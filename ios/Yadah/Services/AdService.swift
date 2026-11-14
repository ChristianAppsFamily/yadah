import AppTrackingTransparency
import Foundation
import GoogleMobileAds

@Observable
@MainActor
final class AdService {
    private(set) var isSDKReady = false
    private(set) var hasCompletedATT = false
    private(set) var canShowPersonalizedAds = false
    private(set) var isAdsAllowed = false

    private var didStartSDK = false

    /// Request ATT (if needed), then start Mobile Ads. Ads must not load before this returns.
    func prepareAdsIfNeeded(isPremium: Bool) async {
        if isPremium {
            disableAds()
            hasCompletedATT = true
            return
        }

        isAdsAllowed = true
        await requestTrackingIfNeeded()
        hasCompletedATT = true
        await startSDKIfNeeded()
    }

    func disableAds() {
        isAdsAllowed = false
    }

    private func requestTrackingIfNeeded() async {
        let status = ATTrackingManager.trackingAuthorizationStatus
        if status == .notDetermined {
            let newStatus = await ATTrackingManager.requestTrackingAuthorization()
            canShowPersonalizedAds = newStatus == .authorized
        } else {
            canShowPersonalizedAds = status == .authorized
        }
    }

    private func startSDKIfNeeded() async {
        guard !didStartSDK else { return }
        didStartSDK = true

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            MobileAds.shared.start { _ in
                Task { @MainActor in
                    self.isSDKReady = true
                    continuation.resume()
                }
            }
        }
    }
}
