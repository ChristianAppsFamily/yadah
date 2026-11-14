import SwiftUI

struct ThankYouWallView: View {
    let viewModel: AppViewModel
    @Environment(\.themePalette) private var theme
    @State private var appeared = false

    private var entries: [WallEntry] {
        viewModel.storage.localWallEntries
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                YadahWordmark(size: .system(.title2, design: .serif, weight: .bold))

                Text("Thank You Wall")
                    .font(.system(.headline, design: .serif, weight: .semibold))
                    .foregroundStyle(theme.navy)

                Text(entries.isEmpty
                     ? "Your thanks will appear here"
                     : "Your moments of gratitude")
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)
            }
            .padding(.top, 12)
            .padding(.bottom, 16)

            if entries.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "hands.sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(theme.accent)
                    Text("No entries yet")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(theme.navy)
                    Text("Tap Give Thanks on Home to add your first entry. A shared community wall will appear once a backend is connected.")
                        .font(.subheadline)
                        .foregroundStyle(theme.warmGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            WallEntryCard(entry: entry)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                                .animation(.spring(response: 0.4).delay(Double(index) * 0.05), value: appeared)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(theme.background)
        .onAppear {
            appeared = true
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
