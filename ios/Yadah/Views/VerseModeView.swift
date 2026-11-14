import SwiftUI

struct VerseModeView: View {
    @Environment(\.themePalette) private var theme
    @Binding var selectedMode: VerseMode
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    YadahWordmark()
                        .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("How would you like to\nreceive verses?")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(theme.navy)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 16) {
                        ModeCard(
                            icon: "shuffle",
                            title: "Randomly",
                            subtitle: "A new verse chosen for you each day",
                            isSelected: selectedMode == .random
                        ) {
                            withAnimation(.snappy) { selectedMode = .random }
                        }

                        ModeCard(
                            icon: "text.book.closed",
                            title: "I'll Choose My Own",
                            subtitle: "Select from our verse library (Pro)",
                            isSelected: selectedMode == .custom
                        ) {
                            withAnimation(.snappy) { selectedMode = .custom }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            SkyBlueButton(title: "Continue") {
                onContinue()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(theme.background)
    }
}

struct ModeCard: View {
    @Environment(\.themePalette) private var theme
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? theme.accentDark : theme.warmGray)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(theme.navy)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(theme.warmGray)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accent : theme.lightBorder)
            }
            .padding(18)
            .background(theme.background)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? theme.accent : theme.lightBorder, lineWidth: isSelected ? 2 : 1)
            }
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
