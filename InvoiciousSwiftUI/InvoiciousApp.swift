import SwiftUI
import FirebaseCore
import RevenueCat

@main
struct InvoiciousApp: App {
    @State private var showOnboarding = true // Always show onboarding for testing

    init() {
        FirebaseApp.configure()

        // Configure RevenueCat
        // TODO: Replace with your actual RevenueCat API key
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_HJyNpkbGDNRzHjzAAycneTsSGHG")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView {
                        showOnboarding = false
                    }
                } else {
                    ContentViewWithAuth()
                }
            }
        }
    }
}
