import Testing
@testable import Yadah

struct YadahTests {
    @Test func adsConfigUsesTestUnits() {
        #expect(AdsConfig.useTestAds == true)
        #expect(AdsConfig.bannerUnitID.contains("3940256099942544"))
    }

    @Test func freeThemesAreSkyAndDay() {
        #expect(AppThemeOption.sky.isProOnly == false)
        #expect(AppThemeOption.day.isProOnly == false)
        #expect(AppThemeOption.deepNavy.isProOnly == true)
        #expect(AppThemeOption.warmGold.isProOnly == true)
    }

    @Test func scriptureLibraryHasFifteenVerses() {
        #expect(Scripture.library.count == 15)
    }
}
