import SwiftUI

struct SplashView: View {
    let onGetStarted: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.12, blue: 0.22)
                .ignoresSafeArea()

            Image("yadah_hands_logo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 1.05)

            VStack {
                Spacer()

                Text("Give Thanks to the Lord")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 20)

                SkyBlueButton(title: "Get Started") {
                    onGetStarted()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 56)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}
