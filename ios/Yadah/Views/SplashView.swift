import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void
    @State private var appeared = false
    @State private var didFinish = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("cae_splash")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .opacity(appeared ? 1 : 0)
        }
        .statusBarHidden()
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                appeared = true
            }
            Task {
                try? await Task.sleep(for: .seconds(1.8))
                finishOnce()
            }
        }
    }

    private func finishOnce() {
        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}
