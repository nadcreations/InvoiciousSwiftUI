import SwiftUI
import Foundation

// MARK: - Modern Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Modern Primary Palette - Premium Deep Blue
        static let primary = Color(red: 0.067, green: 0.176, blue: 0.373)        // #113760 - Professional Navy
        static let primaryLight = Color(red: 0.125, green: 0.278, blue: 0.498)   // #20478F - Lighter Blue
        static let primaryDark = Color(red: 0.035, green: 0.098, blue: 0.212)    // #092036 - Deep Navy
        static let primaryUltraLight = Color(red: 0.97, green: 0.98, blue: 0.995) // #F7FAFF - Ultra Light Blue
        
        // Modern Secondary Palette - Premium Grays
        static let secondary = Color(red: 0.122, green: 0.137, blue: 0.161)      // #1F2329 - Charcoal
        static let secondaryLight = Color(red: 0.196, green: 0.216, blue: 0.247) // #32373F - Light Charcoal
        static let secondaryUltraLight = Color(red: 0.976, green: 0.976, blue: 0.98) // #F9F9FA - Ultra Light Gray
        
        // Premium Accent Colors
        static let accent = Color(red: 0.0, green: 0.694, blue: 0.463)           // #00B176 - Professional Teal
        static let accentLight = Color(red: 0.102, green: 0.773, blue: 0.533)    // #1AC588 - Light Teal
        static let accentGold = Color(red: 0.976, green: 0.722, blue: 0.122)     // #F9B81F - Premium Gold
        static let accentPurple = Color(red: 0.459, green: 0.278, blue: 0.835)   // #7547D5 - Modern Purple
        
        // Modern Status Colors - Enhanced
        static let success = Color(red: 0.067, green: 0.722, blue: 0.388)        // #11B863 - Success Green
        static let successLight = Color(red: 0.925, green: 0.988, blue: 0.945)   // #ECFCF1 - Light Success
        static let warning = Color(red: 0.976, green: 0.631, blue: 0.063)        // #F9A110 - Warning Orange
        static let warningLight = Color(red: 0.996, green: 0.953, blue: 0.886)   // #FEF3E2 - Light Warning
        static let error = Color(red: 0.894, green: 0.255, blue: 0.255)          // #E44141 - Error Red
        static let errorLight = Color(red: 0.992, green: 0.925, blue: 0.925)     // #FDECEC - Light Error
        static let info = Color(red: 0.067, green: 0.557, blue: 0.918)           // #118EEA - Info Blue
        static let infoLight = Color(red: 0.918, green: 0.957, blue: 0.996)      // #EAF4FD - Light Info
        
        // Modern Background System - Enhanced for better card visibility
        static let background = Color(red: 0.98, green: 0.988, blue: 0.996)      // #FAFCFD - Softer Background
        static let backgroundSecondary = Color(red: 0.965, green: 0.976, blue: 0.992) // #F6F9FD - Secondary Background
        static let surface = Color.white                                         // #FFFFFF - Pure White Cards
        static let surfaceSecondary = Color(red: 0.996, green: 0.998, blue: 1.0) // #FEFEFF - Ultra Light Surface
        static let surfaceElevated = Color.white                                 // #FFFFFF - Elevated Surface
        static let cardSurface = Color.white                                     // #FFFFFF - Card Surface
        static let cardSurfaceSecondary = Color(red: 0.996, green: 0.998, blue: 1.0) // #FEFEFF - Secondary Card Surface
        
        // Modern Border System - Refined
        static let border = Color(red: 0.898, green: 0.914, blue: 0.933)         // #E5E9EE - Standard Border
        static let borderLight = Color(red: 0.945, green: 0.957, blue: 0.969)    // #F1F4F7 - Light Border
        static let borderStrong = Color(red: 0.773, green: 0.816, blue: 0.867)   // #C5D0DD - Strong Border
        
        // Professional Text Hierarchy - Enhanced
        static let textPrimary = Color(red: 0.071, green: 0.086, blue: 0.106)    // #121621 - Primary Text
        static let textSecondary = Color(red: 0.384, green: 0.435, blue: 0.494)  // #626F7E - Secondary Text
        static let textTertiary = Color(red: 0.576, green: 0.624, blue: 0.678)   // #939FAD - Tertiary Text
        static let textQuaternary = Color(red: 0.718, green: 0.761, blue: 0.804) // #B7C2CD - Quaternary Text
        static let textInverse = Color.white                                     // #FFFFFF - Inverse Text
        static let textOnPrimary = Color.white                                   // #FFFFFF - Text on Primary
        
        // Invoice Status Colors (Enhanced)
        static let statusDraft = Color(red: 0.6, green: 0.65, blue: 0.7)
        static let statusDraftLight = Color(red: 0.95, green: 0.96, blue: 0.97)
        static let statusSent = info
        static let statusSentLight = infoLight
        static let statusPaid = success
        static let statusPaidLight = successLight
        static let statusOverdue = error
        static let statusOverdueLight = errorLight
        static let statusCancelled = warning
        static let statusCancelledLight = warningLight
        static let statusPartiallyPaid = Color(red: 0.85, green: 0.65, blue: 0.13)
        static let statusPartiallyPaidLight = Color(red: 0.98, green: 0.96, blue: 0.9)
        
        // Premium Gradient Sets
        static let primaryGradient = LinearGradient(
            colors: [primary, primaryLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accentGradient = LinearGradient(
            colors: [accent, accentLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let goldGradient = LinearGradient(
            colors: [accentGold, Color(red: 1.0, green: 0.816, blue: 0.275)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let purpleGradient = LinearGradient(
            colors: [accentPurple, Color(red: 0.569, green: 0.376, blue: 0.922)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let neutralGradient = LinearGradient(
            colors: [surface, surfaceSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let premiumGradient = LinearGradient(
            colors: [primary, accentPurple, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Premium Typography System
    struct Typography {
        // Display Typography - Premium Headlines
        static let display1 = Font.system(size: 42, weight: .black, design: .default)      // Hero text
        static let display2 = Font.system(size: 36, weight: .heavy, design: .default)      // Large displays
        
        // Title Typography - Modern & Bold
        static let title1 = Font.system(size: 32, weight: .bold, design: .default)         // Main titles
        static let title2 = Font.system(size: 28, weight: .bold, design: .default)         // Section titles
        static let title3 = Font.system(size: 24, weight: .semibold, design: .default)     // Subsection titles
        
        // Heading Typography - Professional
        static let heading1 = Font.system(size: 22, weight: .semibold, design: .default)   // Large headings
        static let heading2 = Font.system(size: 20, weight: .semibold, design: .default)   // Medium headings
        static let heading3 = Font.system(size: 18, weight: .medium, design: .default)     // Small headings
        
        // Body Typography - Readable & Clean
        static let body1 = Font.system(size: 17, weight: .regular, design: .default)       // Primary body text
        static let body2 = Font.system(size: 16, weight: .regular, design: .default)       // Secondary body text
        static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)   // Emphasized body
        static let bodySemiBold = Font.system(size: 16, weight: .semibold, design: .default) // Strong body
        
        // Label Typography - Interface Elements
        static let label1 = Font.system(size: 15, weight: .medium, design: .default)       // Large labels
        static let label2 = Font.system(size: 14, weight: .medium, design: .default)       // Standard labels
        static let label3 = Font.system(size: 13, weight: .medium, design: .default)       // Small labels
        
        // Caption Typography - Supporting Text
        static let caption1 = Font.system(size: 12, weight: .medium, design: .default)     // Primary captions
        static let caption2 = Font.system(size: 11, weight: .medium, design: .default)     // Secondary captions
        static let caption3 = Font.system(size: 10, weight: .medium, design: .default)     // Micro text
        
        // Financial Typography - Rounded Design for Numbers
        static let currencyHero = Font.system(size: 36, weight: .bold, design: .rounded)   // Hero currency
        static let currencyLarge = Font.system(size: 28, weight: .bold, design: .rounded)  // Large amounts
        static let currencyMedium = Font.system(size: 20, weight: .bold, design: .rounded) // Standard amounts
        static let currencySmall = Font.system(size: 16, weight: .semibold, design: .rounded) // Small amounts
        static let currencyCaption = Font.system(size: 12, weight: .medium, design: .rounded) // Tiny amounts
        
        // Professional Interface Typography
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)   // Interface headlines
        static let subheadline = Font.system(size: 15, weight: .medium, design: .default)  // Interface subheads
        static let callout = Font.system(size: 16, weight: .regular, design: .default)     // Callout text
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)    // Footnote text
        
        // Premium Specialty Typography
        static let monospace = Font.system(size: 14, weight: .medium, design: .monospaced) // Code/data
        static let serif = Font.system(size: 16, weight: .regular, design: .serif)         // Elegant text
    }
    
    // MARK: - Modern Spacing System
    struct Spacing {
        static let xs: CGFloat = 4      // Extra Small
        static let sm: CGFloat = 8      // Small
        static let md: CGFloat = 12     // Medium
        static let lg: CGFloat = 16     // Large
        static let xl: CGFloat = 20     // Extra Large
        static let xxl: CGFloat = 24    // Extra Extra Large
        static let xxxl: CGFloat = 32   // Triple Extra Large
        static let huge: CGFloat = 40   // Huge
        static let massive: CGFloat = 48 // Massive
        
        // Semantic Spacing
        static let cardPadding: CGFloat = lg
        static let screenPadding: CGFloat = lg
        static let sectionSpacing: CGFloat = xxl
        static let elementSpacing: CGFloat = md
    }
    
    // MARK: - Modern Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let xxxl: CGFloat = 24
        static let circular: CGFloat = 50
        
        // Semantic Radius
        static let card: CGFloat = lg
        static let button: CGFloat = md
        static let input: CGFloat = md
        static let badge: CGFloat = xxxl
    }
    
    // MARK: - Premium Shadow System
    struct Shadows {
        static let none = (color: Color.clear, radius: CGFloat(0), x: CGFloat(0), y: CGFloat(0))
        
        // Subtle Depth Shadows
        static let xs = (
            color: Color.black.opacity(0.02),
            radius: CGFloat(1),
            x: CGFloat(0),
            y: CGFloat(0.5)
        )
        
        static let sm = (
            color: Color.black.opacity(0.04),
            radius: CGFloat(3),
            x: CGFloat(0),
            y: CGFloat(1)
        )
        
        static let md = (
            color: Color.black.opacity(0.06),
            radius: CGFloat(6),
            x: CGFloat(0),
            y: CGFloat(2)
        )
        
        static let lg = (
            color: Color.black.opacity(0.08),
            radius: CGFloat(12),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        
        static let xl = (
            color: Color.black.opacity(0.1),
            radius: CGFloat(20),
            x: CGFloat(0),
            y: CGFloat(8)
        )
        
        static let xxl = (
            color: Color.black.opacity(0.12),
            radius: CGFloat(30),
            x: CGFloat(0),
            y: CGFloat(15)
        )
        
        // Professional Application Shadows
        static let card = sm
        static let cardElevated = md
        static let cardHover = lg
        static let modal = xl
        static let premium = xxl
        
        // Colored Shadows for Premium Feel
        static let primaryShadow = (
            color: Colors.primary.opacity(0.15),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        
        static let accentShadow = (
            color: Colors.accent.opacity(0.15),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
    }
    
    // MARK: - Animation System
    struct Animations {
        // Timing
        static let fast: TimeInterval = 0.2
        static let medium: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let verySlow: TimeInterval = 0.8
        
        // Curves
        static let easeOut = Animation.easeOut(duration: medium)
        static let easeIn = Animation.easeIn(duration: medium)
        static let easeInOut = Animation.easeInOut(duration: medium)
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
        
        // Specialized Animations
        static let cardAppear = Animation.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)
        static let buttonPress = Animation.easeInOut(duration: 0.1)
        static let iconRotation = Animation.easeInOut(duration: 0.3)
        static let shimmer = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
    }
    
    // MARK: - Icon System
    struct Icons {
        // Navigation Icons
        static let dashboard = "house.fill"
        static let invoices = "doc.text.fill"
        static let clients = "person.2.fill"
        static let settings = "gearshape.fill"
        static let reports = "chart.bar.doc.horizontal.fill"
        
        // Action Icons
        static let add = "plus.circle.fill"
        static let edit = "pencil.circle.fill"
        static let delete = "trash.circle.fill"
        static let share = "square.and.arrow.up.fill"
        static let download = "arrow.down.circle.fill"
        
        // Status Icons
        static let success = "checkmark.circle.fill"
        static let warning = "exclamationmark.triangle.fill"
        static let error = "xmark.circle.fill"
        static let info = "info.circle.fill"
        
        // Financial Icons
        static let currency = "dollarsign.circle.fill"
        static let payment = "creditcard.fill"
        static let revenue = "chart.line.uptrend.xyaxis"
        static let expense = "chart.line.downtrend.xyaxis"
        
        // Business Icons
        static let business = "building.2.fill"
        static let email = "envelope.fill"
        static let phone = "phone.fill"
        static let website = "globe"
    }
}

// MARK: - Premium View Modifiers
extension View {
    // Modern Card Style with Enhanced Visual Separation
    func modernCard(elevation: Int = 1) -> some View {
        let shadowColor = elevation == 0 ? Color.clear :
                         elevation == 1 ? Color.black.opacity(0.08) :
                         elevation == 2 ? Color.black.opacity(0.12) :
                         elevation == 3 ? Color.black.opacity(0.16) : Color.black.opacity(0.2)
        
        let shadowRadius: CGFloat = elevation == 0 ? 0 :
                                  elevation == 1 ? 8 :
                                  elevation == 2 ? 12 :
                                  elevation == 3 ? 16 : 24
        
        let shadowY: CGFloat = elevation == 0 ? 0 :
                              elevation == 1 ? 2 :
                              elevation == 2 ? 4 :
                              elevation == 3 ? 8 : 12
        
        return self
            .background(DesignSystem.Colors.cardSurface)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }
    
    // Premium Card with Colored Shadow and Enhanced Styling
    func premiumCard(shadowColor: Color = DesignSystem.Colors.primary, elevation: Int = 1) -> some View {
        let shadowOpacity: Double = elevation == 1 ? 0.12 : elevation == 2 ? 0.16 : 0.2
        let shadowRadius: CGFloat = elevation == 1 ? 10 : elevation == 2 ? 16 : 24
        let shadowY: CGFloat = elevation == 1 ? 3 : elevation == 2 ? 6 : 10
        
        return self
            .background(DesignSystem.Colors.cardSurface)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(
                color: shadowColor.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }
    
    // Ultra Modern Card Style - Sleek and Premium
    func sleekCard(elevation: Int = 1) -> some View {
        self
            .background(DesignSystem.Colors.cardSurface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.06),
                radius: elevation == 1 ? 6 : elevation == 2 ? 12 : 20,
                x: 0,
                y: elevation == 1 ? 2 : elevation == 2 ? 4 : 8
            )
            .shadow(
                color: DesignSystem.Colors.primary.opacity(0.04),
                radius: elevation == 1 ? 12 : elevation == 2 ? 20 : 32,
                x: 0,
                y: elevation == 1 ? 4 : elevation == 2 ? 8 : 16
            )
    }
    
    // Professional Button Style
    func professionalButton(style: ProfessionalButtonStyle = .primary, size: ProfessionalButtonSize = .medium) -> some View {
        self
            .buttonStyle(PlainButtonStyle())
            .modifier(ProfessionalButtonModifier(style: style, size: size))
    }
    
    // Animated Scale Effect
    func animatedScale(_ scale: CGFloat = 0.95, duration: TimeInterval = 0.1) -> some View {
        self.scaleEffect(scale)
            .animation(.easeInOut(duration: duration), value: scale)
    }
    
    // Shimmer Effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
    
    // Gradient Background
    func gradientBackground(_ gradient: LinearGradient) -> some View {
        self.background(gradient)
    }
}

// MARK: - Premium Button System
enum ProfessionalButtonStyle {
    case primary        // Primary brand button
    case secondary      // Secondary button
    case outline        // Outlined button
    case ghost          // Ghost/transparent button
    case destructive    // Destructive action
    case success        // Success/positive action
    case premium        // Premium gradient button
    case accent         // Accent color button
    case minimal        // Minimal style button
}

enum ProfessionalButtonSize {
    case tiny, small, medium, large
}

struct ProfessionalButtonModifier: ViewModifier {
    let style: ProfessionalButtonStyle
    let size: ProfessionalButtonSize
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .font(buttonFont)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minWidth: 80, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
                    .fill(backgroundColor)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
    }
    
    private var buttonFont: Font {
        switch size {
        case .tiny: return DesignSystem.Typography.caption2
        case .small: return DesignSystem.Typography.caption1
        case .medium: return DesignSystem.Typography.label2
        case .large: return DesignSystem.Typography.headline
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .tiny: return DesignSystem.Spacing.xs
        case .small: return DesignSystem.Spacing.sm
        case .medium: return DesignSystem.Spacing.md
        case .large: return DesignSystem.Spacing.lg
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .tiny: return 2
        case .small: return DesignSystem.Spacing.xs
        case .medium: return DesignSystem.Spacing.xs + 2
        case .large: return DesignSystem.Spacing.sm
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return DesignSystem.Colors.primary
        case .secondary: return DesignSystem.Colors.secondary
        case .outline: return DesignSystem.Colors.primary  // Make outline buttons solid too
        case .ghost: return DesignSystem.Colors.secondary  // Make ghost buttons solid
        case .destructive: return DesignSystem.Colors.error
        case .success: return DesignSystem.Colors.success
        case .premium: return DesignSystem.Colors.primary
        case .accent: return DesignSystem.Colors.accent
        case .minimal: return DesignSystem.Colors.secondary
        }
    }
    
    private var textColor: Color {
        // All buttons now have solid backgrounds, so all text should be white
        return DesignSystem.Colors.textOnPrimary
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(DesignSystem.Animations.shimmer) {
                    phase = 300
                }
            }
    }
}

// MARK: - Animated Icons
struct AnimatedIcon: View {
    let iconName: String
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
    }
}

// MARK: - Number Formatting Extensions
extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.currencyGroupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var decimalFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
    
    var percentFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0%"
    }
    
    var accountingFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.currencyGroupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

extension Int {
    var decimalFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// MARK: - Premium UI Components

struct PremiumCard<Content: View>: View {
    let content: Content
    let elevation: Int
    let cornerRadius: CGFloat
    
    init(elevation: Int = 1, cornerRadius: CGFloat = DesignSystem.CornerRadius.card, @ViewBuilder content: () -> Content) {
        self.elevation = elevation
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(DesignSystem.Colors.surface)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }
    
    private var shadowColor: Color {
        Color.black.opacity(shadowOpacity)
    }
    
    private var shadowOpacity: Double {
        switch elevation {
        case 0: return 0.0
        case 1: return 0.04
        case 2: return 0.06
        case 3: return 0.08
        default: return 0.12
        }
    }
    
    private var shadowRadius: CGFloat {
        switch elevation {
        case 0: return 0
        case 1: return 3
        case 2: return 6
        case 3: return 12
        default: return 20
        }
    }
    
    private var shadowY: CGFloat {
        switch elevation {
        case 0: return 0
        case 1: return 1
        case 2: return 2
        case 3: return 4
        default: return 8
        }
    }
}

struct PremiumDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.borderLight.opacity(0),
                        DesignSystem.Colors.borderLight,
                        DesignSystem.Colors.borderLight.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}