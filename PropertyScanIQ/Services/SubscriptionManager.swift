import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var isActive = false
    @Published var renewsAt: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let mockModeEnabled: Bool

    private let productIDs: [SubscriptionPlan: String] = [
        .proMonthly: "propertyscan_iq_pro_monthly",
        .proYearly: "propertyscan_iq_pro_yearly",
        .businessMonthly: "propertyscan_iq_business_monthly"
    ]

    private var transactionTask: Task<Void, Never>?

    init(mockModeEnabled: Bool = true) {
        self.mockModeEnabled = mockModeEnabled
        if mockModeEnabled {
            currentPlan = .free
            isActive = false
        } else {
            transactionTask = listenForTransactions()
        }
    }

    deinit {
        transactionTask?.cancel()
    }

    var canUseProFeatures: Bool {
        currentPlan.isPaid && isActive
    }

    var planLabel: String {
        isActive ? currentPlan.displayName : "Free"
    }

    func loadProducts() async {
        guard !mockModeEnabled else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Array(productIDs.values))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        guard let id = productIDs[plan] else { return nil }
        return products.first { $0.id == id }
    }

    func purchase(plan: SubscriptionPlan) async {
        if mockModeEnabled {
            activateMock(plan)
            return
        }

        guard let product = product(for: plan) else {
            errorMessage = "Subscription product is not available yet."
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateCustomerProductStatus()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        if mockModeEnabled {
            activateMock(.proMonthly)
            return
        }

        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func activateMock(_ plan: SubscriptionPlan) {
        currentPlan = plan
        isActive = plan.isPaid
        renewsAt = plan.isPaid ? Calendar.current.date(byAdding: .month, value: 1, to: Date()) : nil
    }

    func resetMockSubscription() {
        currentPlan = .free
        isActive = false
        renewsAt = nil
    }

    func updateCustomerProductStatus() async {
        guard !mockModeEnabled else { return }
        var bestPlan: SubscriptionPlan = .free
        var renewalDate: Date?

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result), transaction.revocationDate == nil else { continue }
            if let matchingPlan = productIDs.first(where: { $0.value == transaction.productID })?.key {
                bestPlan = matchingPlan
                renewalDate = transaction.expirationDate
            }
        }

        currentPlan = bestPlan
        isActive = bestPlan.isPaid
        renewsAt = renewalDate
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? self.checkVerified(result) else { continue }
                await self.updateCustomerProductStatus()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notAvailableInStorefront
        case .verified(let safe):
            return safe
        }
    }
}
