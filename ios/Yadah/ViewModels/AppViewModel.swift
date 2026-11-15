import SwiftUI

@Observable
@MainActor
class AppViewModel {
    let storage = StorageService()
    let notificationService = NotificationService()
    let adService = AdService()
    let storeKit = StoreKitService()

    var showMoment = false
    var showAmen = false
    var selectedTab: TabSelection = .home
    var showPaywall = false
    var adsPrepared = false

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
        storage.isPro ? 5 : 1
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
        _ = await requestNotificationPermission()
    }

    func requestNotificationPermission() async -> Bool {
        let granted = await notificationService.requestPermission()
        if granted {
            notificationService.scheduleNotifications(for: storage.reminderTimes)
        }
        return granted
    }

    func completeOnboarding() {
        storage.hasOnboarded = true
    }

    func completeSetup() {
        storage.hasCompletedSetup = true
    }

    /// Requests notification permission first, then leaves onboarding to Home or Settings.
    func finishOnboarding(openSettings: Bool) async {
        selectedTab = openSettings ? .settings : .home
        await requestNotificationsAfterOnboarding()
        await prepareAdsAfterOnboarding()
        completeSetup()
        completeOnboarding()
    }

    func saveProfile(name: String, city: String, state: String, wallInitials: String? = nil) {
        storage.userProfile = UserProfile(
            name: name,
            city: city,
            state: state,
            wallInitials: wallInitials
        )
    }

    func setReminderEnabled(id: String, isEnabled: Bool) {
        guard let index = storage.reminderTimes.firstIndex(where: { $0.id == id }) else { return }
        let current = storage.reminderTimes[index]
        if current.isEnabled == isEnabled { return }

        if isEnabled {
            let enabledCount = storage.reminderTimes.filter(\.isEnabled).count
            if enabledCount >= maxReminders {
                showPaywall = true
                return
            }
        }

        var times = storage.reminderTimes
        times[index].isEnabled = isEnabled
        storage.reminderTimes = times
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func updateReminderTime(id: String, date: Date) {
        guard let index = storage.reminderTimes.firstIndex(where: { $0.id == id }) else { return }

        if !storage.isPro {
            let reminder = storage.reminderTimes[index]
            let enabledCount = storage.reminderTimes.filter(\.isEnabled).count
            // Free users may edit the single enabled reminder (or the only one if none enabled yet).
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
