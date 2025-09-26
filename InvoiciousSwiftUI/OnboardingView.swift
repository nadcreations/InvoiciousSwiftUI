import SwiftUI

// MARK: - Onboarding Models
struct OnboardingPage {
    let id = UUID()
    let title: String
    let headline: String
    let description: String
    let benefit: String
    let imageName: String
    let backgroundColor: LinearGradient
    let textColor: Color
}

// MARK: - Onboarding Content
struct OnboardingContent {
    static let pages = [
        OnboardingPage(
            title: "Welcome to Invoicious",
            headline: "Get Paid Faster",
            description: "Stop waiting 60+ days for payments. Professional invoices that get results and help you maintain healthy cash flow.",
            benefit: "Average users get paid 40% faster",
            imageName: "AppLogo",
            backgroundColor: LinearGradient(
                colors: [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.1, green: 0.4, blue: 0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            textColor: .white
        ),

        OnboardingPage(
            title: "Effortless Organization",
            headline: "Stay in Control",
            description: "Never lose track of who owes you money. Automatic reminders and smart organization keep your business running smoothly.",
            benefit: "Reduce late payments by 65%",
            imageName: "chart.line.uptrend.xyaxis",
            backgroundColor: LinearGradient(
                colors: [Color(red: 0.3, green: 0.8, blue: 0.5), Color(red: 0.2, green: 0.6, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            textColor: .white
        ),

        OnboardingPage(
            title: "Professional Impact",
            headline: "Look Like a Pro",
            description: "Beautiful, branded invoices that make the right impression. Your clients will take you seriously from day one.",
            benefit: "Increase client trust & retention",
            imageName: "star.circle.fill",
            backgroundColor: LinearGradient(
                colors: [Color(red: 0.9, green: 0.5, blue: 0.2), Color(red: 0.8, green: 0.3, blue: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            textColor: .white
        ),

        OnboardingPage(
            title: "Save Precious Time",
            headline: "More Time for What Matters",
            description: "Automate the boring stuff. Spend less time on paperwork and more time growing your business and serving clients.",
            benefit: "Save 5+ hours per week",
            imageName: "clock.arrow.circlepath",
            backgroundColor: LinearGradient(
                colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.2, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            textColor: .white
        )
    ]
}

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateContent = false
    @Environment(\.dismiss) private var dismiss

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background
            OnboardingContent.pages[currentPage].backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: currentPage)

            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    if currentPage < OnboardingContent.pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                }

                Spacer()

                // Content
                OnboardingPageView(
                    page: OnboardingContent.pages[currentPage],
                    animate: animateContent
                )

                Spacer()

                // Bottom Navigation
                VStack(spacing: 30) {
                    // Page Indicators
                    HStack(spacing: 12) {
                        ForEach(0..<OnboardingContent.pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Navigation Buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button(action: previousPage) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                            }
                        } else {
                            Spacer()
                        }

                        Spacer()

                        Button(action: nextPage) {
                            HStack(spacing: 8) {
                                Text(currentPage == OnboardingContent.pages.count - 1 ? "Get Started" : "Next")
                                    .font(.system(size: 18, weight: .semibold))
                                if currentPage < OnboardingContent.pages.count - 1 {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .scaleEffect(currentPage == OnboardingContent.pages.count - 1 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: currentPage)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            animateContent = true
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.x > 50 && currentPage > 0 {
                        previousPage()
                    } else if value.translation.x < -50 && currentPage < OnboardingContent.pages.count - 1 {
                        nextPage()
                    }
                }
        )
    }

    private func nextPage() {
        if currentPage < OnboardingContent.pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage -= 1
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onComplete()
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let animate: Bool

    var body: some View {
        VStack(spacing: 40) {
            // Icon with Animation
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1.0 : 0.0)

                if page.imageName == "AppLogo" {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .scaleEffect(animate ? 1.0 : 0.5)
                        .opacity(animate ? 1.0 : 0.0)
                } else {
                    Image(systemName: page.imageName)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1.0 : 0.5)
                        .opacity(animate ? 1.0 : 0.0)
                }
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animate)

            // Text Content
            VStack(spacing: 24) {
                // Main Headline
                Text(page.headline)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animate)

                // Description
                Text(page.description)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animate)

                // Benefit Badge
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)

                    Text(page.benefit)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .scaleEffect(animate ? 1.0 : 0.8)
                .opacity(animate ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: animate)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Onboarding Wrapper for App Integration
struct OnboardingWrapper: View {
    @State private var showOnboarding = true
    let content: AnyView

    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    var body: some View {
        Group {
            if showOnboarding && !hasCompletedOnboarding {
                OnboardingView {
                    showOnboarding = false
                }
            } else {
                content
            }
        }
    }

    private var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Preview
#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}