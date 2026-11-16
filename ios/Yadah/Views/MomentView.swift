import SwiftUI

struct MomentView: View {
    @Environment(\.themePalette) private var theme
    let onComplete: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            theme.momentGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text(AppConstants.displayName)
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 20)

                Spacer(minLength: 32)

                VStack(spacing: 20) {
                    Text(instructionCopy)
                        .font(.system(.title3, design: .serif, weight: .regular))
                        .foregroundStyle(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    Text("THANK YOU LORD!")
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 32)

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
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }
        }
        .statusBarHidden()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.15)) {
                appeared = true
            }
        }
    }

    private var instructionCopy: String {
        MomentPrompt.forToday().body
    }
}
