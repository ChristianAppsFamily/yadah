import SwiftUI

nonisolated enum AppThemeOption: String, CaseIterable, Codable, Sendable, Identifiable {
    case sky
    case deepNavy
    case warmGold
    case softCream

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sky: return "Sky"
        case .deepNavy: return "Deep Navy"
        case .warmGold: return "Warm Gold"
        case .softCream: return "Soft Cream"
        }
    }

    var isProOnly: Bool {
        self != .sky
    }

    var palette: ThemePalette {
        switch self {
        case .sky:
            return ThemePalette(
                navy: Color(red: 0.09, green: 0.20, blue: 0.35),
                accent: Color(red: 0.58, green: 0.83, blue: 0.94),
                accentDark: Color(red: 0.42, green: 0.72, blue: 0.87),
                accentLight: Color(red: 0.68, green: 0.88, blue: 0.96),
                warmGray: Color(red: 0.55, green: 0.55, blue: 0.55),
                lightBorder: Color(red: 0.91, green: 0.93, blue: 0.95),
                background: .white,
                momentTop: Color(red: 0.58, green: 0.83, blue: 0.94),
                momentMid: Color(red: 0.45, green: 0.73, blue: 0.89),
                momentBottom: Color(red: 0.35, green: 0.62, blue: 0.82),
                splashBackground: Color(red: 0.05, green: 0.12, blue: 0.22)
            )
        case .deepNavy:
            return ThemePalette(
                navy: Color(red: 0.92, green: 0.94, blue: 0.97),
                accent: Color(red: 0.35, green: 0.55, blue: 0.85),
                accentDark: Color(red: 0.25, green: 0.42, blue: 0.72),
                accentLight: Color(red: 0.45, green: 0.62, blue: 0.90),
                warmGray: Color(red: 0.70, green: 0.74, blue: 0.80),
                lightBorder: Color(red: 0.20, green: 0.28, blue: 0.40),
                background: Color(red: 0.07, green: 0.12, blue: 0.22),
                momentTop: Color(red: 0.12, green: 0.22, blue: 0.40),
                momentMid: Color(red: 0.10, green: 0.18, blue: 0.34),
                momentBottom: Color(red: 0.06, green: 0.10, blue: 0.20),
                splashBackground: Color(red: 0.05, green: 0.08, blue: 0.16)
            )
        case .warmGold:
            return ThemePalette(
                navy: Color(red: 0.28, green: 0.18, blue: 0.08),
                accent: Color(red: 0.78, green: 0.58, blue: 0.22),
                accentDark: Color(red: 0.69, green: 0.49, blue: 0.18),
                accentLight: Color(red: 0.90, green: 0.75, blue: 0.40),
                warmGray: Color(red: 0.55, green: 0.48, blue: 0.40),
                lightBorder: Color(red: 0.92, green: 0.88, blue: 0.80),
                background: Color(red: 0.99, green: 0.97, blue: 0.93),
                momentTop: Color(red: 0.90, green: 0.72, blue: 0.35),
                momentMid: Color(red: 0.78, green: 0.58, blue: 0.22),
                momentBottom: Color(red: 0.62, green: 0.42, blue: 0.15),
                splashBackground: Color(red: 0.18, green: 0.12, blue: 0.05)
            )
        case .softCream:
            return ThemePalette(
                navy: Color(red: 0.30, green: 0.24, blue: 0.20),
                accent: Color(red: 0.85, green: 0.68, blue: 0.58),
                accentDark: Color(red: 0.72, green: 0.52, blue: 0.42),
                accentLight: Color(red: 0.94, green: 0.82, blue: 0.74),
                warmGray: Color(red: 0.58, green: 0.52, blue: 0.48),
                lightBorder: Color(red: 0.90, green: 0.86, blue: 0.82),
                background: Color(red: 0.98, green: 0.95, blue: 0.91),
                momentTop: Color(red: 0.94, green: 0.82, blue: 0.74),
                momentMid: Color(red: 0.85, green: 0.68, blue: 0.58),
                momentBottom: Color(red: 0.72, green: 0.52, blue: 0.42),
                splashBackground: Color(red: 0.25, green: 0.18, blue: 0.14)
            )
        }
    }
}

struct ThemePalette {
    let navy: Color
    let accent: Color
    let accentDark: Color
    let accentLight: Color
    let warmGray: Color
    let lightBorder: Color
    let background: Color
    let momentTop: Color
    let momentMid: Color
    let momentBottom: Color
    let splashBackground: Color

    var skyGradient: LinearGradient {
        LinearGradient(colors: [accentLight, accent], startPoint: .leading, endPoint: .trailing)
    }

    var momentGradient: LinearGradient {
        LinearGradient(colors: [momentTop, momentMid, momentBottom], startPoint: .top, endPoint: .bottom)
    }
}

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = AppThemeOption.sky.palette
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
