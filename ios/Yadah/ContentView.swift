import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if !viewModel.storage.hasOnboarded {
                OnboardingFlow(viewModel: viewModel)
            } else if viewModel.showMoment {
                MomentView(scripture: viewModel.currentScripture) {
                    viewModel.completeMoment()
                }
                .transition(.opacity)
            } else if viewModel.showAmen {
                AmenView {
                    viewModel.completeAmen()
                }
                .transition(.opacity)
            } else {
                MainTabView(viewModel: viewModel)
            }
        }
        .environment(\.themePalette, viewModel.themePalette)
        .animation(.easeInOut(duration: 0.4), value: viewModel.storage.hasOnboarded)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showMoment)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showAmen)
        .task {
            await viewModel.setup()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showMoment)) { _ in
            viewModel.triggerMoment()
        }
        .onReceive(NotificationCenter.default.publisher(for: .yadahPurchaseUpdated)) { _ in
            Task {
                if await viewModel.storeKit.refreshEntitlements() {
                    viewModel.storage.isPremium = true
                    viewModel.adService.disableAds()
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(viewModel: viewModel)
                .environment(\.themePalette, viewModel.themePalette)
        }
    }
}

struct OnboardingFlow: View {
    let viewModel: AppViewModel
    @State private var step: OnboardingStep = .splash
    @State private var reminderMode: ReminderSetupMode = .random

    var body: some View {
        Group {
            switch step {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut) { step = .profile }
                }

            case .profile:
                ProfileSetupView { name, city, state in
                    viewModel.saveProfile(name: name, city: city, state: state)
                    withAnimation(.easeInOut) { step = .verseMode }
                }

            case .verseMode:
                VerseModeView(selectedMode: Binding(
                    get: { viewModel.storage.verseMode },
                    set: { viewModel.storage.verseMode = $0 }
                )) {
                    if viewModel.storage.verseMode == .custom {
                        if viewModel.storage.isPremium {
                            withAnimation(.easeInOut) { step = .verseLibrary }
                        } else {
                            viewModel.storage.verseMode = .random
                            viewModel.showPaywall = true
                            withAnimation(.easeInOut) { step = .reminders }
                        }
                    } else {
                        withAnimation(.easeInOut) { step = .reminders }
                    }
                }

            case .verseLibrary:
                VerseLibraryView(selectedIds: Binding(
                    get: { viewModel.storage.selectedVerseIds },
                    set: { viewModel.storage.selectedVerseIds = $0 }
                )) {
                    withAnimation(.easeInOut) { step = .reminders }
                }

            case .reminders:
                ReminderSetupView(selectedMode: $reminderMode) {
                    Task {
                        applyReminderMode()
                        _ = await viewModel.requestNotificationPermission()
                        viewModel.completeOnboarding()
                        viewModel.completeSetup()
                        await viewModel.prepareAdsAfterOnboarding()
                    }
                }
            }
        }
        .transition(.opacity)
    }

    private func applyReminderMode() {
        var times = viewModel.storage.reminderTimes
        switch reminderMode {
        case .random:
            for index in times.indices {
                times[index].isEnabled = false
            }
            if let morning = times.firstIndex(where: { $0.id == "morning" }) {
                times[morning].isEnabled = true
            } else if !times.isEmpty {
                times[0].isEnabled = true
            }
        case .custom:
            break
        }
        viewModel.storage.reminderTimes = times
        viewModel.storage.normalizeReminderLimits(isPremium: viewModel.storage.isPremium)
        viewModel.notificationService.scheduleNotifications(for: viewModel.storage.reminderTimes)
    }
}

nonisolated enum OnboardingStep: Sendable {
    case splash, profile, verseMode, verseLibrary, reminders
}

struct MainTabView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.themePalette) private var theme

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.selectedTab) {
                Tab("Home", systemImage: "house.fill", value: TabSelection.home) {
                    HomeView(viewModel: viewModel)
                }

                Tab("Thank You Wall", systemImage: "person.3.fill", value: TabSelection.wall) {
                    ThankYouWallView(viewModel: viewModel)
                }

                Tab("Settings", systemImage: "gearshape.fill", value: TabSelection.settings) {
                    SettingsView(viewModel: viewModel)
                }
            }
            .tint(theme.accent)

            AdBannerContainer(adService: viewModel.adService, isPremium: viewModel.storage.isPremium)
        }
        .task {
            await viewModel.prepareAdsAfterOnboarding()
            RateAppService.recordVisitAndMaybePrompt()
        }
    }
}
