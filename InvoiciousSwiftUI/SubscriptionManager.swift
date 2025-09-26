import Foundation
import RevenueCat
import SwiftUI

// MARK: - Subscription Manager
@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isSubscribed = false
    @Published var currentOfferings: Offerings?
    @Published var isLoading = false
    @Published var errorMessage = ""

    // Product identifiers
    static let weeklyProductID = "com.invoicious.inv.weekly"
    static let yearlyProductID = "com.invoicious.inv.yearly"

    // Entitlement identifier
    static let premiumEntitlementID = "premium"

    override init() {
        super.init()

        // Set delegate and check current subscription status
        Purchases.shared.delegate = self
        checkSubscriptionStatus()
        loadOfferings()
    }

    // MARK: - Check Subscription Status
    func checkSubscriptionStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await MainActor.run {
                    self.isSubscribed = customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true
                }
                print("✅ Subscription Status: \(isSubscribed ? "Active" : "Inactive")")
            } catch {
                print("❌ Error checking subscription status: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Force Refresh Subscription Status
    func refreshSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.isSubscribed = customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true
            }
            print("✅ Subscription Status Refreshed: \(isSubscribed ? "Active" : "Inactive")")
        } catch {
            print("❌ Error refreshing subscription status: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Load Offerings
    func loadOfferings() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = ""
            }

            do {
                let offerings = try await Purchases.shared.offerings()
                await MainActor.run {
                    self.currentOfferings = offerings
                    self.isLoading = false
                }
                print("✅ Loaded \(offerings.all.count) offerings")
            } catch {
                print("❌ Error loading offerings: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Purchase Product
    func purchaseProduct(_ package: Package) async throws -> Bool {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            let isActive = result.customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true

            await MainActor.run {
                self.isSubscribed = isActive
                self.isLoading = false
            }

            // Force refresh to ensure all UI updates
            await refreshSubscriptionStatus()

            print("✅ Purchase successful: \(isActive)")
            return isActive

        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = ""
            }

            do {
                let customerInfo = try await Purchases.shared.restorePurchases()
                await MainActor.run {
                    self.isSubscribed = customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true
                    self.isLoading = false
                }
                print("✅ Restore successful: \(isSubscribed)")
            } catch {
                print("❌ Restore failed: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Get Premium Features
    var premiumFeatures: [String] {
        return [
            "Unlimited Invoices",
            "Advanced Templates",
            "Automatic Backups",
            "Priority Customer Support",
            "Advanced Analytics",
            "Custom Branding",
            "Time Tracking",
            "Recurring Invoices"
        ]
    }

    // MARK: - Check Feature Access
    func hasAccess(to feature: PremiumFeature) -> Bool {
        return isSubscribed
    }
}

// MARK: - Premium Features Enum
enum PremiumFeature {
    case unlimitedInvoices
    case advancedTemplates
    case automaticBackups
    case prioritySupport
    case advancedAnalytics
    case customBranding
    case timeTracking
    case recurringInvoices
}

// MARK: - RevenueCat Delegate
extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.isSubscribed = customerInfo.entitlements[Self.premiumEntitlementID]?.isActive == true
        }
    }
}