import SwiftUI

nonisolated enum AppThemeOption: String, CaseIterable, Codable, Sendable, Identifiable {
    case sky
    case day
    case deepNavy
    case warmGold
    case oliveGrove
    case slateDawn

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sky: return "Sky"
        case .day: return "Day"
        case .deepNavy: return "Deep Navy"
        case .warmGold: return "Warm Gold"
        case .oliveGrove: return "Olive Grove"
        case .slateDawn: return "Slate Dawn"
        }
    }

    var isProOnly: Bool {
        switch self {
        case .sky, .day: return false
        case .deepNavy, .warmGold, .oliveGrove, .slateDawn: return true
        }
    }

    var prefersLightColorScheme: Bool {
        switch self {
        case .sky, .day, .warmGold, .oliveGrove, .slateDawn: return true
        case .deepNavy: return false
        }
    }

    var palette: ThemePalette {
        switch self {
        case .sky:
            return ThemePalette(
                navy: Color(red: 0.09, green: 0.20, blue: 0.35),
                accent: Color(red: 0.42, green: 0.68, blue: 0.86),
                accentDark: Color(red: 0.28, green: 0.52, blue: 0.72),
                accentLight: Color(red: 0.62, green: 0.82, blue: 0.94),
                warmGray: Color(red: 0.42, green: 0.48, blue: 0.55),
                lightBorder: Color(red: 0.88, green: 0.91, blue: 0.94),
                background: Color(red: 0.98, green: 0.99, blue: 1.0),
                momentTop: Color(red: 0.58, green: 0.83, blue: 0.94),
                momentMid: Color(red: 0.45, green: 0.73, blue: 0.89),
                momentBottom: Color(red: 0.35, green: 0.62, blue: 0.82),
                splashBackground: Color(red: 0.05, green: 0.12, blue: 0.22),
                tabSelected: Color(red: 0.09, green: 0.20, blue: 0.35),
                tabUnselected: Color(red: 0.45, green: 0.55, blue: 0.65)
            )
        case .day:
            return ThemePalette(
                navy: Color(red: 0.30, green: 0.24, blue: 0.20),
                accent: Color(red: 0.85, green: 0.68, blue: 0.58),
                accentDark: Color(red: 0.72, green: 0.52, blue: 0.42),
                accentLight: Color(red: 0.94, green: 0.82, blue: 0.74),
                warmGray: Color(red: 0.52, green: 0.46, blue: 0.42),
                lightBorder: Color(red: 0.90, green: 0.86, blue: 0.82),
                background: Color(red: 0.99, green: 0.97, blue: 0.94),
                momentTop: Color(red: 0.94, green: 0.82, blue: 0.74),
                momentMid: Color(red: 0.85, green: 0.68, blue: 0.58),
                momentBottom: Color(red: 0.72, green: 0.52, blue: 0.42),
                splashBackground: Color(red: 0.25, green: 0.18, blue: 0.14),
                tabSelected: Color(red: 0.30, green: 0.24, blue: 0.20),
                tabUnselected: Color(red: 0.62, green: 0.55, blue: 0.48)
            )
        case .deepNavy:
            return ThemePalette(
                navy: Color(red: 0.92, green: 0.94, blue: 0.97),
                accent: Color(red: 0.45, green: 0.68, blue: 0.92),
                accentDark: Color(red: 0.32, green: 0.52, blue: 0.78),
                accentLight: Color(red: 0.55, green: 0.72, blue: 0.92),
                warmGray: Color(red: 0.70, green: 0.74, blue: 0.80),
                lightBorder: Color(red: 0.20, green: 0.28, blue: 0.40),
                background: Color(red: 0.07, green: 0.12, blue: 0.22),
                momentTop: Color(red: 0.12, green: 0.22, blue: 0.40),
                momentMid: Color(red: 0.10, green: 0.18, blue: 0.34),
                momentBottom: Color(red: 0.06, green: 0.10, blue: 0.20),
                splashBackground: Color(red: 0.05, green: 0.08, blue: 0.16),
                tabSelected: Color(red: 0.92, green: 0.94, blue: 0.97),
                tabUnselected: Color(red: 0.55, green: 0.62, blue: 0.72)
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
                splashBackground: Color(red: 0.18, green: 0.12, blue: 0.05),
                tabSelected: Color(red: 0.28, green: 0.18, blue: 0.08),
                tabUnselected: Color(red: 0.62, green: 0.52, blue: 0.38)
            )
        case .oliveGrove:
            return ThemePalette(
                navy: Color(red: 0.22, green: 0.28, blue: 0.18),
                accent: Color(red: 0.55, green: 0.62, blue: 0.38),
                accentDark: Color(red: 0.42, green: 0.48, blue: 0.28),
                accentLight: Color(red: 0.78, green: 0.82, blue: 0.62),
                warmGray: Color(red: 0.48, green: 0.50, blue: 0.42),
                lightBorder: Color(red: 0.86, green: 0.88, blue: 0.80),
                background: Color(red: 0.97, green: 0.98, blue: 0.94),
                momentTop: Color(red: 0.78, green: 0.82, blue: 0.58),
                momentMid: Color(red: 0.55, green: 0.62, blue: 0.38),
                momentBottom: Color(red: 0.40, green: 0.46, blue: 0.28),
                splashBackground: Color(red: 0.14, green: 0.18, blue: 0.10),
                tabSelected: Color(red: 0.22, green: 0.28, blue: 0.18),
                tabUnselected: Color(red: 0.55, green: 0.58, blue: 0.48)
            )
        case .slateDawn:
            return ThemePalette(
                navy: Color(red: 0.18, green: 0.24, blue: 0.32),
                accent: Color(red: 0.48, green: 0.58, blue: 0.68),
                accentDark: Color(red: 0.36, green: 0.45, blue: 0.55),
                accentLight: Color(red: 0.72, green: 0.78, blue: 0.84),
                warmGray: Color(red: 0.48, green: 0.52, blue: 0.58),
                lightBorder: Color(red: 0.84, green: 0.87, blue: 0.90),
                background: Color(red: 0.96, green: 0.97, blue: 0.98),
                momentTop: Color(red: 0.68, green: 0.74, blue: 0.82),
                momentMid: Color(red: 0.48, green: 0.58, blue: 0.68),
                momentBottom: Color(red: 0.34, green: 0.42, blue: 0.52),
                splashBackground: Color(red: 0.10, green: 0.14, blue: 0.20),
                tabSelected: Color(red: 0.18, green: 0.24, blue: 0.32),
                tabUnselected: Color(red: 0.55, green: 0.60, blue: 0.66)
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
    let tabSelected: Color
    let tabUnselected: Color

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
