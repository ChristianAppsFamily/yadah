import SwiftUI

struct HomeView: View {
    let viewModel: AppViewModel
    @Environment(\.themePalette) private var theme

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    YadahWordmark(size: .system(.title, design: .serif, weight: .bold))
                        .padding(.top, 12)

                    VStack(spacing: 20) {
                        Text(todayDateString)
                            .font(.system(.headline, design: .serif, weight: .semibold))
                            .foregroundStyle(theme.navy)

                        ScriptureCard(scripture: viewModel.currentScripture)
                    }

                    if viewModel.storage.todayCount > 0 {
                        HStack(spacing: 24) {
                            StatPill(label: "Today", value: "\(viewModel.storage.todayCount)")
                            StatPill(label: "All Time", value: "\(viewModel.storage.totalCount)")
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }

            Button {
                viewModel.triggerMoment()
            } label: {
                Text("Give Thanks")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(theme.accent)
                    .clipShape(.capsule)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.showMoment)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background {
            theme.background.ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AdBannerContainer(
                adService: viewModel.adService,
                adsHidden: viewModel.storage.adsHidden
            )
        }
    }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

struct ScriptureCard: View {
    @Environment(\.themePalette) private var theme
    let scripture: Scripture

    var body: some View {
        VStack(spacing: 14) {
            Text("\"\(scripture.text)\"")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(theme.navy.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Rectangle()
                .fill(theme.accent.opacity(0.3))
                .frame(width: 40, height: 1)

            Text(scripture.reference)
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundStyle(theme.warmGray)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(theme.background)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.lightBorder, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}

struct StatPill: View {
    @Environment(\.themePalette) private var theme
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(theme.navy)

            Text(label)
                .font(.caption2)
                .foregroundStyle(theme.warmGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(theme.background)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.lightBorder, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}
