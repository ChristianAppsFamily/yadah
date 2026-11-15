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

    /// Request ATT only. Always returns (with timeout) so onboarding cannot hang.
    func requestATTIfNeeded() async {
        await withTimeout(seconds: 4) {
            await self.requestTrackingIfNeeded()
        }
        hasCompletedATT = true
    }

    /// Start ads after ATT has already been answered. Ads must not load before ATT completes.
    func prepareAdsIfNeeded(adsHidden: Bool) async {
        if adsHidden {
            disableAds()
            if !hasCompletedATT {
                hasCompletedATT = true
            }
            return
        }

        isAdsAllowed = true
        if !hasCompletedATT {
            await requestATTIfNeeded()
        }
        await startSDKIfNeeded()
    }

    func disableAds() {
        isAdsAllowed = false
    }

    private func requestTrackingIfNeeded() async {
        try? await Task.sleep(for: .milliseconds(350))

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

    private func withTimeout(seconds: Double, operation: @escaping () async -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await operation()
            }
            group.addTask {
                try? await Task.sleep(for: .seconds(seconds))
            }
            await group.next()
            group.cancelAll()
        }
    }
}
