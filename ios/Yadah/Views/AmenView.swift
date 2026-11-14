import SwiftUI

struct AmenView: View {
    @Environment(\.themePalette) private var theme
    let onComplete: () -> Void
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.7

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            Text("AMEN")
                .font(.system(size: 52, weight: .bold, design: .serif))
                .foregroundStyle(theme.navy)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .statusBarHidden()
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1
                scale = 1
            }

            Task {
                try? await Task.sleep(for: .seconds(2.5))
                withAnimation(.easeOut(duration: 0.6)) {
                    opacity = 0
                    scale = 1.1
                }
                try? await Task.sleep(for: .seconds(0.7))
                onComplete()
            }
        }
    }
}
