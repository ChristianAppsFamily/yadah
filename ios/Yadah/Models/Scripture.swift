import Foundation

nonisolated struct Scripture: Identifiable, Sendable, Hashable {
    let id: String
    let text: String
    let reference: String
    let theme: ScriptureTheme
}

nonisolated enum ScriptureTheme: String, CaseIterable, Sendable, Hashable {
    case morning = "Morning"
    case provision = "Provision"
    case hardship = "Hardship"
    case healing = "Healing"
    case praise = "Praise"
}

extension Scripture {
    static let library: [Scripture] = [
        Scripture(id: "1thess518", text: "In every thing give thanks: for this is the will of God in Christ Jesus concerning you.", reference: "1 Thessalonians 5:18", theme: .praise),
        Scripture(id: "psalm1004", text: "Enter into His gates with thanksgiving, and into His courts with praise.", reference: "Psalm 100:4", theme: .praise),
        Scripture(id: "phil46", text: "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God.", reference: "Philippians 4:6", theme: .hardship),
        Scripture(id: "psalm6930", text: "I will praise the name of God with a song, and will magnify Him with thanksgiving.", reference: "Psalm 69:30", theme: .praise),
        Scripture(id: "james117", text: "Every good gift and every perfect gift is from above, and cometh down from the Father of lights.", reference: "James 1:17", theme: .provision),
        Scripture(id: "psalm301", text: "I will extol thee, O Lord; for thou hast lifted me up, and hast not made my foes to rejoice over me.", reference: "Psalm 30:1", theme: .morning),
        Scripture(id: "psalm1411", text: "O Lord, I cry unto thee: make haste unto me; give ear unto my voice, when I cry unto thee.", reference: "Psalm 141:1", theme: .morning),
        Scripture(id: "psalm591", text: "Deliver me from mine enemies, O my God: defend me from them that rise up against me.", reference: "Psalm 59:1", theme: .hardship),
        Scripture(id: "psalm2510", text: "All the paths of the Lord are mercy and truth unto such as keep his covenant and his testimonies.", reference: "Psalm 25:10", theme: .provision),
        Scripture(id: "psalm1033", text: "Who forgiveth all thine iniquities; who healeth all thy diseases.", reference: "Psalm 103:3", theme: .healing),
        Scripture(id: "jer1714", text: "Heal me, O Lord, and I shall be healed; save me, and I shall be saved: for thou art my praise.", reference: "Jeremiah 17:14", theme: .healing),
        Scripture(id: "isaiah4031", text: "But they that wait upon the Lord shall renew their strength; they shall mount up with wings as eagles.", reference: "Isaiah 40:31", theme: .morning),
        Scripture(id: "psalm241", text: "The earth is the Lord's, and the fulness thereof; the world, and they that dwell therein.", reference: "Psalm 24:1", theme: .provision),
        Scripture(id: "psalm14518", text: "The Lord is nigh unto all them that call upon him, to all that call upon him in truth.", reference: "Psalm 145:18", theme: .healing),
        Scripture(id: "psalm1501", text: "Praise ye the Lord. Praise God in his sanctuary: praise him in the firmament of his power.", reference: "Psalm 150:1", theme: .praise),
    ]

    static func randomForToday() -> Scripture {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % library.count
        return library[index]
    }

    static func byTheme(_ theme: ScriptureTheme) -> [Scripture] {
        library.filter { $0.theme == theme }
    }
}
