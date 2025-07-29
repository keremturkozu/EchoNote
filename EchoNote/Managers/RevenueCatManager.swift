import Foundation
import SwiftUI

// Temporary mock for testing without RevenueCat
// TODO: Add RevenueCat package and uncomment RevenueCat import
// import RevenueCat

// MARK: - Mock Package for testing
struct MockPackage {
    let identifier: String
    let packageType: PackageType
    let price: String
    
    enum PackageType {
        case weekly, monthly, annual, lifetime
    }
}

// MARK: - Subscription Plan Model
struct SubscriptionPlan: Identifiable {
    let id: String
    let title: String
    let price: String
    let period: String
    let package: MockPackage
    let isPopular: Bool
    let savings: String?
    
    init(package: MockPackage, isPopular: Bool = false, savings: String? = nil) {
        self.id = package.identifier
        self.package = package
        self.isPopular = isPopular
        self.savings = savings
        
        // Extract title from package
        switch package.packageType {
        case .weekly:
            self.title = "Weekly"
            self.period = "/week"
        case .monthly:
            self.title = "Monthly"
            self.period = "/month"
        case .annual:
            self.title = "Annual"
            self.period = "/year"
        case .lifetime:
            self.title = "Lifetime"
            self.period = "one-time"
        }
        
        // Use mock price
        self.price = package.price
    }
}

// MARK: - Mock RevenueCat Manager
class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()
    
    @Published var isSubscribed = false
    @Published var availablePackages: [SubscriptionPlan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        setupMockData()
    }
    
    // MARK: - Setup Mock Data
    private func setupMockData() {
        // Check current subscription status from UserDefaults
        isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
    }
    
    // MARK: - Fetch Packages (Mock)
    func fetchPackages() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            
            // Create mock packages
            let weeklyPackage = MockPackage(identifier: "weekly_premium", packageType: .weekly, price: "$4.99")
            let annualPackage = MockPackage(identifier: "annual_premium", packageType: .annual, price: "$24.98")
            let lifetimePackage = MockPackage(identifier: "lifetime_premium", packageType: .lifetime, price: "$99.99")
            
            self.availablePackages = [
                SubscriptionPlan(package: weeklyPackage),
                SubscriptionPlan(package: annualPackage, isPopular: true, savings: "Save 60%"),
                SubscriptionPlan(package: lifetimePackage, savings: "Best Value")
            ]
        }
    }
    
    // MARK: - Purchase (Mock)
    func purchase(package: MockPackage) async -> Bool {
        isLoading = true
        
        // Simulate purchase delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.isSubscribed = true
            UserDefaults.standard.set(true, forKey: "isSubscribed")
        }
        
        return true
    }
    
    // MARK: - Restore Purchases (Mock)
    func restorePurchases() async -> Bool {
        isLoading = true
        
        // Simulate restore delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        DispatchQueue.main.async {
            self.isLoading = false
            // Check if user has any previous purchases (mock)
            let hasPreviousPurchase = UserDefaults.standard.bool(forKey: "hasPreviousPurchase")
            self.isSubscribed = hasPreviousPurchase
            UserDefaults.standard.set(hasPreviousPurchase, forKey: "isSubscribed")
        }
        
        return self.isSubscribed
    }
    
    // MARK: - Check Trial Eligibility (Mock)
    func checkTrialEligibility() async -> Bool {
        // Mock: user is eligible for trial
        return true
    }
} 