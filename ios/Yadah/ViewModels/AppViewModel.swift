import SwiftUI
import UIKit

@Observable
@MainActor
class AppViewModel {
    let storage: StorageService
    let wallService: WallService
    let notificationService = NotificationService()
    let adService = AdService()
    let storeKit = StoreKitService()

    var showMoment = false
    var showAmen = false
    var selectedTab: TabSelection = .home
    var showPaywall = false
    var adsPrepared = false
    /// When true, Settings should emphasize the profile section (from Join the wall).
    var focusProfileInSettings = false
    var showProfileSheet = false

    init() {
        let storage = StorageService()
        self.storage = storage
        self.wallService = WallService(storage: storage)
    }

    var currentScripture: Scripture {
        if storage.verseMode == .custom, !storage.selectedVerseIds.isEmpty {
            let selected = Scripture.library.filter { storage.selectedVerseIds.contains($0.id) }
            if !selected.isEmpty {
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
                return selected[dayOfYear % selected.count]
            }
        }
        return Scripture.randomForToday()
    }

    var maxReminders: Int {
        storage.isPro ? Int.max : 1
    }

    var hasJoinedWall: Bool {
        storage.userProfile?.hasJoinedWall == true
    }

    var themePalette: ThemePalette {
        let selected = storage.selectedTheme
        if selected.isProOnly && !storage.isPro {
            return AppThemeOption.sky.palette
        }
        return selected.palette
    }

    var preferredColorScheme: ColorScheme? {
        let selected = storage.selectedTheme
        if selected.isProOnly && !storage.isPro {
            return .light
        }
        return selected.prefersLightColorScheme ? .light : .dark
    }

