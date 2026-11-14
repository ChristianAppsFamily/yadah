import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme
    let viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                theme.skyGradient
                    .frame(height: 140)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)

                    Text("Remove Ads Pro")
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            ScrollView {
                VStack(spacing: 24) {
                    Text("A More Focused Experience")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(theme.navy)
                        .padding(.top, 24)

                    VStack(spacing: 12) {
                        PremiumFeatureRow(icon: "xmark.circle.fill", text: "Remove all advertisements")
                        PremiumFeatureRow(icon: "paintpalette.fill", text: "Custom themes & backgrounds")
                        PremiumFeatureRow(icon: "bell.badge.fill", text: "Up to 5 daily reminders")
                        PremiumFeatureRow(icon: "text.book.closed.fill", text: "Choose your own verses")
                    }

                    VStack(spacing: 8) {
                        Text("One-time purchase")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(theme.warmGray)

                        Text(viewModel.storeKit.displayPrice)
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(theme.navy)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(theme.accent, lineWidth: 2)
                    }

                    SkyBlueButton(title: viewModel.storeKit.isPurchasing ? "Purchasing…" : "Unlock Pro") {
                        Task { await viewModel.purchaseRemoveAds() }
                    }
                    .disabled(viewModel.storeKit.isPurchasing)

                    Button {
                        Task { await viewModel.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(theme.accentDark)
                    }

                    if let message = viewModel.storeKit.lastErrorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe later")
                            .font(.subheadline)
                            .foregroundStyle(theme.warmGray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(theme.background)
        .task {
            await viewModel.storeKit.loadProducts()
        }
    }
}

struct PremiumFeatureRow: View {
    @Environment(\.themePalette) private var theme
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(theme.accent)
                .frame(width: 28)

            Text(text)
                .font(.body)
                .foregroundStyle(theme.navy)

            Spacer()
        }
        .padding(.horizontal, 8)
    }
}
