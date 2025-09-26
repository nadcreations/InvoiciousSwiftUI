import Foundation
import SwiftUI

struct Client: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var phone: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var createdDate: Date
    
    init(name: String = "", email: String = "", phone: String = "", address: String = "", city: String = "", state: String = "", zipCode: String = "", country: String = "") {
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.createdDate = Date()
    }
}

struct LineItem: Identifiable, Codable {
    let id = UUID()
    var description: String
    var quantity: Double
    var unitPrice: Double
    
    var total: Double {
        quantity * unitPrice
    }
    
    init(description: String = "", quantity: Double = 1.0, unitPrice: Double = 0.0) {
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

// MARK: - Estimate Status
enum EstimateStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case sent = "Sent"
    case accepted = "Accepted"
    case declined = "Declined"
    case expired = "Expired"
    
    var color: Color {
        switch self {
        case .draft: return DesignSystem.Colors.statusDraft
        case .sent: return DesignSystem.Colors.statusSent
        case .accepted: return DesignSystem.Colors.statusPaid
        case .declined: return DesignSystem.Colors.statusCancelled
        case .expired: return DesignSystem.Colors.statusOverdue
        }
    }
}

enum InvoiceStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case sent = "Sent"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    case partiallyPaid = "Partially Paid"
    
    var color: Color {
        switch self {
        case .draft:
            return .gray
        case .sent:
            return .blue
        case .paid:
            return .green
        case .overdue:
            return .red
        case .cancelled:
            return .orange
        case .partiallyPaid:
            return .yellow
        }
    }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case check = "Check"
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case paypal = "PayPal"
    case other = "Other"
}

struct Payment: Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var paymentDate: Date
    var paymentMethod: PaymentMethod
    var reference: String
    var notes: String
    
    init(amount: Double, paymentMethod: PaymentMethod, reference: String = "", notes: String = "") {
        self.amount = amount
        self.paymentDate = Date()
        self.paymentMethod = paymentMethod
        self.reference = reference
        self.notes = notes
    }
}

// MARK: - Estimate Data Model
struct Estimate: Identifiable, Codable {
    let id = UUID()
    var estimateNumber: String
    var client: Client
    var lineItems: [LineItem]
    var taxRate: Double
    var validUntil: Date
    var status: EstimateStatus
    var notes: String
    var createdDate: Date
    var issueDate: Date
    
    // Computed properties
    var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }
    
    var taxAmount: Double {
        subtotal * taxRate
    }
    
    var total: Double {
        subtotal + taxAmount
    }
    
    var isExpired: Bool {
        Date() > validUntil
    }
    
    var effectiveStatus: EstimateStatus {
        if isExpired && status != .accepted && status != .declined {
            return .expired
        }
        return status
    }
    
    init(client: Client = Client(), notes: String = "") {
        self.estimateNumber = "EST-\(Int(Date().timeIntervalSince1970))"
        self.client = client
        self.lineItems = []
        self.taxRate = 0.0
        self.validUntil = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        self.status = .draft
        self.notes = notes
        self.createdDate = Date()
        self.issueDate = Date()
    }
    
    // MARK: - One-Click Conversion to Invoice
    func convertToInvoice() -> Invoice {
        var invoice = Invoice(client: self.client, notes: self.notes)
        invoice.lineItems = self.lineItems
        invoice.taxRate = self.taxRate
        invoice.status = .draft
        // Set due date to 30 days from now by default
        invoice.dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return invoice
    }
}

struct Invoice: Identifiable, Codable {
    let id = UUID()
    var invoiceNumber: String
    var client: Client
    var issueDate: Date
    var dueDate: Date
    var lineItems: [LineItem]
    var notes: String
    var status: InvoiceStatus
    var createdDate: Date
    var payments: [Payment]
    var taxRate: Double = 0.10
    var selectedTemplate: String = "Classic" // Store template as string for backward compatibility
    
