import Foundation

@Observable
@MainActor
class StorageService {
    private let defaults = UserDefaults.standard

    /// Stored so `@Observable` notifies SwiftUI (UserDefaults-only computed setters do not).
    var hasOnboarded: Bool {
        didSet { defaults.set(hasOnboarded, forKey: "yadah_hasOnboarded") }
    }

    var hasCompletedSetup: Bool {
        didSet { defaults.set(hasCompletedSetup, forKey: "yadah_hasCompletedSetup") }
    }

    /// Stored so theme changes notify SwiftUI (UserDefaults-only computed setters do not).
    var selectedTheme: AppThemeOption {
        didSet { defaults.set(selectedTheme.rawValue, forKey: "yadah_selectedTheme") }
    }

    /// Stored so joining/saving wall profile refreshes Thank You Wall and Settings.
    var userProfile: UserProfile? {
        didSet {
            let data = try? JSONEncoder().encode(userProfile)
            defaults.set(data, forKey: "yadah_userProfile")
        }
    }

    init() {
        hasOnboarded = defaults.bool(forKey: "yadah_hasOnboarded")
        hasCompletedSetup = defaults.bool(forKey: "yadah_hasCompletedSetup")
        selectedTheme = Self.loadSelectedTheme(from: UserDefaults.standard)
        userProfile = Self.loadUserProfile(from: UserDefaults.standard)
    }

    private static func loadSelectedTheme(from defaults: UserDefaults) -> AppThemeOption {
        guard let raw = defaults.string(forKey: "yadah_selectedTheme") else { return .sky }
        if raw == "softCream" { return .day }
        return AppThemeOption(rawValue: raw) ?? .sky
    }

    private static func loadUserProfile(from defaults: UserDefaults) -> UserProfile? {
        guard let data = defaults.data(forKey: "yadah_userProfile") else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    var verseMode: VerseMode {
        get {
            guard let raw = defaults.string(forKey: "yadah_verseMode") else { return .random }
            return VerseMode(rawValue: raw) ?? .random
        }
        set { defaults.set(newValue.rawValue, forKey: "yadah_verseMode") }
    }

    var selectedVerseIds: [String] {
        get { defaults.stringArray(forKey: "yadah_selectedVerses") ?? [] }
        set { defaults.set(newValue, forKey: "yadah_selectedVerses") }
    }

    /// Legacy single flag — migrated into isPro + hasRemovedAds on first read.
    private var legacyIsPremium: Bool {
        defaults.bool(forKey: "yadah_isPremium")
    }

    var isPro: Bool {
        get {
            migrateLegacyPremiumIfNeeded()
            return defaults.bool(forKey: "yadah_isPro")
        }
        set { defaults.set(newValue, forKey: "yadah_isPro") }
    }

    var hasRemovedAds: Bool {
        get {
            migrateLegacyPremiumIfNeeded()
            return defaults.bool(forKey: "yadah_hasRemovedAds")
        }
        set { defaults.set(newValue, forKey: "yadah_hasRemovedAds") }
    }

    var adsHidden: Bool {
        hasRemovedAds || isPro
    }

    var reminderTimes: [ReminderTime] {
        get {
            if let data = defaults.data(forKey: "yadah_reminderTimes"),
               let saved = try? JSONDecoder().decode([ReminderTime].self, from: data) {
                return saved
            }
            return ReminderTime.defaults
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: "yadah_reminderTimes")
        }
    }

    var localWallEntries: [WallEntry] {
        get {
            guard let data = defaults.data(forKey: "yadah_localWallEntries"),
                  let saved = try? JSONDecoder().decode([WallEntry].self, from: data) else {
                return []
            }
            return saved
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: "yadah_localWallEntries")
        }
    }

    /// Stable anonymous id for light wall rate limiting (not a login).
    var wallDeviceId: String {
        let key = "yadah_wallDeviceId"
        if let existing = defaults.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let id = UUID().uuidString
        defaults.set(id, forKey: key)
        return id
    }

    var todayCount: Int {
        get {
            checkDateReset()
            return defaults.integer(forKey: "yadah_todayCount")
        }
        set { defaults.set(newValue, forKey: "yadah_todayCount") }
    }

    var totalCount: Int {
        get { defaults.integer(forKey: "yadah_totalCount") }
        set { defaults.set(newValue, forKey: "yadah_totalCount") }
    }

    private func migrateLegacyPremiumIfNeeded() {
        let migratedKey = "yadah_premiumMigrated"
        guard !defaults.bool(forKey: migratedKey) else { return }
        if legacyIsPremium {
            defaults.set(true, forKey: "yadah_isPro")
            defaults.set(true, forKey: "yadah_hasRemovedAds")
        }
        defaults.set(true, forKey: migratedKey)
    }

    private func checkDateReset() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        let lastDate = defaults.string(forKey: "yadah_lastDate") ?? ""

        if lastDate != todayKey {
            defaults.set(todayKey, forKey: "yadah_lastDate")
            defaults.set(0, forKey: "yadah_todayCount")
        }
    }

    func recordAmen() {
        checkDateReset()
        todayCount += 1
        totalCount += 1
    }

    /// Caps enabled reminders for free. Pro has no enable cap. Does not force-enable when the user turns all off.
    func normalizeReminderLimits(isPro: Bool) {
        guard !isPro else { return }
        var times = reminderTimes
        let enabledIndexes = times.indices.filter { times[$0].isEnabled }
        let maxAllowed = 1
        guard enabledIndexes.count > maxAllowed else { return }
        for index in enabledIndexes.dropFirst(maxAllowed) {
            times[index].isEnabled = false
        }
        reminderTimes = times
    }
}
