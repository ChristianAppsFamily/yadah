import Foundation

/// AdMob unit IDs for Yadah.
///
/// Test builds must keep `useTestAds = true` (Google test unit IDs).
/// App Store / production archives must set `useTestAds = false` only after
/// real Yadah production IDs are filled in below — never ship a final build
/// with test IDs still enabled.
enum AdsConfig {
    /// Keep `true` for local Xcode and TestFlight test builds.
    /// Set to `false` only for verified production App Store archives.
    static let useTestAds = true

    private static let testAppID = "ca-app-pub-3940256099942544~1458002511"
    private static let testBannerUnitID = "ca-app-pub-3940256099942544/2934735716"

    /// Replace with Yadah's AdMob iOS app ID before setting `useTestAds = false`.
    private static let productionAppID = "ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx"
    /// Replace with Yadah's AdMob iOS banner unit ID before setting `useTestAds = false`.
    private static let productionBannerUnitID = "ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx"

    static var appID: String {
        useTestAds ? testAppID : productionAppID
    }

    static var bannerUnitID: String {
        useTestAds ? testBannerUnitID : productionBannerUnitID
    }
}
