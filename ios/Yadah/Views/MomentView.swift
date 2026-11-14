import SwiftUI

struct MomentView: View {
    @Environment(\.themePalette) private var theme
    let scripture: Scripture
    let onComplete: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            theme.momentGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text(AppConstants.displayName)
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 16)

                Spacer()

                VStack(spacing: 32) {
                    Text("\"\(scripture.text)\"")
                        .font(.system(.title3, design: .serif, weight: .regular))
                        .italic()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    Text("— \(scripture.reference)")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .opacity(appeared ? 1 : 0)

                    VStack(spacing: 6) {
                        Text("Take a moment.")
                            .font(.system(.callout, design: .default))
                            .italic()
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Breathe. Thank Him.")
                            .font(.system(.callout, design: .default))
                            .italic()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .opacity(appeared ? 1 : 0)
                }
                .padding(.horizontal, 32)

                Spacer()

                Button(action: onComplete) {
                    Text("In Jesus' Name")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundStyle(theme.navy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.white)
                        .clipShape(.capsule)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
        .statusBarHidden()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }
}
