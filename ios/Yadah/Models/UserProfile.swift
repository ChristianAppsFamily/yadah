import Foundation

nonisolated struct UserProfile: Codable, Sendable {
    var name: String
    var country: String
    var city: String
    var state: String
    /// Legacy field kept for decoding older installs; no longer collected in UI.
    var wallInitials: String?
    /// Filename under Application Support for an optional local-only profile photo.
    var localPhotoFileName: String?

    enum CodingKeys: String, CodingKey {
        case name, country, city, state, wallInitials, localPhotoFileName
    }

    init(
        name: String,
        country: String,
        city: String,
        state: String,
        wallInitials: String? = nil,
        localPhotoFileName: String? = nil
    ) {
        self.name = name
        self.country = country
        self.city = city
        self.state = state
        self.wallInitials = wallInitials
        self.localPhotoFileName = localPhotoFileName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? "United States"
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        wallInitials = try container.decodeIfPresent(String.self, forKey: .wallInitials)
        localPhotoFileName = try container.decodeIfPresent(String.self, forKey: .localPhotoFileName)
    }

    /// Label shown on the Thank You Wall: first name only.
    var wallDisplayName: String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty, trimmedName != "Friend" {
            return String(trimmedName.prefix(40))
        }
        return "?"
    }

    /// Enough identity + place to appear on the shared Thank You Wall.
    var hasJoinedWall: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasIdentity = !trimmedName.isEmpty && trimmedName != "Friend"
        let hasPlace = !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasIdentity && hasPlace
    }

    var isUnitedStates: Bool {
        let c = country.trimmingCharacters(in: .whitespacesAndNewlines)
        return c == "United States" || c == "USA" || c == "US"
    }
}
