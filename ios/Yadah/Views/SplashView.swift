import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void
    @State private var didFinish = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("cae_splash")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        }
        .statusBarHidden()
        .task {
            try? await Task.sleep(for: .seconds(1.7))
            finishOnce()
        }
    }

    private func finishOnce() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
