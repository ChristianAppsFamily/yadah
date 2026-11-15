import SwiftUI

struct ReminderPromptView: View {
    @Environment(\.themePalette) private var theme
    let onYes: () -> Void
    let onNo: () -> Void

    var body: some View {
        VStack(spacing: 0) {
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
                Button(action: onYes) {
                    Text("Yes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(theme.skyGradient)
                        .clipShape(.capsule)
                }

                Button(action: onNo) {
                    Text("No")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(theme.navy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .overlay {
                            Capsule().stroke(theme.accent, lineWidth: 1.5)
                        }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background {
            theme.background.ignoresSafeArea()
        }
    }
}
