import Foundation
import StoreKit

struct EntitlementState: Equatable {
    var hasRemovedAds = false
    var isPro = false
}

@Observable
@MainActor
final class StoreKitService {
    private(set) var removeAdsProduct: Product?
    private(set) var monthlyProduct: Product?
    private(set) var yearlyProduct: Product?
    private(set) var isPurchasing = false
    private(set) var lastErrorMessage: String?
    private var updatesTask: Task<Void, Never>?

    var removeAdsDisplayPrice: String {
        removeAdsProduct?.displayPrice ?? AppConstants.removeAdsFallbackPrice
    }

    var monthlyDisplayPrice: String {
        monthlyProduct?.displayPrice ?? AppConstants.proMonthlyFallbackPrice
    }

    var yearlyDisplayPrice: String {
        yearlyProduct?.displayPrice ?? AppConstants.proYearlyFallbackPrice
    }

    func start() {
        updatesTask?.cancel()
        updatesTask = Task { await listenForTransactions() }
        Task { await loadProducts() }
        Task { _ = await refreshEntitlements() }
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: AppConstants.allProductIDs)
            removeAdsProduct = products.first { $0.id == AppConstants.removeAdsProductID }
            monthlyProduct = products.first { $0.id == AppConstants.proMonthlyProductID }
            yearlyProduct = products.first { $0.id == AppConstants.proYearlyProductID }
        } catch {
            lastErrorMessage = "Unable to load products."
        }
    }

    func purchaseRemoveAds() async -> Bool {
        await purchase(product: removeAdsProduct, productID: AppConstants.removeAdsProductID)
    }

    func purchaseMonthly() async -> Bool {
        await purchase(product: monthlyProduct, productID: AppConstants.proMonthlyProductID)
    }

    func purchaseYearly() async -> Bool {
        await purchase(product: yearlyProduct, productID: AppConstants.proYearlyProductID)
    }

    func restore() async -> EntitlementState {
        do {
            try await AppStore.sync()
            return await refreshEntitlements()
        } catch {
            lastErrorMessage = "Unable to restore purchases."
            return EntitlementState()
        }
    }

    @discardableResult
    func refreshEntitlements() async -> EntitlementState {
        var state = EntitlementState()
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            switch transaction.productID {
            case AppConstants.removeAdsProductID:
                state.hasRemovedAds = true
            case AppConstants.proMonthlyProductID, AppConstants.proYearlyProductID:
                state.isPro = true
                state.hasRemovedAds = true
            default:
                break
            }
        }
        return state
    }

    private func purchase(product: Product?, productID: String) async -> Bool {
        var resolved = product
        if resolved == nil {
            await loadProducts()
            switch productID {
            case AppConstants.removeAdsProductID:
                resolved = removeAdsProduct
            case AppConstants.proMonthlyProductID:
                resolved = monthlyProduct
            case AppConstants.proYearlyProductID:
                resolved = yearlyProduct
            default:
                resolved = nil
            }
        }

        guard let resolved else {
            lastErrorMessage = "Product unavailable. Try again later."
            return false
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await resolved.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    lastErrorMessage = "Purchase could not be verified."
                    return false
                }
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastErrorMessage = "Purchase failed. Please try again."
            return false
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            await transaction.finish()
            NotificationCenter.default.post(name: .yadahPurchaseUpdated, object: nil)
        }
    }
}

extension Notification.Name {
    static let yadahPurchaseUpdated = Notification.Name("yadahPurchaseUpdated")
}
