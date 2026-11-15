import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme
    let viewModel: AppViewModel
    @State private var selectedPlan: ProPlan = .yearly

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

                    Text("Yadah Pro")
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
                        PremiumFeatureRow(icon: "bell.badge.fill", text: "Up to 5 daily reminders")
                        PremiumFeatureRow(icon: "text.book.closed.fill", text: "Choose your own verses")
                        PremiumFeatureRow(icon: "paintpalette.fill", text: "Pro themes & Day mode extras")
                        PremiumFeatureRow(icon: "xmark.circle.fill", text: "No advertisements")
                    }

                    if !viewModel.storage.isPro {
                        HStack(spacing: 14) {
                            PricingCard(
                                period: "Monthly",
                                price: viewModel.storeKit.monthlyDisplayPrice,
                                subtext: "/month",
                                isHighlighted: selectedPlan == .monthly
                            ) {
                                selectedPlan = .monthly
                            }

                            ZStack(alignment: .top) {
                                PricingCard(
                                    period: "Yearly",
                                    price: viewModel.storeKit.yearlyDisplayPrice,
                                    subtext: "/year",
                                    isHighlighted: selectedPlan == .yearly
                                ) {
                                    selectedPlan = .yearly
                                }

                                Text("Save 44%")
                                    .font(.system(.caption2, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(theme.skyGradient)
                                    .clipShape(.capsule)
                                    .offset(y: -10)
                            }
                        }
                        .padding(.top, 4)

                        SkyBlueButton(
                            title: viewModel.storeKit.isPurchasing
                                ? "Purchasing…"
                                : "Start 7-Day Free Trial"
                        ) {
                            Task {
                                switch selectedPlan {
                                case .monthly:
                                    await viewModel.purchaseProMonthly()
                                case .yearly:
                                    await viewModel.purchaseProYearly()
                                }
                            }
                        }
                        .disabled(viewModel.storeKit.isPurchasing)
                    }

                    if !viewModel.storage.adsHidden {
                        VStack(spacing: 10) {
                            Text("Or remove ads only")
                                .font(.subheadline)
                                .foregroundStyle(theme.warmGray)

                            Button {
                                Task { await viewModel.purchaseRemoveAds() }
                            } label: {
                                Text("REMOVE ADS: One-Time-\(viewModel.storeKit.removeAdsDisplayPrice)")
                                    .font(.system(.body, weight: .semibold))
                                    .foregroundStyle(theme.navy)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .overlay {
                                        Capsule().stroke(theme.accent, lineWidth: 1.5)
                                    }
                            }
                            .disabled(viewModel.storeKit.isPurchasing)
                        }
                    }

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

nonisolated enum ProPlan: Sendable {
    case monthly
    case yearly
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

struct PricingCard: View {
    @Environment(\.themePalette) private var theme
    let period: String
    let price: String
    let subtext: String
    let isHighlighted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(period)
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(theme.navy)

                Text(price)
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundStyle(theme.navy)

                Text(subtext)
                    .font(.caption2)
                    .foregroundStyle(theme.warmGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(theme.background)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isHighlighted ? theme.accent : theme.lightBorder, lineWidth: isHighlighted ? 2 : 1)
            }
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
