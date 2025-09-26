import SwiftUI
import PDFKit
import RevenueCat

// MARK: - PDF Preview View
struct PDFPreviewView: View {
    let pdfData: Data
    let invoice: Invoice
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("PDF Preview")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            PDFViewRepresentable(data: pdfData)
                .frame(height: 600)
                .modernCard(elevation: 2)
        }
    }
}

struct PDFViewRepresentable: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
}

// MARK: - Invoice Template System
enum InvoiceTemplate: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case minimalist = "Minimalist"
    case corporate = "Corporate"
    case creative = "Creative"
    case executive = "Executive"
    case finance = "Finance"
    case consulting = "Consulting"
    case technology = "Technology"
    case legal = "Legal"
    
    var id: String { rawValue }
    
    var displayName: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .classic:
            return "Timeless and professional design"
        case .minimalist:
            return "Clean and simple layout"
        case .corporate:
            return "Formal business style"
        case .creative:
            return "Modern and artistic approach"
        case .executive:
            return "Premium executive style"
        case .finance:
            return "Professional financial format"
        case .consulting:
            return "Clean consulting style"
        case .technology:
            return "Modern tech-focused design"
        case .legal:
            return "Formal legal document style"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .classic:
            return DesignSystem.Colors.primary
        case .minimalist:
            return DesignSystem.Colors.secondary
        case .corporate:
            return Color.blue
        case .creative:
            return DesignSystem.Colors.accent
        case .executive:
            return Color(red: 0.8, green: 0.7, blue: 0.3)
        case .finance:
            return Color(red: 0.2, green: 0.6, blue: 0.4)
        case .consulting:
            return Color(red: 0.4, green: 0.5, blue: 0.8)
        case .technology:
            return Color(red: 0.6, green: 0.2, blue: 0.8)
        case .legal:
            return Color(red: 0.3, green: 0.3, blue: 0.5)
        }
    }
    
    var accentColor: Color {
        return primaryColor.opacity(0.7)
    }
    
    var previewImage: String {
        switch self {
        case .classic:
            return "doc.text"
        case .minimalist:
            return "doc.plaintext"
        case .corporate:
            return "building.2"
        case .creative:
            return "paintbrush"
        case .executive:
            return "crown"
        case .finance:
            return "chart.bar"
        case .consulting:
            return "person.2"
        case .technology:
            return "laptopcomputer"
        case .legal:
            return "scale.3d"
        }
    }

    var isPremium: Bool {
        switch self {
        case .classic, .minimalist, .corporate:
            return false
        case .creative, .executive, .finance, .consulting, .technology, .legal:
            return true
        }
    }
}

