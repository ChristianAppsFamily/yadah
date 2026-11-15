import SwiftUI

struct ThankYouWallView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.themePalette) private var theme

    private var entries: [WallEntry] {
        viewModel.wallService.entries
    }

    private var thanksTotal: Int {
        viewModel.wallService.displayedThanksTotal
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                YadahWordmark(size: .system(.title2, design: .serif, weight: .bold))

                Text(thanksTotalLabel)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.warmGray)
                    .monospacedDigit()
            }
            .padding(.top, 12)
            .padding(.bottom, 16)

            if !viewModel.hasJoinedWall {
                joinPrompt
            } else if entries.isEmpty {
                emptyState
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
                .refreshable {
                    await viewModel.wallService.refresh()
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
        .task {
            await viewModel.wallService.refresh()
        }
    }

    private var thanksTotalLabel: String {
        let formatted = thanksTotal.formatted(.number.grouping(.automatic))
        if thanksTotal == 1 {
            return "1 has given thanks"
        }
        return "\(formatted) have given thanks"
    }

    private var joinPrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("yadah_hands_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

            Text("Join the Thank You Wall")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(theme.navy)

            Text("Add your name and city so others can see you giving thanks.")
                .font(.subheadline)
                .foregroundStyle(theme.warmGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                viewModel.openWallJoinInSettings()
            } label: {
                Text("Join the wall!")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(theme.skyGradient)
                    .clipShape(.capsule)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
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
            Spacer()
        }
    }
}

struct WallEntryCard: View {
    @Environment(\.themePalette) private var theme
    let entry: WallEntry

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.initials)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.navy)
                .frame(width: 40, height: 40)
                .background(theme.accentLight.opacity(0.55))
                .clipShape(.circle)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.initials)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.navy)

                Text(entry.city)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(theme.warmGray)
            }

            Spacer(minLength: 8)

            Text(timeAgo(entry.timestamp))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.warmGray.opacity(0.65))
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