    // MARK: - Invoice Tracking & Communication
    var sentDate: Date?
    var lastViewedDate: Date?
    var viewCount: Int = 0
    var downloadCount: Int = 0
    var emailsSent: [InvoiceEmailRecord] = []
    var trackingEnabled: Bool = true
    
    var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }
    
    var taxAmount: Double {
        subtotal * taxRate
    }
    
    var total: Double {
        subtotal + taxAmount
    }
    
    var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBalance: Double {
        total - totalPaid
    }
    
    var isFullyPaid: Bool {
        remainingBalance <= 0
    }
    
    var isPartiallyPaid: Bool {
        totalPaid > 0 && totalPaid < total
    }
    
    var isOverdue: Bool {
        status == .sent && dueDate < Date() && !isFullyPaid
    }
    
    var template: InvoiceTemplate {
        get {
            return InvoiceTemplate(rawValue: selectedTemplate) ?? .classic
        }
        set {
            selectedTemplate = newValue.rawValue
        }
    }
    
    var effectiveStatus: InvoiceStatus {
        if isFullyPaid {
            return .paid
        } else if isPartiallyPaid {
            return .partiallyPaid
        } else if isOverdue {
            return .overdue
        } else {
            return status
        }
    }
    
    init(client: Client = Client(), notes: String = "") {
        self.invoiceNumber = "INV-\(Int(Date().timeIntervalSince1970))"
        self.client = client
        self.issueDate = Date()
        self.dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        self.lineItems = [LineItem()]
        self.notes = notes
        self.status = .draft
        self.createdDate = Date()
        self.payments = []
        // Initialize tracking fields
        self.sentDate = nil
        self.lastViewedDate = nil
        self.viewCount = 0
        self.downloadCount = 0
        self.emailsSent = []
        self.trackingEnabled = true
    }
}

// MARK: - Invoice Email Tracking
struct InvoiceEmailRecord: Identifiable, Codable {
    let id = UUID()
    var sentDate: Date
    var recipientEmail: String
    var subject: String
    var deliveryStatus: EmailDeliveryStatus
    var openedDate: Date?
    var downloadedDate: Date?
    var trackingId: String
    
    init(recipientEmail: String, subject: String) {
        self.sentDate = Date()
        self.recipientEmail = recipientEmail
        self.subject = subject
        self.deliveryStatus = .sending
        self.trackingId = UUID().uuidString
    }
}

enum EmailDeliveryStatus: String, CaseIterable, Codable {
    case sending = "Sending"
    case delivered = "Delivered"
    case opened = "Opened"
    case failed = "Failed"
    case bounced = "Bounced"
    
    var color: Color {
        switch self {
        case .sending: return DesignSystem.Colors.warning
        case .delivered: return DesignSystem.Colors.primary
        case .opened: return DesignSystem.Colors.success
        case .failed, .bounced: return DesignSystem.Colors.error
        }
    }
    
    var icon: String {
        switch self {
        case .sending: return "paperplane"
        case .delivered: return "checkmark.circle"
        case .opened: return "envelope.open"
        case .failed: return "exclamationmark.triangle"
        case .bounced: return "arrow.uturn.left"
        }
    }
}

enum RecurrenceFrequency: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiannually = "Semi-annually"
    case annually = "Annually"
    
    var dayInterval: Int {
        switch self {
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .quarterly: return 90
        case .semiannually: return 180
        case .annually: return 365
        }
    }
}

struct TimeEntry: Identifiable, Codable, Hashable {
    let id = UUID()
    var description: String
    var startTime: Date
    var endTime: Date?
    var hourlyRate: Double
    var isRunning: Bool
    var projectName: String
    var clientId: UUID?
    var createdDate: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TimeEntry, rhs: TimeEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    var duration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        } else if isRunning {
            return Date().timeIntervalSince(startTime)
        }
        return 0
    }
    
    var hours: Double {
        duration / 3600.0 // Convert seconds to hours
    }
    
    var total: Double {
        hours * hourlyRate
    }
    
    init(description: String = "", hourlyRate: Double = 0, projectName: String = "", clientId: UUID? = nil) {
        self.description = description
        self.startTime = Date()
        self.endTime = nil
        self.hourlyRate = hourlyRate
        self.isRunning = false
        self.projectName = projectName
        self.clientId = clientId
        self.createdDate = Date()
    }
}

