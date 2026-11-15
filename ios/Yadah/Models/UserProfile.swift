import Foundation

nonisolated struct UserProfile: Codable, Sendable {
    var name: String
    var city: String
    var state: String
    /// When the user entered initials explicitly, use these on the wall.
    var wallInitials: String?

    var initials: String {
        if let wallInitials, !wallInitials.isEmpty {
            return wallInitials.uppercased()
        }
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        if let first = parts.first {
            return String(first.prefix(1)).uppercased()
        }
        return "?"
    }
}
