import Testing
@testable import Yadah

struct YadahTests {
    @Test func adsConfigUsesTestUnits() {
        #expect(AdsConfig.useTestAds == true)
        #expect(AdsConfig.bannerUnitID.contains("3940256099942544"))
    }
}
