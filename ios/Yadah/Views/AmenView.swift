import SwiftUI

struct AmenView: View {
    @Environment(\.themePalette) private var theme
    let onComplete: () -> Void
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.85

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
            withAnimation(.easeInOut(duration: 0.75)) {
                opacity = 1
                scale = 1
            }

            Task {
                try? await Task.sleep(for: .seconds(2.6))
                withAnimation(.easeInOut(duration: 0.85)) {
                    opacity = 0
                    scale = 1.05
                }
                try? await Task.sleep(for: .seconds(0.9))
                onComplete()
            }
        }
    }
}
