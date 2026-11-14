import Foundation
import StoreKit

@Observable
@MainActor
final class StoreKitService {
    private(set) var product: Product?
    private(set) var isPurchasing = false
    private(set) var lastErrorMessage: String?
    private var updatesTask: Task<Void, Never>?

    var displayPrice: String {
        product?.displayPrice ?? AppConstants.removeAdsFallbackPrice
    }

    func start() {
        updatesTask?.cancel()
        updatesTask = Task { await listenForTransactions() }
        Task { await loadProducts() }
        Task { await refreshEntitlements() }
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [AppConstants.removeAdsProductID])
            product = products.first
        } catch {
            lastErrorMessage = "Unable to load products."
        }
    }

    func purchase() async -> Bool {
        guard let product else {
            await loadProducts()
            guard let product else {
                lastErrorMessage = "Product unavailable. Try again later."
                return false
            }
            return await purchase(product)
        }
        return await purchase(product)
    }

    func restore() async -> Bool {
        do {
            try await AppStore.sync()
            return await refreshEntitlements()
        } catch {
            lastErrorMessage = "Unable to restore purchases."
            return false
        }
    }

    @discardableResult
    func refreshEntitlements() async -> Bool {
        var owned = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == AppConstants.removeAdsProductID {
                owned = true
                break
            }
        }
        return owned
    }

    private func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
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
