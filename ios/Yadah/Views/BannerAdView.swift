import GoogleMobileAds
import SwiftUI
import UIKit

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let width: CGFloat

    func makeUIView(context: Context) -> BannerView {
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: max(width, 320))
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.keyRootViewController()
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: max(width, 320))
        if abs(uiView.adSize.size.width - adSize.size.width) > 0.5 {
            uiView.adSize = adSize
            uiView.load(Request())
        }
    }

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
    let adsHidden: Bool

    private var bannerWidth: CGFloat {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        return scene?.screen.bounds.width ?? UIScreen.main.bounds.width
    }

    private var bannerHeight: CGFloat {
        currentOrientationAnchoredAdaptiveBanner(width: bannerWidth).size.height
    }

    var body: some View {
        Group {
            if shouldShow {
                BannerAdView(adUnitID: AdsConfig.bannerUnitID, width: bannerWidth)
                    .frame(width: bannerWidth, height: bannerHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
            }
        }
        .frame(height: shouldShow ? bannerHeight : 0)
        .accessibilityHidden(!shouldShow)
    }

    private var shouldShow: Bool {
        !adsHidden && adService.isAdsAllowed && adService.hasCompletedATT && adService.isSDKReady
    }
}
