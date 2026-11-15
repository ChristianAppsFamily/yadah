import SwiftUI

struct ReminderSetupView: View {
    @Environment(\.themePalette) private var theme
    @Binding var selectedMode: ReminderSetupMode
    var isLoading: Bool = false
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    YadahWordmark()
                        .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("When should we remind you\nto give Thanks to the Lord?")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(theme.navy)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 16) {
                        ModeCard(
                            icon: "shuffle",
                            title: "Randomly",
                            subtitle: "We'll pick a morning moment for you",
                            isSelected: selectedMode == .random
                        ) {
                            withAnimation(.snappy) { selectedMode = .random }
                        }

                        ModeCard(
                            icon: "clock",
                            title: "Set My Times",
                            subtitle: "Choose reminder times in Settings",
                            isSelected: selectedMode == .custom
                        ) {
                            withAnimation(.snappy) { selectedMode = .custom }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Button {
                onStart()
            } label: {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isLoading ? "Starting…" : "Start Receiving")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(theme.skyGradient)
                .clipShape(.capsule)
            }
            .disabled(isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(theme.background)
    }
}

nonisolated enum ReminderSetupMode: Sendable {
    case random
    case custom
}
