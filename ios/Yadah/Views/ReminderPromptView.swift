import SwiftUI

struct ReminderPromptView: View {
    @Environment(\.themePalette) private var theme
    let onBack: () -> Void
    let onYes: () async -> Void
    let onNo: () async -> Void

    @State private var isWorking = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Label("Back", systemImage: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(theme.accentDark)
                }
                .disabled(isWorking)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 16) {
                YadahWordmark()

                Text("Setup your daily Reminders to Give the Lord Thanks now?")
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundStyle(theme.navy)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("You can always change this later in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(theme.warmGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    guard !isWorking else { return }
                    isWorking = true
                    Task {
                        await onYes()
                        isWorking = false
                    }
                } label: {
                    HStack(spacing: 10) {
                        if isWorking {
                            ProgressView().tint(.white)
                        }
                        Text("Yes")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(theme.skyGradient)
                    .clipShape(.capsule)
                }
                .disabled(isWorking)

                Button {
                    guard !isWorking else { return }
                    isWorking = true
                    Task {
                        await onNo()
                        isWorking = false
                    }
                } label: {
                    Text("No")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(theme.navy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .overlay {
                            Capsule().stroke(theme.accent, lineWidth: 1.5)
                        }
                }
                .disabled(isWorking)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background {
            theme.background.ignoresSafeArea()
        }
    }
}
