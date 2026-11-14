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
        storage.isPremium ? 5 : 1
    }

    var themePalette: ThemePalette {
        let selected = storage.selectedTheme
        if selected.isProOnly && !storage.isPremium {
            return AppThemeOption.sky.palette
        }
        return selected.palette
    }

    func setup() async {
        storeKit.start()
        if await storeKit.refreshEntitlements() {
            storage.isPremium = true
        }
        storage.normalizeReminderLimits(isPremium: storage.isPremium)
        await notificationService.checkAuthorizationStatus()
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func prepareAdsAfterOnboarding() async {
        guard !adsPrepared else { return }
        await adService.prepareAdsIfNeeded(isPremium: storage.isPremium)
        adsPrepared = true
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

    func saveProfile(name: String, city: String, state: String) {
        storage.userProfile = UserProfile(name: name, city: city, state: state)
    }

    func toggleReminder(id: String) {
        guard let index = storage.reminderTimes.firstIndex(where: { $0.id == id }) else { return }
        let currentEnabled = storage.reminderTimes.filter(\.isEnabled).count
        let isCurrentlyEnabled = storage.reminderTimes[index].isEnabled

        if !isCurrentlyEnabled && currentEnabled >= maxReminders {
            showPaywall = true
            return
        }

        var times = storage.reminderTimes
        times[index].isEnabled.toggle()
        storage.reminderTimes = times
        notificationService.scheduleNotifications(for: storage.reminderTimes)
    }

    func setVerseMode(_ mode: VerseMode) {
        if mode == .custom && !storage.isPremium {
            showPaywall = true
            return
        }
        storage.verseMode = mode
    }

    func setTheme(_ theme: AppThemeOption) {
        if theme.isProOnly && !storage.isPremium {
            showPaywall = true
            return
        }
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
        let success = await storeKit.purchase()
        if success {
            storage.isPremium = true
            adsPrepared = true
            adService.disableAds()
            showPaywall = false
        }
    }

    func restorePurchases() async {
        let restored = await storeKit.restore()
        let entitled = await storeKit.refreshEntitlements()
        if restored || entitled {
            storage.isPremium = true
            adService.disableAds()
            showPaywall = false
        }
    }
}

nonisolated enum TabSelection: Hashable, Sendable {
    case home
    case wall
    case settings
}