struct RecurringInvoice: Identifiable, Codable {
    let id = UUID()
    var templateInvoice: Invoice
    var frequency: RecurrenceFrequency
    var nextDueDate: Date
    var isActive: Bool
    var endDate: Date?
    var createdDate: Date
    var lastGeneratedDate: Date?
    var generatedInvoiceIds: [UUID]
    
    init(templateInvoice: Invoice, frequency: RecurrenceFrequency) {
        self.templateInvoice = templateInvoice
        self.frequency = frequency
        self.nextDueDate = Calendar.current.date(byAdding: .day, value: frequency.dayInterval, to: Date()) ?? Date()
        self.isActive = true
        self.endDate = nil
        self.createdDate = Date()
        self.lastGeneratedDate = nil
        self.generatedInvoiceIds = []
    }
}

struct Project: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var clientId: UUID?
    var defaultHourlyRate: Double
    var isActive: Bool
    var createdDate: Date
    var timeEntries: [TimeEntry]
    
    var totalHours: Double {
        timeEntries.reduce(0) { $0 + $1.hours }
    }
    
    var totalValue: Double {
        timeEntries.reduce(0) { $0 + $1.total }
    }
    
    init(name: String, description: String = "", clientId: UUID? = nil, defaultHourlyRate: Double = 0) {
        self.name = name
        self.description = description
        self.clientId = clientId
        self.defaultHourlyRate = defaultHourlyRate
        self.isActive = true
        self.createdDate = Date()
        self.timeEntries = []
    }
}

struct BusinessInfo: Codable {
    var name: String
    var email: String
    var phone: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var website: String
    var logo: String?
    var defaultHourlyRate: Double
    var defaultCurrency: String
    var taxNumber: String
    
    init() {
        self.name = ""
        self.email = ""
        self.phone = ""
        self.address = ""
        self.city = ""
        self.state = ""
        self.zipCode = ""
        self.country = ""
        self.website = ""
        self.logo = nil
        self.defaultHourlyRate = 75.0
        self.defaultCurrency = "USD"
        self.taxNumber = ""
    }
}

// MARK: - Tracking Time Range
enum TrackingTimeRange: String, CaseIterable, Identifiable {
    case last24Hours = "last24Hours"
    case last7Days = "last7Days"
    case last30Days = "last30Days"
    case allTime = "allTime"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .last24Hours: return "24H"
        case .last7Days: return "7D"
        case .last30Days: return "30D"
        case .allTime: return "All"
        }
    }
}

// MARK: - Shared UI Components
struct ModernStatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)

            VStack(spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)

                Text(value)
                    .font(DesignSystem.Typography.label2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

struct ModernFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.semibold)
                
                Text("\(count.decimalFormatted)")
                    .font(DesignSystem.Typography.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(
                        isSelected ? DesignSystem.Colors.textInverse.opacity(0.2) : color.opacity(0.1)
                    )
                    .cornerRadius(8)
            }
            .foregroundColor(isSelected ? DesignSystem.Colors.textInverse : color)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? color : DesignSystem.Colors.surface
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.badge)
                    .stroke(color.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
            .cornerRadius(DesignSystem.CornerRadius.badge)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ModernFilterOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .buttonStyle(.plain)
    }
}

struct ModernSortOption: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? DesignSystem.Colors.textInverse : DesignSystem.Colors.primary)
                
                Text(title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? DesignSystem.Colors.textInverse : DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.textInverse)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .buttonStyle(.plain)
    }
}