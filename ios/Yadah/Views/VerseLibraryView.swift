import SwiftUI

struct VerseLibraryView: View {
    @Environment(\.themePalette) private var theme
    @Binding var selectedIds: [String]
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        YadahWordmark()
                        Text("Choose Your Verses")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(theme.navy)
                    }
                    .padding(.top, 20)

                    ForEach(ScriptureTheme.allCases, id: \.self) { themeItem in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(themeItem.rawValue)
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(theme.navy)
                                .padding(.leading, 4)

                            ForEach(Scripture.byTheme(themeItem)) { scripture in
                                VerseSelectCard(
                                    scripture: scripture,
                                    isSelected: selectedIds.contains(scripture.id)
                                ) {
                                    toggleSelection(scripture.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            SkyBlueButton(title: "Save My List") {
                onSave()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(theme.background)
    }

    private func toggleSelection(_ id: String) {
        withAnimation(.snappy) {
            if selectedIds.contains(id) {
                selectedIds.removeAll { $0 == id }
            } else {
                selectedIds.append(id)
            }
        }
    }
}

struct VerseSelectCard: View {
    @Environment(\.themePalette) private var theme
    let scripture: Scripture
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(scripture.reference)
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundStyle(theme.navy)

                    Text(scripture.text)
                        .font(.caption)
                        .foregroundStyle(theme.warmGray)
                        .lineLimit(3)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.accent : theme.lightBorder)
            }
            .padding(16)
            .background(theme.background)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? theme.accent : theme.lightBorder, lineWidth: isSelected ? 1.5 : 1)
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
