import SwiftUI
import RevenueCat

// MARK: - Paywall View
struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primary.opacity(0.1),
                        DesignSystem.Colors.primaryLight.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {

                        // Header
                        PaywallHeaderView()

                        // Features List
                        PaywallFeaturesView()

                        // Pricing Plans
                        if let currentOffering = subscriptionManager.currentOfferings?.current {
                            PaywallPricingView(
                                offering: currentOffering,
                                selectedPackage: $selectedPackage
                            )
                        }

                        // Purchase Button
                        PaywallPurchaseButton(
                            selectedPackage: selectedPackage,
                            subscriptionManager: subscriptionManager,
                            showFreeTrial: selectedPackage?.identifier.contains("weekly") == true
                        )

                        // Restore & Terms
                        PaywallFooterView(subscriptionManager: subscriptionManager)

                        Spacer(minLength: DesignSystem.Spacing.xxxl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                }
            }
            .navigationTitle("Upgrade to Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            subscriptionManager.loadOfferings()
        }
    }
}

// MARK: - Paywall Header
struct PaywallHeaderView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryGradient)
                    .frame(width: 120, height: 120)

                Image(systemName: "crown.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Unlock Premium Features")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Take your invoicing to the next level with professional features")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
}

// MARK: - Features List
struct PaywallFeaturesView: View {
    let features = SubscriptionManager.shared.premiumFeatures

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Premium Features")
                .font(DesignSystem.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(features, id: \.self) { feature in
                    PaywallFeatureRow(feature: feature)
                }
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - Feature Row
struct PaywallFeatureRow: View {
    let feature: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.success)

            Text(feature)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
    }
}

// MARK: - Pricing View
struct PaywallPricingView: View {
    let offering: Offering
    @Binding var selectedPackage: Package?
    @State private var showFreeTrial = true

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Choose Your Plan")
                .font(DesignSystem.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(offering.availablePackages, id: \.identifier) { package in
                    PaywallPricingCard(
                        package: package,
                        isSelected: selectedPackage?.identifier == package.identifier,
                        showFreeTrial: showFreeTrial && package.identifier.contains("weekly")
                    ) {
                        selectedPackage = package
                        // Update trial visibility based on selection
                        showFreeTrial = !package.identifier.contains("yearly")
                    }
                }
            }
        }
        .onAppear {
            // Auto-select weekly with free trial by default
            if selectedPackage == nil {
                if let weeklyPackage = offering.availablePackages.first(where: { $0.identifier.contains("weekly") }) {
                    selectedPackage = weeklyPackage
                }
            }
        }
    }
}

// MARK: - Pricing Card
struct PaywallPricingCard: View {
    let package: Package
    let isSelected: Bool
    let showFreeTrial: Bool
    let onTap: () -> Void

    private var isPopular: Bool {
        package.identifier.contains("yearly")
    }

    private var savings: String? {
        if package.identifier.contains("yearly") {
            return "Save 60%"
        }
        return nil
    }

    private var hasFreeTrial: Bool {
        package.identifier.contains("weekly") && showFreeTrial
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Free Trial Badge (if applicable)
                if hasFreeTrial {
                    HStack {
                        Text("3-Day Free Trial")
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.primary)
                            .cornerRadius(DesignSystem.CornerRadius.sm)

                        Spacer()
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.storeProduct.localizedTitle)
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        if hasFreeTrial {
                            Text("Free for 3 days, then \(package.storeProduct.localizedPriceString)/week")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        } else {
                            Text(package.storeProduct.localizedDescription)
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        if hasFreeTrial {
                            Text("FREE")
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.success)

                            Text("3 days")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        } else {
                            Text(package.storeProduct.localizedPriceString)
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primary)

                            if let period = package.storeProduct.subscriptionPeriod {
                                let periodString = period.unit == .month ? "month" : period.unit == .year ? "year" : "week"
                                Text("per \(periodString)")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }
                }

                if let savings = savings {
                    HStack {
                        Text(savings)
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.success)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.successLight)
                            .cornerRadius(DesignSystem.CornerRadius.sm)

                        Spacer()
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(isSelected ? DesignSystem.Colors.primaryUltraLight : DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(
                        isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Purchase Button
struct PaywallPurchaseButton: View {
    let selectedPackage: Package?
    let subscriptionManager: SubscriptionManager
    let showFreeTrial: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: purchaseSelected) {
            HStack {
                if subscriptionManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }

                Text(buttonText)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                selectedPackage != nil ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .disabled(selectedPackage == nil || subscriptionManager.isLoading)
    }

    private var hasFreeTrial: Bool {
        guard let package = selectedPackage else { return false }
        return package.identifier.contains("weekly") && showFreeTrial
    }

    private var buttonText: String {
        if subscriptionManager.isLoading {
            return "Processing..."
        } else if let package = selectedPackage {
            if hasFreeTrial {
                return "Start 3-Day Free Trial"
            } else {
                return "Subscribe for \(package.storeProduct.localizedPriceString)"
            }
        } else {
            return "Select a Plan"
        }
    }

    private func purchaseSelected() {
        guard let package = selectedPackage else { return }

        Task {
            do {
                let success = try await subscriptionManager.purchaseProduct(package)
                if success {
                    // Dismiss paywall on successful purchase
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
}

// MARK: - Footer
struct PaywallFooterView: View {
    let subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button("Restore Purchases") {
                subscriptionManager.restorePurchases()
            }
            .font(DesignSystem.Typography.callout)
            .foregroundColor(DesignSystem.Colors.primary)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)

                Text("Cancel anytime. Subscriptions auto-renew.")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    PaywallView()
}