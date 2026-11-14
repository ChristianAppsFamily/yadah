import Foundation

@Observable
@MainActor
class StorageService {
    private let defaults = UserDefaults.standard

    var hasOnboarded: Bool {
        get { defaults.bool(forKey: "yadah_hasOnboarded") }
        set { defaults.set(newValue, forKey: "yadah_hasOnboarded") }
    }

    var hasCompletedSetup: Bool {
        get { defaults.bool(forKey: "yadah_hasCompletedSetup") }
        set { defaults.set(newValue, forKey: "yadah_hasCompletedSetup") }
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

    var isPremium: Bool {
        get { defaults.bool(forKey: "yadah_isPremium") }
        set { defaults.set(newValue, forKey: "yadah_isPremium") }
    }

    var selectedTheme: AppThemeOption {
        get {
            guard let raw = defaults.string(forKey: "yadah_selectedTheme"),
                  let theme = AppThemeOption(rawValue: raw) else {
                return .sky
            }
            return theme
        }
        set { defaults.set(newValue.rawValue, forKey: "yadah_selectedTheme") }
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

    /// Ensures free users only have one enabled reminder.
    func normalizeReminderLimits(isPremium: Bool) {
        var times = reminderTimes
        let enabledIndexes = times.indices.filter { times[$0].isEnabled }
        let maxAllowed = isPremium ? 5 : 1
        if enabledIndexes.count > maxAllowed {
            for index in enabledIndexes.dropFirst(maxAllowed) {
                times[index].isEnabled = false
            }
            reminderTimes = times
        } else if enabledIndexes.isEmpty, let first = times.indices.first {
            times[first].isEnabled = true
            reminderTimes = times
        }
    }
}