// MARK: - Invoice Template Selection View
struct InvoiceTemplateSelectionView: View {
    @Binding var selectedTemplate: InvoiceTemplate
    @State private var showingPreview = false
    @State private var previewTemplate: InvoiceTemplate = .classic
    @State private var showingPaywall = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    let invoice: Invoice
    let businessInfo: BusinessInfo
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Choose Your Template")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Select a professional template for your invoice")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Template Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.md) {
                        ForEach(InvoiceTemplate.allCases) { template in
                            TemplateCard(
                                template: template,
                                isSelected: selectedTemplate == template,
                                onSelect: { selectedTemplate = template },
                                onPreview: {
                                    previewTemplate = template
                                    showingPreview = true
                                },
                                onShowPaywall: { showingPaywall = true }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Current Selection
                    if selectedTemplate != .classic {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.success)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Selected Template")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text(selectedTemplate.displayName)
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedTemplate.primaryColor)
                                
                                Text(selectedTemplate.description)
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.cardPadding)
                        .modernCard(elevation: 1)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Select Template")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingPreview) {
            TemplatePreviewView(
                template: previewTemplate,
                invoice: invoice,
                businessInfo: businessInfo
            )
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: InvoiceTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    let onShowPaywall: () -> Void
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            // Template Preview
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, template.primaryColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)

                Image(systemName: template.previewImage)
                    .font(.system(size: 30))
                    .foregroundColor(template.primaryColor)

                // Premium Badge
                if template.isPremium {
                    VStack {
                        HStack {
                            Text("PRO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(DesignSystem.Colors.accentGold)
                                .cornerRadius(8)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
            
            // Template Info
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(template.displayName)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(template.description)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Action Buttons - Fixed Double Background Issue
            HStack(spacing: DesignSystem.Spacing.sm) {
                Button(action: { onPreview() }) {
                    Text("Preview")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(template.primaryColor.opacity(0.8))
                )
                
                Button(action: {
                    if template.isPremium && !subscriptionManager.hasAccess(to: .advancedTemplates) {
                        onShowPaywall()
                    } else {
                        onSelect()
                    }
                }) {
                    Text(template.isPremium && !subscriptionManager.hasAccess(to: .advancedTemplates) ? "Upgrade" : "Select")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.semibold)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(isSelected ? template.primaryColor : template.primaryColor.opacity(0.6))
                )
                .disabled(isSelected)
                .opacity(isSelected ? 0.7 : 1.0)
            }
        }
        .modernCard(elevation: isSelected ? 2 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(
                    isSelected ? template.primaryColor : Color.clear,
                    lineWidth: isSelected ? 2 : 0
                )
        )
    }
}

// MARK: - Template Preview View
struct TemplatePreviewView: View {
    let template: InvoiceTemplate
    let invoice: Invoice
    let businessInfo: BusinessInfo
    @Environment(\.dismiss) private var dismiss
    @State private var pdfData: Data?
    @State private var showingPDF = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    // Template Header
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [template.primaryColor, template.accentColor]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: template.previewImage)
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.textInverse)
                        }
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(template.displayName)
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text(template.description)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .modernCard(elevation: 1)
                    .padding(.horizontal)
                    
                    // Invoice Preview
                    InvoiceTemplatePreview(
                        template: template,
                        invoice: invoice,
                        businessInfo: businessInfo
                    )
                    .padding(.horizontal)
                    
                    // Generate PDF Button
                    Button("Generate PDF Preview") {
                        generatePDFPreview()
                    }
                    .professionalButton(style: .primary, size: .large)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Template Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPDF) {
            if let pdfData = pdfData {
                PDFPreviewView(pdfData: pdfData, invoice: invoice)
            }
        }
    }
    
    private func generatePDFPreview() {
        if let data = PDFGenerator.shared.generateInvoicePDF(invoice: invoice, businessInfo: businessInfo, template: template) {
            pdfData = data
            showingPDF = true
        }
    }
}

// MARK: - Invoice Template Preview
struct InvoiceTemplatePreview: View {
    let template: InvoiceTemplate
    let invoice: Invoice
    let businessInfo: BusinessInfo
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            
            // Header based on template style
            templateHeader
            
