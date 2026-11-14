import GoogleMobileAds
import SwiftUI
import UIKit

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.keyRootViewController()
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private static func keyRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {}

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {}
    }
}

struct AdBannerContainer: View {
    let adService: AdService
    let isPremium: Bool

    var body: some View {
        Group {
            if !isPremium, adService.isAdsAllowed, adService.hasCompletedATT, adService.isSDKReady {
                BannerAdView(adUnitID: AdsConfig.bannerUnitID)
                    .frame(width: 320, height: 50)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
