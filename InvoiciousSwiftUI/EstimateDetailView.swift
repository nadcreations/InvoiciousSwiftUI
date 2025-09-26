import SwiftUI

struct EstimateDetailView: View {
    let estimate: Estimate
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingPDFView = false
    @State private var showingTemplateSelection = false
    @State private var selectedTemplate: InvoiceTemplate = .classic
    @State private var generatedPDFData: Data?
    @State private var showingConversionConfirmation = false
    @State private var convertedInvoice: Invoice?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                    
                    // Enhanced Estimate Header with Actions
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        
                        // Main Header
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(estimate.estimateNumber)
                                    .font(DesignSystem.Typography.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Estimate Details")
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            ModernEstimateStatusBadge(status: estimate.effectiveStatus)
                        }
                        
                        // Amount Section
                        HStack {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Total Amount")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text(estimate.total.currencyFormatted)
                                    .font(DesignSystem.Typography.currencyLarge)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                Text("Valid Until")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text(estimate.validUntil, style: .date)
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(estimate.isExpired ? DesignSystem.Colors.error : DesignSystem.Colors.textPrimary)
                            }
                        }
                        
                        // 🎯 ONE-CLICK CONVERSION BUTTON - MAIN FEATURE
                        if estimate.status != .accepted && estimate.status != .declined && !estimate.isExpired {
                            Button(action: { showingConversionConfirmation = true }) {
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(DesignSystem.Colors.primary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Convert to Invoice")
                                            .font(DesignSystem.Typography.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)

                                        Text("One-click conversion with all details")
                                            .font(DesignSystem.Typography.caption1)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }

                                    Spacer()

                                    Text("1-Click")
                                        .font(DesignSystem.Typography.caption1)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .padding(.horizontal, DesignSystem.Spacing.sm)
                                        .padding(.vertical, DesignSystem.Spacing.xs)
                                }
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }
                        
                        // Action Buttons Row
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Button(action: { generateAndShowPDF() }) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: DesignSystem.Icons.download)
                                        .font(.system(size: 14, weight: .medium))
                                    Text("PDF")
                                        .font(DesignSystem.Typography.caption1)
                                }
                            }
                            .professionalButton(style: .primary, size: .small)
                            
                            Button(action: { showingTemplateSelection = true }) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Template")
                                        .font(DesignSystem.Typography.caption1)
                                }
                            }
                            .professionalButton(style: .outline, size: .small)
                            
                            Button(action: { shareEstimate() }) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: DesignSystem.Icons.share)
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Share")
                                        .font(DesignSystem.Typography.caption1)
                                }
                            }
                            .professionalButton(style: .outline, size: .small)
                            
                            Spacer()
                        }
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .background(DesignSystem.Colors.surface)
                    .modernCard(elevation: 2)
                    
                    // Client Information
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Client Information")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(estimate.client.name)
                                        .font(DesignSystem.Typography.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                    
                                    if !estimate.client.email.isEmpty {
                                        Text(estimate.client.email)
                                            .font(DesignSystem.Typography.callout)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            if !estimate.client.address.isEmpty {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(estimate.client.address)
                                            .font(DesignSystem.Typography.callout)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                        
                                        let locationParts = [estimate.client.city, estimate.client.state, estimate.client.zipCode].filter { !$0.isEmpty }
                                        if !locationParts.isEmpty {
                                            Text(locationParts.joined(separator: ", "))
                                                .font(DesignSystem.Typography.caption1)
                                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .background(DesignSystem.Colors.surface)
                    .modernCard(elevation: 1)
                    
                    // Line Items
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Line Items")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(estimate.lineItems) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.description)
                                            .font(DesignSystem.Typography.callout)
                                            .fontWeight(.medium)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                        
                                        HStack(spacing: DesignSystem.Spacing.sm) {
                                            Text("Qty: \(item.quantity, specifier: "%.1f")")
                                                .font(DesignSystem.Typography.caption1)
                                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                            
                                            Text("×")
                                                .font(DesignSystem.Typography.caption1)
                                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                            
                                            Text(item.unitPrice.currencyFormatted)
                                                .font(DesignSystem.Typography.caption1)
                                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.total.currencyFormatted)
                                        .font(DesignSystem.Typography.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                }
                                .padding(DesignSystem.Spacing.md)
                                .background(DesignSystem.Colors.backgroundSecondary)
                                .cornerRadius(DesignSystem.CornerRadius.sm)
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .background(DesignSystem.Colors.surface)
                    .modernCard(elevation: 1)
                    
                    // Estimate Totals
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Text("Subtotal:")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Spacer()
                            
                            Text(estimate.subtotal.currencyFormatted)
                                .font(DesignSystem.Typography.callout)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        
                        if estimate.taxRate > 0 {
                            HStack {
                                Text("Tax (\(Int(estimate.taxRate * 100))%):")
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Spacer()
                                
                                Text(estimate.taxAmount.currencyFormatted)
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                        }
                        
                        Divider()
                            .background(DesignSystem.Colors.borderStrong)
                        
                        HStack {
                            Text("Total Amount:")
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text(estimate.total.currencyFormatted)
                                .font(DesignSystem.Typography.currencyLarge)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .background(DesignSystem.Colors.surface)
                    .modernCard(elevation: 1)
                    
                    // Estimate Notes
                    if !estimate.notes.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Notes")
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text(estimate.notes)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .padding(DesignSystem.Spacing.md)
                                .background(DesignSystem.Colors.backgroundSecondary)
                                .cornerRadius(DesignSystem.CornerRadius.sm)
                        }
                        .padding(DesignSystem.Spacing.cardPadding)
                        .background(DesignSystem.Colors.surface)
                        .modernCard(elevation: 1)
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.massive)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .professionalButton(style: .ghost, size: .small)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // Edit action
                    }
                    .professionalButton(style: .primary, size: .small)
                }
            }
        }
        .sheet(isPresented: $showingPDFView) {
            if let pdfData = generatedPDFData {
                NavigationStack {
                    PDFPreviewView(pdfData: pdfData, invoice: Invoice(client: estimate.client))
                        .navigationTitle("Estimate PDF")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    showingPDFView = false
                                }
                                .professionalButton(style: .ghost, size: .small)
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Share") {
                                    showingPDFView = false
                                    shareEstimate()
                                }
                                .professionalButton(style: .primary, size: .small)
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showingTemplateSelection) {
            InvoiceTemplateSelectionView(
                selectedTemplate: $selectedTemplate,
                invoice: Invoice(client: estimate.client),
                businessInfo: dataManager.businessInfo
            )
        }
        .alert("Convert to Invoice", isPresented: $showingConversionConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Convert") {
                convertToInvoice()
            }
        } message: {
            Text("This will create a new invoice with all estimate details. The estimate will be marked as accepted.")
        }
        .alert("Conversion Complete!", isPresented: .constant(convertedInvoice != nil)) {
            Button("View Invoice") {
                // Navigate to invoice detail
                convertedInvoice = nil
            }
            Button("Stay Here") {
                convertedInvoice = nil
            }
        } message: {
            if let invoice = convertedInvoice {
                Text("Estimate successfully converted to invoice \(invoice.invoiceNumber)")
            }
        }
    }
    
    // MARK: - One-Click Conversion Method
    private func convertToInvoice() {
        print("🔄 Converting estimate \(estimate.estimateNumber) to invoice...")
        
        let invoice = dataManager.convertEstimateToInvoice(estimate)
        convertedInvoice = invoice
        
        // Haptic feedback for success
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("✅ Conversion complete! Invoice: \(invoice.invoiceNumber)")
    }
    
    private func generateAndShowPDF() {
        print("📄 Generating PDF for estimate: \(estimate.estimateNumber)")
        
        // Create a temporary invoice for PDF generation
        let tempInvoice = estimate.convertToInvoice()
        tempInvoice.invoiceNumber = estimate.estimateNumber // Keep estimate number for PDF
        
        if let pdfData = PDFGenerator.shared.generateInvoicePDF(
            invoice: tempInvoice,
            businessInfo: dataManager.businessInfo,
            template: selectedTemplate
        ) {
            generatedPDFData = pdfData
            showingPDFView = true
            print("✅ PDF generated successfully! Size: \(pdfData.count.decimalFormatted) bytes")
        } else {
            print("❌ Failed to generate PDF")
        }
    }
    
    private func shareEstimate() {
        print("📤 Sharing estimate: \(estimate.estimateNumber)")
        
        // First generate PDF if not already generated
        if generatedPDFData == nil {
            generateAndShowPDF()
        }
        
        guard let pdfData = generatedPDFData else {
            print("❌ No PDF data to share")
            return
        }
        
        // Create temporary file for sharing
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(estimate.estimateNumber).pdf")
        
        do {
            try pdfData.write(to: tempURL)
            
            // Present share sheet
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(
                    activityItems: [tempURL],
                    applicationActivities: nil
                )
                
                // Get the root view controller to present from
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    activityVC.popoverPresentationController?.sourceView = window
                    rootVC.present(activityVC, animated: true) {
                        print("✅ Share sheet presented successfully")
                    }
                }
            }
        } catch {
            print("❌ Error writing PDF to temp file: \(error.localizedDescription)")
        }
    }
}

// MARK: - Modern Estimate Status Badge
struct ModernEstimateStatusBadge: View {
    let status: EstimateStatus
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.rawValue)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.semibold)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(status.color.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.badge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.badge)
                .stroke(status.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    EstimateDetailView(estimate: Estimate())
}