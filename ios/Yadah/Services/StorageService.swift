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

    init() {
        hasOnboarded = defaults.bool(forKey: "yadah_hasOnboarded")
        hasCompletedSetup = defaults.bool(forKey: "yadah_hasCompletedSetup")
        selectedTheme = Self.loadSelectedTheme(from: UserDefaults.standard)
    }

    private static func loadSelectedTheme(from defaults: UserDefaults) -> AppThemeOption {
        guard let raw = defaults.string(forKey: "yadah_selectedTheme") else { return .sky }
        if raw == "softCream" { return .day }
        return AppThemeOption(rawValue: raw) ?? .sky
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

    var userProfile: UserProfile? {
        get {
            guard let data = defaults.data(forKey: "yadah_userProfile") else { return nil }
            return try? JSONDecoder().decode(UserProfile.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: "yadah_userProfile")
        }
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
        appendLocalWallEntry()
    }

    private func appendLocalWallEntry() {
        guard let profile = userProfile else { return }
        let cityLabel: String
        if profile.city.isEmpty {
            cityLabel = "Somewhere"
        } else if profile.state.isEmpty {
            cityLabel = profile.city
        } else {
            cityLabel = "\(profile.city), \(profile.state)"
        }
        var entries = localWallEntries
        entries.insert(
            WallEntry(
                id: UUID().uuidString,
                initials: profile.initials,
                city: cityLabel,
                timestamp: Date()
            ),
            at: 0
        )
        if entries.count > 50 {
            entries = Array(entries.prefix(50))
        }
        localWallEntries = entries
    }

    /// Caps enabled reminders for free vs Pro. Does not force-enable when the user turns all off.
    func normalizeReminderLimits(isPro: Bool) {
        var times = reminderTimes
        let enabledIndexes = times.indices.filter { times[$0].isEnabled }
        let maxAllowed = isPro ? 5 : 1
        guard enabledIndexes.count > maxAllowed else { return }
        for index in enabledIndexes.dropFirst(maxAllowed) {
            times[index].isEnabled = false
        }
        reminderTimes = times
    }
}
