import Foundation

nonisolated struct ReminderTime: Identifiable, Codable, Sendable, Hashable {
    let id: String
    var hour: Int
    var minute: Int
    let name: String
    var isEnabled: Bool

    var asDate: Date {
        var components = DateComponents()
        components.year = 2001
        components.month = 1
        components.day = 1
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    var displayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: asDate)
    }
}

extension ReminderTime {
    /// Free tier starts with one reminder enabled; Pro can enable up to five.
    static let defaults: [ReminderTime] = [
        ReminderTime(id: "morning", hour: 7, minute: 0, name: "Morning Awakening", isEnabled: true),
        ReminderTime(id: "start", hour: 9, minute: 0, name: "Start of the Day", isEnabled: false),
        ReminderTime(id: "midday", hour: 12, minute: 0, name: "Midday Pause", isEnabled: false),
        ReminderTime(id: "afternoon", hour: 15, minute: 0, name: "Afternoon Breath", isEnabled: false),
        ReminderTime(id: "evening", hour: 18, minute: 0, name: "Evening Gratitude", isEnabled: false),
        ReminderTime(id: "night", hour: 21, minute: 0, name: "Before Rest", isEnabled: false),
    ]
}
