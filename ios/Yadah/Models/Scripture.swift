import Foundation

nonisolated enum ScriptureTestament: String, CaseIterable, Sendable, Hashable {
    case old = "Old Testament"
    case new = "New Testament"
}

nonisolated struct Scripture: Identifiable, Sendable, Hashable {
    let id: String
    let text: String
    let reference: String
    let theme: ScriptureTheme
    let testament: ScriptureTestament
}

nonisolated enum ScriptureTheme: String, CaseIterable, Sendable, Hashable {
    case morning = "Morning"
    case provision = "Provision"
    case hardship = "Hardship"
    case healing = "Healing"
    case praise = "Praise"
}

extension Scripture {
    static let library: [Scripture] = loadLibrary()

    static func randomForToday() -> Scripture {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % library.count
        return library[index]
    }

    static func byTheme(_ theme: ScriptureTheme) -> [Scripture] {
        library.filter { $0.theme == theme }
    }

    static func byTestament(_ testament: ScriptureTestament) -> [Scripture] {
        library.filter { $0.testament == testament }
    }

    private static func loadLibrary() -> [Scripture] {
        guard let url = Bundle.main.url(
            forResource: "thanksgiving_verses_180_WEB",
            withExtension: "json"
        ) else {
            assertionFailure("Missing thanksgiving_verses_180_WEB.json in app bundle")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let rows = try JSONDecoder().decode([WEBVerseDTO].self, from: data)
            return rows.map { row in
                Scripture(
                    id: "web-\(row.id)",
                    text: row.text,
                    reference: row.reference,
                    theme: .praise,
                    testament: ScriptureTestament(rawValue: row.testament) ?? .old
                )
            }
        } catch {
            assertionFailure("Failed to decode thanksgiving_verses_180_WEB.json: \(error)")
            return []
        }
    }
}

private struct WEBVerseDTO: Decodable {
    let id: Int
    let reference: String
    let text: String
    let testament: String
}
