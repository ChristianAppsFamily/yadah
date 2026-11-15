import SwiftUI

struct ThankYouWallView: View {
    let viewModel: AppViewModel
    @Environment(\.themePalette) private var theme

    private var entries: [WallEntry] {
        viewModel.storage.localWallEntries
    }

    var body: some View {
        VStack(spacing: 0) {
            YadahWordmark(size: .system(.title2, design: .serif, weight: .bold))
                .padding(.top, 12)
                .padding(.bottom, 16)

            if entries.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image("yadah_hands_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)

                    Text("No entries yet")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(theme.navy)

                    Text("This is a shared community wall of everyone giving thanks, feel free to encourage one another!")
                        .font(.subheadline)
                        .foregroundStyle(theme.warmGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(entries) { entry in
                            WallEntryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
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
}

struct WallEntryCard: View {
    @Environment(\.themePalette) private var theme
    let entry: WallEntry

    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(theme.skyGradient)
                .frame(width: 4)
                .clipShape(.capsule)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.initials)
                    .font(.system(.headline, design: .serif, weight: .bold))
                    .foregroundStyle(theme.navy)

                Text(entry.city)
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)
            }

            Spacer()

            Text(timeAgo(entry.timestamp))
                .font(.caption2)
                .foregroundStyle(theme.warmGray.opacity(0.7))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(theme.background)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.lightBorder, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 14))
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }
}
