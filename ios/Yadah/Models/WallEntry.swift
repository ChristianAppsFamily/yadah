import Foundation

nonisolated struct WallEntry: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let initials: String
    let city: String
    let timestamp: Date
}