    func setup() async {
        storeKit.start()
        applyEntitlements(await storeKit.refreshEntitlements())
        storage.normalizeReminderLimits(isPro: storage.isPro)
        await notificationService.checkAuthorizationStatus()
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func requestATTAfterSplash() async {
        await adService.requestATTIfNeeded()
    }

    func prepareAdsAfterOnboarding() async {
        guard !adsPrepared else { return }
        await adService.prepareAdsIfNeeded(adsHidden: storage.adsHidden)
        adsPrepared = true
    }

    func requestNotificationsAfterOnboarding() async {
        let granted = await requestNotificationPermission()
        if !granted {
            openSystemSettings()
        }
    }

    func requestNotificationPermission() async -> Bool {
        let granted = await notificationService.requestPermission()
        if granted {
            notificationService.scheduleNotifications(for: storage.reminderTimes)
        }
        return granted
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func completeOnboarding() {
        storage.hasOnboarded = true
    }

    func completeSetup() {
        storage.hasCompletedSetup = true
    }

    /// Enters the app immediately; notifications/ads continue in the background.
    func finishOnboarding(openSettings: Bool, requestNotifications: Bool) {
        selectedTab = openSettings ? .settings : .home
        completeSetup()
        completeOnboarding()
        Task {
            if requestNotifications {
                await requestNotificationsAfterOnboarding()
            }
            await prepareAdsAfterOnboarding()
        }
    }

    func openWallJoinInSettings() {
        focusProfileInSettings = true
        showProfileSheet = true
        selectedTab = .settings
    }

    func openProfileSheet() {
        showProfileSheet = true
    }

    func saveProfile(
        name: String,
        country: String,
        city: String,
        state: String,
        localPhotoFileName: String? = nil
    ) {
        storage.userProfile = UserProfile(
            name: name,
            country: country,
            city: city,
            state: state,
            localPhotoFileName: localPhotoFileName
        )
        focusProfileInSettings = false
        showProfileSheet = false
    }

    func addCustomReminder() {
        guard storage.isPro else {
            showPaywall = true
            return
        }

        let calendar = Calendar.current
        let nextHour = calendar.component(.hour, from: Date().addingTimeInterval(3600)) % 24
        let customCount = storage.reminderTimes.filter { $0.id.hasPrefix("custom-") }.count + 1
        let reminder = ReminderTime(
            id: "custom-\(UUID().uuidString)",
            hour: nextHour,
            minute: 0,
            name: "Custom Reminder \(customCount)",
            isEnabled: true
        )
        var times = storage.reminderTimes
        times.append(reminder)
        storage.reminderTimes = times
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func setReminderEnabled(id: String, isEnabled: Bool) {
        guard let index = storage.reminderTimes.firstIndex(where: { $0.id == id }) else { return }
        let current = storage.reminderTimes[index]
        if current.isEnabled == isEnabled { return }

        if isEnabled {
            Task {
                await enableReminderIfAuthorized(id: id)
            }
            return
        }

        var times = storage.reminderTimes
        times[index].isEnabled = false
        storage.reminderTimes = times
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    private func enableReminderIfAuthorized(id: String) async {
        await notificationService.checkAuthorizationStatus()
        if !notificationService.isAuthorized {
            let granted = await requestNotificationPermission()
            if !granted {
                openSystemSettings()
                return
            }
        }

        let enabledCount = storage.reminderTimes.filter(\.isEnabled).count
        if enabledCount >= maxReminders {
            showPaywall = true
            return
        }

        guard let index = storage.reminderTimes.firstIndex(where: { $0.id == id }) else { return }
        var times = storage.reminderTimes
        times[index].isEnabled = true
        storage.reminderTimes = times
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func updateReminderTime(id: String, date: Date) {
        guard let index = storage.reminderTimes.firstIndex(where: { $0.id == id }) else { return }

        if !storage.isPro {
            let reminder = storage.reminderTimes[index]
            let enabledCount = storage.reminderTimes.filter(\.isEnabled).count
            let canEditFree = reminder.isEnabled || enabledCount == 0
            if !canEditFree {
                showPaywall = true
                return
            }
        }

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let newHour = components.hour ?? storage.reminderTimes[index].hour
        let newMinute = components.minute ?? storage.reminderTimes[index].minute
        if storage.reminderTimes[index].hour == newHour,
           storage.reminderTimes[index].minute == newMinute {
            return
        }

        var times = storage.reminderTimes
        times[index].hour = newHour
        times[index].minute = newMinute
        storage.reminderTimes = times
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func setVerseMode(_ mode: VerseMode) {
        if mode == .custom && !storage.isPro {
            showPaywall = true
            return
        }
        if storage.verseMode == mode { return }
        storage.verseMode = mode
    }

    func setTheme(_ theme: AppThemeOption) {
        if theme.isProOnly && !storage.isPro {
            showPaywall = true
            return
        }
        if storage.selectedTheme == theme { return }
        storage.selectedTheme = theme
    }

    func toggleVerseSelection(_ id: String) {
        var selected = storage.selectedVerseIds
        if selected.contains(id) {
            selected.removeAll { $0 == id }
        } else {
            selected.append(id)
        }
        storage.selectedVerseIds = selected
    }

    func triggerMoment() {
        showMoment = true
    }

    func completeMoment() {
        showMoment = false
        showAmen = true
        storage.recordAmen()
        if hasJoinedWall {
            Task {
                await wallService.postGiveThanks()
            }
        }
    }

    func completeAmen() {
        showAmen = false
    }

    func purchaseRemoveAds() async {
        let success = await storeKit.purchaseRemoveAds()
        if success {
            storage.hasRemovedAds = true
            adsPrepared = true
            adService.disableAds()
            showPaywall = false
        }
    }

    func purchaseProMonthly() async {
        let success = await storeKit.purchaseMonthly()
        if success {
            applyProPurchase()
        }
    }

    func purchaseProYearly() async {
        let success = await storeKit.purchaseYearly()
        if success {
            applyProPurchase()
        }
    }

    func restorePurchases() async {
        let state = await storeKit.restore()
        applyEntitlements(state)
        if state.hasRemovedAds || state.isPro {
            showPaywall = false
        }
    }

    func applyEntitlements(_ state: EntitlementState) {
        if state.isPro {
            storage.isPro = true
            storage.hasRemovedAds = true
            adService.disableAds()
        } else if state.hasRemovedAds {
            storage.hasRemovedAds = true
            adService.disableAds()
        }
        storage.normalizeReminderLimits(isPro: storage.isPro)
    }

    private func applyProPurchase() {
        storage.isPro = true
        storage.hasRemovedAds = true
        adsPrepared = true
        adService.disableAds()
        showPaywall = false
        storage.normalizeReminderLimits(isPro: true)
    }
}

nonisolated enum TabSelection: Hashable, Sendable {
    case home
    case wall
    case settings
}
