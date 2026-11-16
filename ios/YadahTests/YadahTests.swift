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
        #expect(AppThemeOption.oliveGrove.isProOnly == true)
        #expect(AppThemeOption.slateDawn.isProOnly == true)
        #expect(AppThemeOption.oliveGrove.prefersLightColorScheme == true)
        #expect(AppThemeOption.slateDawn.prefersLightColorScheme == true)
    }

    @Test func scriptureLibraryHasFifteenVerses() {
        #expect(Scripture.library.count == 15)
    }

    @Test func momentPromptLibraryHasThirtyOneEntries() {
        #expect(MomentPrompt.library.count == 31)
        let day = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let sameDay = MomentPrompt.forToday(date: day)
        #expect(sameDay.id == MomentPrompt.forToday(date: day).id)
        #expect(sameDay.id == 1)
    }
}
