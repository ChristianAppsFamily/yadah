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
                    .padding(.horizontal, 24)

                AdBannerContainer(
                    adService: viewModel.adService,
                    adsHidden: viewModel.storage.adsHidden
                )

                VStack(spacing: 28) {
                    profileSection
                    upgradeSection
                    remindersSection
                    themesSection
                    versesSection
                    connectSection
                    aboutSection
                    footer
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
        .background {
            theme.background.ignoresSafeArea()
        }
        .task {
            await viewModel.storeKit.loadProducts()
        }
        .onChange(of: viewModel.focusProfileInSettings) { _, focused in
            if focused {
                viewModel.showProfileSheet = true
            }
        }
        .sheet(isPresented: $viewModel.showProfileSheet, onDismiss: {
            viewModel.focusProfileInSettings = false
        }) {
            ProfileSheetView(viewModel: viewModel)
                .environment(\.themePalette, theme)
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                viewModel.openProfileSheet()
            } label: {
                Text(viewModel.hasJoinedWall ? "Edit Profile" : "Create Profile")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(theme.skyGradient)
                    .clipShape(.capsule)
            }

            if let profile = viewModel.storage.userProfile, profile.hasJoinedWall {
                Text("\(profile.name) · \(WallService.cityLabel(for: profile))")
                    .font(.subheadline)
                    .foregroundStyle(theme.warmGray)
            } else if viewModel.focusProfileInSettings {
                Text("Add your name and city to join the wall.")
                    .font(.subheadline)
                    .foregroundStyle(theme.warmGray)
            }
        }
    }

    private var upgradeSection: some View {
        VStack(spacing: 12) {
            if !viewModel.storage.isPro {
                Button {
                    viewModel.showPaywall = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.white)
                        Text("Yadah Pro")
                            .font(.system(.body, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(theme.skyGradient)
                    .clipShape(.capsule)
                }
            }

            if !viewModel.storage.adsHidden {
                Button {
                    viewModel.showPaywall = true
                } label: {
                    Text("REMOVE ADS: One-Time-\(viewModel.storeKit.removeAdsDisplayPrice)")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(theme.navy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .overlay {
                            Capsule().stroke(theme.accent, lineWidth: 1.5)
                        }
                }
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: "Reminders")

            ForEach(viewModel.storage.reminderTimes) { reminder in
                ReminderRow(
                    reminder: reminder,
                    isPro: viewModel.storage.isPro,
                    onEnabledChange: { enabled in
                        viewModel.setReminderEnabled(id: reminder.id, isEnabled: enabled)
                    },
                    onTimeChange: { date in
                        viewModel.updateReminderTime(id: reminder.id, date: date)
                    },
                    onLockedTap: {
                        viewModel.showPaywall = true
                    }
                )
            }

            if viewModel.storage.isPro {
                Button {
                    viewModel.addCustomReminder()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add reminder")
                            .font(.system(.body, weight: .semibold))
                    }
                    .foregroundStyle(theme.accentDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.accent, lineWidth: 1.5)
                    }
                }
                .buttonStyle(.plain)
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
                    title: viewModel.storage.isPro ? "Choose My Own" : "Choose My Own (Pro)",
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

struct ProfileSheetView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.themePalette) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("This profile is for the Thank You Wall. Your photo stays on this device.")
                        .font(.subheadline)
                        .foregroundStyle(theme.warmGray)
                        .fixedSize(horizontal: false, vertical: true)

                    ProfileSetupView(
                        initialProfile: viewModel.storage.userProfile,
                        embeddedInSettings: true,
                        saveButtonTitle: viewModel.hasJoinedWall ? "Save Profile" : "Create Profile"
                    ) { name, country, city, state, photoFileName in
                        viewModel.saveProfile(
                            name: name,
                            country: country,
                            city: city,
                            state: state,
                            localPhotoFileName: photoFileName
                        )
                        dismiss()
                    }
                }
                .padding(24)
            }
            .background {
                theme.background.ignoresSafeArea()
            }
            .navigationTitle(viewModel.hasJoinedWall ? "Edit Profile" : "Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
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
    let isPro: Bool
    let onEnabledChange: (Bool) -> Void
    let onTimeChange: (Date) -> Void
    let onLockedTap: () -> Void

    private var timeEditingLocked: Bool {
        !isPro && !reminder.isEnabled
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(reminder.name)
                    .font(.caption)
                    .foregroundStyle(theme.warmGray)

                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(theme.accentDark)

                    if timeEditingLocked {
                        Button(action: onLockedTap) {
                            HStack(spacing: 4) {
                                Text(reminder.displayTime)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(theme.navy)
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(theme.warmGray)
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { reminder.asDate },
                                set: { onTimeChange($0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(theme.accent)
                    }
                }
            }

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { onEnabledChange($0) }
                )
            )
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
            .contentShape(Rectangle())
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