            // Invoice Details
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Invoice #")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text(invoice.invoiceNumber)
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                        Text("Total")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text(invoice.total.currencyFormatted)
                            .font(DesignSystem.Typography.currencyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(template.primaryColor)
                    }
                }
                
                Divider()
                    .foregroundColor(template.primaryColor.opacity(0.3))
                
                // Client Information
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Bill To:")
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text(invoice.client.name)
                            .font(DesignSystem.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        if !invoice.client.email.isEmpty {
                            Text(invoice.client.email)
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                        Text("Due Date")
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text(invoice.dueDate, style: .date)
                            .font(DesignSystem.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                // Line Items Preview
                if !invoice.lineItems.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(invoice.lineItems.prefix(2), id: \.id) { item in
                            HStack {
                                Text(item.description)
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(item.total.currencyFormatted)
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                        }
                        
                        if invoice.lineItems.count > 2 {
                            HStack {
                                Text("... and \((invoice.lineItems.count - 2).decimalFormatted) more items")
                                    .font(DesignSystem.Typography.caption2)
                                    .italic()
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .modernCard(elevation: 2)
        .background(templateBackground)
    }
    
    @ViewBuilder
    private var templateHeader: some View {
        switch template {
        case .classic:
            classicHeader
        case .minimalist:
            minimalistHeader
        case .corporate:
            corporateHeader
        case .creative:
            creativeHeader
        case .executive:
            executiveHeader
        case .finance:
            financeHeader
        case .consulting:
            consultingHeader
        case .technology:
            technologyHeader
        case .legal:
            legalHeader
        }
    }
    
    private var classicHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(businessInfo.name.isEmpty ? "Your Business" : businessInfo.name)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(template.primaryColor)
            
            if !businessInfo.email.isEmpty {
                Text(businessInfo.email)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
    
    private var minimalistHeader: some View {
        HStack {
            Text(businessInfo.name.isEmpty ? "BUSINESS" : businessInfo.name.uppercased())
                .font(DesignSystem.Typography.headline)
                .fontWeight(.light)
                .foregroundColor(template.primaryColor)
                .tracking(2)
            
            Spacer()
        }
    }
    
    private var corporateHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Rectangle()
                .fill(template.primaryColor)
                .frame(height: 4)
            
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(businessInfo.name.isEmpty ? "Corporate Business" : businessInfo.name)
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    if !businessInfo.address.isEmpty {
                        Text(businessInfo.address)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private var creativeHeader: some View {
        HStack {
            Circle()
                .fill(template.primaryColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(businessInfo.name.prefix(1).uppercased()))
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textInverse)
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(businessInfo.name.isEmpty ? "Creative Studio" : businessInfo.name)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("INVOICE")
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.bold)
                    .foregroundColor(template.primaryColor)
                    .tracking(1)
            }
            
            Spacer()
        }
    }
    
    private var executiveHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Rectangle()
                .fill(template.primaryColor)
                .frame(height: 3)
            
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(businessInfo.name.isEmpty ? "Executive Services" : businessInfo.name)
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("PREMIUM INVOICE")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(template.primaryColor)
                        .tracking(1)
                }
                
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(template.primaryColor)
            }
        }
    }
    
    private var financeHeader: some View {
        HStack {
            Rectangle()
                .fill(template.primaryColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(businessInfo.name.isEmpty ? "Financial Services" : businessInfo.name)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("FINANCIAL STATEMENT")
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(template.primaryColor)
            }
            
            Spacer()
        }
        .padding(.leading, DesignSystem.Spacing.sm)
    }
    
    private var consultingHeader: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(businessInfo.name.isEmpty ? "Consulting Group" : businessInfo.name)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text("INVOICE")
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.bold)
                    .foregroundColor(template.primaryColor)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(template.primaryColor.opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.sm)
            }
            
            Divider()
                .background(template.primaryColor.opacity(0.3))
        }
    }
    
    private var technologyHeader: some View {
        HStack {
            LinearGradient(
                gradient: Gradient(colors: [template.primaryColor, template.accentColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(
                Text(businessInfo.name.isEmpty ? "TECH" : String(businessInfo.name.prefix(4)).uppercased())
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.black)
            )
            .frame(height: 30)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("INVOICE")
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(template.primaryColor)
                
                Rectangle()
                    .fill(template.primaryColor)
                    .frame(width: 50, height: 2)
            }
        }
    }
    
    private var legalHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: "scale.3d")
                    .font(.title2)
                    .foregroundColor(template.primaryColor)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(businessInfo.name.isEmpty ? "Legal Services" : businessInfo.name)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("PROFESSIONAL INVOICE")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(template.primaryColor)
                }
                
                Spacer()
            }
            
            Rectangle()
                .fill(template.primaryColor)
                .frame(height: 1)
        }
    }
    
    private var templateBackground: some View {
        Group {
            switch template {
            case .creative, .technology:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        template.primaryColor.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .executive:
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.98, green: 0.97, blue: 0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            default:
                Color.white
            }
        }
    }
}