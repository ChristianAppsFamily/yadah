import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void
    @State private var didFinish = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            GeometryReader { proxy in
                Image("cae_splash")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .accessibilityHidden(true)
            }
            .ignoresSafeArea()
        }
        .statusBarHidden()
        .task {
            try? await Task.sleep(for: .seconds(1.0))
            finishOnce()
        }
    }

    private func finishOnce() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
