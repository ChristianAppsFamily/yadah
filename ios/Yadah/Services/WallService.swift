import Foundation

@Observable
@MainActor
final class WallService {
    private(set) var entries: [WallEntry] = []
    private(set) var communityTotal = 0
    private(set) var isLoading = false
    private(set) var lastError: String?

    private let session: URLSession
    private let storage: StorageService

    init(storage: StorageService, session: URLSession = .shared) {
        self.storage = storage
        self.session = session
        self.entries = storage.localWallEntries
        self.communityTotal = max(storage.localWallEntries.count, storage.totalCount)
    }

    /// Display total: prefer remote community count, never below local activity.
    var displayedThanksTotal: Int {
        max(communityTotal, entries.count, storage.totalCount)
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        await fetchLatest(limit: 50)
        await fetchEntryCount()
    }

    func fetchLatest(limit: Int = 50) async {
        do {
            let remote = try await performFetch(limit: limit)
            entries = remote
            storage.localWallEntries = remote
            lastError = nil
        } catch {
            entries = storage.localWallEntries
            lastError = error.localizedDescription
        }
    }

    func fetchEntryCount() async {
        do {
            let count = try await performCount()
            communityTotal = max(count, entries.count, storage.totalCount)
        } catch {
            communityTotal = max(communityTotal, entries.count, storage.totalCount)
        }
    }

    /// Posts initials + city after Give Thanks. Optimistically updates local cache.
    func postGiveThanks() async {
        guard let profile = storage.userProfile, profile.hasJoinedWall else { return }

        let displayName = String(profile.wallDisplayName.prefix(40))
        let city = Self.cityLabel(for: profile)
        let optimistic = WallEntry(
            id: UUID().uuidString,
            initials: displayName,
            city: city,
            timestamp: Date()
        )

        var cached = storage.localWallEntries
        cached.insert(optimistic, at: 0)
        if cached.count > 50 {
            cached = Array(cached.prefix(50))
        }
        storage.localWallEntries = cached
        entries = cached
        communityTotal = max(communityTotal + 1, entries.count, storage.totalCount)

        do {
            let saved = try await performInsert(initials: displayName, city: city)
            if let index = entries.firstIndex(where: { $0.id == optimistic.id }) {
                entries[index] = saved
            } else {
                entries.insert(saved, at: 0)
            }
            storage.localWallEntries = entries
            lastError = nil
            await fetchEntryCount()
        } catch {
            lastError = error.localizedDescription
        }
    }

    static func cityLabel(for profile: UserProfile) -> String {
        let city = profile.city.trimmingCharacters(in: .whitespacesAndNewlines)
        let state = profile.state.trimmingCharacters(in: .whitespacesAndNewlines)
        let country = profile.country.trimmingCharacters(in: .whitespacesAndNewlines)

        if city.isEmpty {
            return country.isEmpty ? "Somewhere" : String(country.prefix(80))
        }

        if profile.isUnitedStates {
            if state.isEmpty {
                return String(city.prefix(80))
            }
            return String("\(city), \(state)".prefix(80))
        }

        var parts = [city]
        if !state.isEmpty { parts.append(state) }
        if !country.isEmpty { parts.append(country) }
        return String(parts.joined(separator: ", ").prefix(80))
    }

    // MARK: - Networking

    private func performFetch(limit: Int) async throws -> [WallEntry] {
        var components = URLComponents(
            url: SupabaseConfig.projectURL.appendingPathComponent("rest/v1/wall_entries"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "select", value: "id,initials,city,created_at"),
            URLQueryItem(name: "order", value: "created_at.desc"),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        guard let url = components.url else {
            throw WallServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyCommonHeaders(to: &request)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)

        let decoder = Self.makeDecoder()
        let remote = try decoder.decode([RemoteWallEntry].self, from: data)
        return remote.map(\.asWallEntry)
    }

    private func performCount() async throws -> Int {
        var components = URLComponents(
            url: SupabaseConfig.projectURL.appendingPathComponent("rest/v1/wall_entries"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "select", value: "id"),
        ]
        guard let url = components.url else {
            throw WallServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyCommonHeaders(to: &request)
        request.setValue("count=exact", forHTTPHeaderField: "Prefer")
        request.setValue("0-0", forHTTPHeaderField: "Range")

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw WallServiceError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw WallServiceError.server("HTTP \(http.statusCode)")
        }

        // Content-Range: 0-0/12345 or */12345
        if let range = http.value(forHTTPHeaderField: "Content-Range"),
           let total = range.split(separator: "/").last,
           let count = Int(total) {
            return count
        }
        return 0
    }

    private func performInsert(initials: String, city: String) async throws -> WallEntry {
        let url = SupabaseConfig.projectURL.appendingPathComponent("rest/v1/wall_entries")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyCommonHeaders(to: &request)
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        let body = InsertBody(
            initials: initials,
            city: city,
            device_id: storage.wallDeviceId
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)

        let decoder = Self.makeDecoder()
        let remote = try decoder.decode([RemoteWallEntry].self, from: data)
        guard let first = remote.first else {
            throw WallServiceError.emptyResponse
        }
        return first.asWallEntry
    }

    private func applyCommonHeaders(to request: inout URLRequest) {
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw WallServiceError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw WallServiceError.server(message)
        }
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = WallDateParsing.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date: \(raw)"
            )
        }
        return decoder
    }
}

private enum WallDateParsing {
    nonisolated static func date(from raw: String) -> Date? {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: raw) {
            return date
        }
        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]
        return standard.date(from: raw)
    }
}

// MARK: - DTOs

private struct RemoteWallEntry: Decodable {
    let id: UUID
    let initials: String
    let city: String
    let created_at: Date

    var asWallEntry: WallEntry {
        WallEntry(
            id: id.uuidString,
            initials: initials,
            city: city,
            timestamp: created_at
        )
    }
}

private struct InsertBody: Encodable {
    let initials: String
    let city: String
    let device_id: String
}

enum WallServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not reach the Thank You Wall."
        case .invalidResponse:
            return "Unexpected response from the Thank You Wall."
        case .emptyResponse:
            return "The Thank You Wall did not return an entry."
        case .server(let message):
            return message
        }
    }
}
