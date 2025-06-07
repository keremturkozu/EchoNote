import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    
    let productIds = ["com.yourappname.echonote.premium.yearly"]
    
    @Published
    private(set) var products: [Product] = []
    
    @Published
    private(set) var purchasedProductIDs = Set<String>()
    
    @Published
    var isPremiumUser: Bool = false
    
    private var transactionListener: Task<Void, Error>? = nil

    init() {
        transactionListener = listenForTransactions()
        
        Task {
            await retrieveProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func retrieveProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            products = storeProducts
        } catch {
            print("Failed to fetch products: \\(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            // Check if the transaction is verified.
            switch verificationResult {
            case .verified(let transaction):
                // The transaction is verified. Finish it.
                await transaction.finish()
                await self.updatePurchasedProducts()
            case .unverified(_, _):
                // Transaction verification failed. Do not grant access.
                break
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        purchasedProductIDs.removeAll()
        isPremiumUser = false
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            }
        }
        
        self.isPremiumUser = !self.purchasedProductIDs.isEmpty
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handle(transactionVerification: result)
            }
        }
    }
    
    private func handle(transactionVerification result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await transaction.finish()
            await self.updatePurchasedProducts()
        default:
            break
        }
    }
} 