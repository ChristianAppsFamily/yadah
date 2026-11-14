import SwiftUI

enum YadahColors {
    static let navy = Color(red: 0.09, green: 0.20, blue: 0.35)
    static let skyBlue = Color(red: 0.58, green: 0.83, blue: 0.94)
    static let skyBlueDark = Color(red: 0.42, green: 0.72, blue: 0.87)
    static let skyBlueLight = Color(red: 0.68, green: 0.88, blue: 0.96)
    static let warmGray = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let lightBorder = Color(red: 0.91, green: 0.93, blue: 0.95)
    static let cardBackground = Color.white

    static let skyGradient = LinearGradient(
        colors: [skyBlueLight, skyBlue],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let momentGradient = LinearGradient(
        colors: [
            Color(red: 0.58, green: 0.83, blue: 0.94),
            Color(red: 0.45, green: 0.73, blue: 0.89),
            Color(red: 0.35, green: 0.62, blue: 0.82)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct YadahWordmark: View {
    @Environment(\.themePalette) private var theme
    let size: Font

    init(size: Font = .system(.title, design: .serif, weight: .bold)) {
        self.size = size
    }

    var body: some View {
        Text(AppConstants.displayName)
            .font(size)
            .foregroundStyle(theme.navy)
    }
}

struct SkyBlueButton: View {
    @Environment(\.themePalette) private var theme
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(theme.skyGradient)
                .clipShape(.capsule)
        }
    }
}

struct SettingsLinkRow: View {
    @Environment(\.themePalette) private var theme
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(theme.accentDark)
                    .frame(width: 24)
                Text(title)
                    .font(.body)
                    .foregroundStyle(theme.navy)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }
}
