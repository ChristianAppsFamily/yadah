import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.themePalette) private var theme
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                YadahWordmark(size: .system(.title2, design: .serif, weight: .bold))
                    .padding(.top, 12)

                remindersSection
                themesSection
                versesSection
                connectSection
                aboutSection

                if !viewModel.storage.isPremium {
                    Button {
                        viewModel.showPaywall = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.white)
                            Text("Remove Ads Pro — \(viewModel.storeKit.displayPrice)")
                                .font(.system(.body, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(theme.skyGradient)
                        .clipShape(.capsule)
                    }
                }

                footer
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(theme.background)
        .task {
            await viewModel.storeKit.loadProducts()
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Reminders")

            if !viewModel.notificationService.isAuthorized {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                } label: {
                    Text("Enable Notifications in Settings")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.accentDark)
                }
            }

            if !viewModel.storage.isPremium {
                Text("Free: 1 reminder · Pro: up to 5")
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)
            }

            ForEach(viewModel.storage.reminderTimes, id: \.id) { reminder in
                ReminderRow(reminder: reminder) {
                    viewModel.toggleReminder(id: reminder.id)
                }
            }
        }
    }

    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Themes")

            VStack(spacing: 12) {
                ForEach(AppThemeOption.allCases) { themeOption in
                    SettingsOptionRow(
                        title: themeOption.isProOnly ? "\(themeOption.displayName) (Pro)" : themeOption.displayName,
                        isSelected: viewModel.storage.selectedTheme == themeOption
                    ) {
                        viewModel.setTheme(themeOption)
                    }
                }
            }
        }
    }

    private var versesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "My Verses")

            VStack(spacing: 12) {
                SettingsOptionRow(
                    title: "Random",
                    isSelected: viewModel.storage.verseMode == .random
                ) {
                    viewModel.setVerseMode(.random)
                }

                SettingsOptionRow(
                    title: viewModel.storage.isPremium ? "Choose My Own" : "Choose My Own (Pro)",
                    isSelected: viewModel.storage.verseMode == .custom
                ) {
                    viewModel.setVerseMode(.custom)
                }
            }
        }
    }

    private var connectSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Connect")

            VStack(spacing: 0) {
                SettingsLinkRow(title: "Facebook", systemImage: "f.square.fill") {
                    open(AppConstants.facebookURL)
                }
                Divider().padding(.leading, 40)
                SettingsLinkRow(title: "Follow Us on Instagram", systemImage: "camera.fill") {
                    open(AppConstants.instagramURL)
                }
                Divider().padding(.leading, 40)
                SettingsLinkRow(title: "Join Our Community (Women Only)", systemImage: "person.3.fill") {
                    open(AppConstants.communityURL)
                }
                Divider().padding(.leading, 40)
                SettingsLinkRow(title: "Contact Us", systemImage: "envelope.fill") {
                    open("mailto:\(AppConstants.contactEmail)")
                }
                Divider().padding(.leading, 40)
                SettingsLinkRow(title: "More Apps", systemImage: "square.grid.2x2.fill") {
                    open(AppConstants.moreAppsURL)
                }
                Divider().padding(.leading, 40)
                SettingsLinkRow(title: "Privacy Policy", systemImage: "hand.raised.fill") {
                    open(AppConstants.privacyPolicyURL)
                }
                Divider().padding(.leading, 40)
                SettingsLinkRow(title: "Rate This App", systemImage: "star.fill") {
                    RateAppService.openWriteReview()
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.lightBorder, lineWidth: 1)
            }
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "About")

            VStack(spacing: 0) {
                AboutRow(title: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.lightBorder, lineWidth: 1)
            }
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var footer: some View {
        VStack(spacing: 4) {
            Text(AppConstants.displayName)
                .font(.system(.body, design: .serif, weight: .semibold))
                .foregroundStyle(theme.navy)
            Text("Developed By")
                .font(.caption)
                .foregroundStyle(theme.warmGray)
            Text(AppConstants.developerName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.navy)
            Text("Copyright © \(AppConstants.copyrightYear) \(AppConstants.developerName)")
                .font(.caption2)
                .foregroundStyle(theme.warmGray)
            Text("All Rights Reserved.")
                .font(.caption2)
                .foregroundStyle(theme.warmGray)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 8)
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        openURL(url)
    }
}

struct SettingsSectionHeader: View {
    @Environment(\.themePalette) private var theme
    let title: String

    var body: some View {
        Text(title)
            .font(.system(.headline, design: .serif, weight: .semibold))
            .foregroundStyle(theme.navy)
    }
}

struct ReminderRow: View {
    @Environment(\.themePalette) private var theme
    let reminder: ReminderTime
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.displayTime)
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(theme.navy)

                Text(reminder.name)
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .tint(theme.accent)
            .labelsHidden()
        }
        .padding(14)
        .background(theme.background)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.lightBorder, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct SettingsOptionRow: View {
    @Environment(\.themePalette) private var theme
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(theme.navy)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accent : theme.lightBorder)
            }
            .padding(14)
            .background(theme.background)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.accent : theme.lightBorder, lineWidth: isSelected ? 1.5 : 1)
            }
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct AboutRow: View {
    @Environment(\.themePalette) private var theme
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundStyle(theme.navy)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundStyle(theme.warmGray)
        }
        .padding(14)
    }
}
