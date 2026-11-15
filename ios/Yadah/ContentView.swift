import SwiftUI
import UIKit

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
        .preferredColorScheme(viewModel.preferredColorScheme)
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
                let state = await viewModel.storeKit.refreshEntitlements()
                viewModel.applyEntitlements(state)
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
    @State private var step: OnboardingStep = .profile
    @State private var didRequestATT = false

    var body: some View {
        Group {
            switch step {
            case .profile:
                ProfileSetupView(initialProfile: viewModel.storage.userProfile) { name, city, state, wallInitials in
                    viewModel.saveProfile(
                        name: name,
                        city: city,
                        state: state,
                        wallInitials: wallInitials
                    )
                    withAnimation(.easeInOut) { step = .reminderPrompt }
                }

            case .reminderPrompt:
                ReminderPromptView(
                    onBack: {
                        withAnimation(.easeInOut) { step = .profile }
                    },
                    onYes: {
                        await viewModel.finishOnboarding(openSettings: true)
                    },
                    onNo: {
                        await viewModel.finishOnboarding(openSettings: false)
                    }
                )
            }
        }
        .transition(.opacity)
        .task {
            guard !didRequestATT else { return }
            didRequestATT = true
            // System LaunchScreen already showed CAE; request ATT once before setup continues.
            await viewModel.requestATTAfterSplash()
        }
    }
}

nonisolated enum OnboardingStep: Sendable {
    case profile, reminderPrompt
}

struct MainTabView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.themePalette) private var theme

    var body: some View {
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
        .tint(theme.tabSelected)
        .onAppear {
            applyTabBarAppearance(theme: theme)
        }
        .onChange(of: viewModel.storage.selectedTheme) { _, _ in
            applyTabBarAppearance(theme: viewModel.themePalette)
        }
        .task {
            await viewModel.prepareAdsAfterOnboarding()
            if !viewModel.notificationService.isAuthorized {
                await viewModel.requestNotificationsAfterOnboarding()
            }
            RateAppService.recordVisitAndMaybePrompt()
        }
    }

    private func applyTabBarAppearance(theme: ThemePalette) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(theme.background)

        let selected = UIColor(theme.tabSelected)
        let unselected = UIColor(theme.tabUnselected)

        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]
        appearance.stackedLayoutAppearance.normal.iconColor = unselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselected]

        appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
