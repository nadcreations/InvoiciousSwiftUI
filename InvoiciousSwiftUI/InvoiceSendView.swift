import SwiftUI

struct InvoiceSendView: View {
    let invoice: Invoice
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var emailService = InvoiceEmailService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipientEmail: String
    @State private var customMessage: String = ""
    @State private var includePaymentInstructions = true
    @State private var enableTracking = true
    @State private var generatedPDFData: Data?
    @State private var isGeneratingPDF = false
    @State private var showingSendConfirmation = false
    @State private var sendResult: EmailSendResult?
    @State private var selectedTemplate: InvoiceTemplate = .classic
    
    init(invoice: Invoice) {
        self.invoice = invoice
        self._recipientEmail = State(initialValue: invoice.client.email)
        self._selectedTemplate = State(initialValue: invoice.template)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Recipient Section
                Section("Send To") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(invoice.client.name)
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            TextField("Client email", text: $recipientEmail)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        
                        Spacer()
                        
                        // Email validation indicator
                        if isValidEmail(recipientEmail) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.success)
                        } else if !recipientEmail.isEmpty {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.error)
                        }
                    }
                }
                
                // Invoice Details Section
                Section("Invoice Details") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Invoice \(invoice.invoiceNumber)")
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.semibold)
                            
                            Text("Due: \(invoice.dueDate, style: .date)")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(invoice.total.currencyFormatted)
                            .font(DesignSystem.Typography.currencyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    
                    // Template Selection
                    HStack {
                        Text("PDF Template")
                            .font(DesignSystem.Typography.callout)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(InvoiceTemplate.allCases) { template in
                                Button(template.displayName) {
                                    selectedTemplate = template
                                    // Regenerate PDF with new template
                                    generatePDF()
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedTemplate.displayName)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }
                }
                
                // Custom Message Section
                Section("Personal Message (Optional)") {
                    TextField("Add a personal message to your client...", text: $customMessage, axis: .vertical)
                        .lineLimit(3...6)
                        .font(DesignSystem.Typography.callout)
                }
                
                // Options Section
                Section("Email Options") {
                    Toggle("Include Payment Instructions", isOn: $includePaymentInstructions)
                    Toggle("Enable Read Receipts", isOn: $enableTracking)
                        .onChange(of: enableTracking) { enabled in
                            // Update tracking preference
                            var updatedInvoice = invoice
                            updatedInvoice.trackingEnabled = enabled
                            dataManager.updateInvoice(updatedInvoice)
                        }
                }
                
                // Email Preview Section
                Section("Email Preview") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Subject Preview
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subject:")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text(emailSubject)
                                .font(DesignSystem.Typography.callout)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        
                        Divider()
                        
                        // Message Preview
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Message Preview:")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text(emailPreview)
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Send Statistics (if invoice has been sent before)
                if !invoice.emailsSent.isEmpty {
                    Section("Send History") {
                        ForEach(invoice.emailsSent.prefix(3)) { emailRecord in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Image(systemName: emailRecord.deliveryStatus.icon)
                                            .foregroundColor(emailRecord.deliveryStatus.color)
                                            .font(.caption)
                                        
                                        Text(emailRecord.deliveryStatus.rawValue)
                                            .font(DesignSystem.Typography.caption1)
                                            .fontWeight(.medium)
                                            .foregroundColor(emailRecord.deliveryStatus.color)
                                    }
                                    
                                    Text(emailRecord.sentDate, style: .relative)
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                                
                                Spacer()
                                
                                if let openedDate = emailRecord.openedDate {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("📖 Opened")
                                            .font(DesignSystem.Typography.caption2)
                                            .foregroundColor(DesignSystem.Colors.success)
                                        
                                        Text(openedDate, style: .relative)
                                            .font(DesignSystem.Typography.caption2)
                                            .foregroundColor(DesignSystem.Colors.textTertiary)
                                    }
                                }
                            }
                        }
                        
                        if invoice.emailsSent.count > 3 {
                            Text("+ \(invoice.emailsSent.count - 3) more emails sent")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                }
                
                // Tracking Stats
                if invoice.lastViewedDate != nil || invoice.viewCount > 0 {
                    Section("Tracking Stats") {
                        HStack {
                            Text("👀 Total Views:")
                            Spacer()
                            Text("\(invoice.viewCount)")
                                .fontWeight(.semibold)
                        }
                        
                        if let lastViewed = invoice.lastViewedDate {
                            HStack {
                                Text("🕐 Last Viewed:")
                                Spacer()
                                Text(lastViewed, style: .relative)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                        
                        if invoice.downloadCount > 0 {
                            HStack {
                                Text("⬇️ Downloads:")
                                Spacer()
                                Text("\(invoice.downloadCount)")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Send Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink("Tracking") {
                            InvoiceTrackingDetailView(invoice: invoice)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                        Button("Send") {
                            sendInvoice()
                        }
                        .professionalButton(style: .primary, size: .small)
                        .disabled(!canSendInvoice || isGeneratingPDF)
                    }
                }
            }
        }
        .onAppear {
            generatePDF()
        }
        .alert("Send Invoice", isPresented: $showingSendConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Send Now") {
                performSend()
            }
        } message: {
            Text("Send invoice \(invoice.invoiceNumber) to \(recipientEmail)?")
        }
        .alert("Email Result", isPresented: .constant(sendResult != nil)) {
            Button("OK") {
                if case .sent = sendResult {
                    dismiss()
                }
                sendResult = nil
            }
        } message: {
            if let result = sendResult {
                switch result {
                case .sent:
                    Text("✅ Invoice sent successfully! Your client will receive email tracking notifications.")
                case .cancelled:
                    Text("📭 Email sending was cancelled.")
                case .failed(let error):
                    Text("❌ Failed to send email: \(error)")
                }
            }
        }
    }
    
    private var emailSubject: String {
        "Invoice \(invoice.invoiceNumber) from \(dataManager.businessInfo.name.isEmpty ? "Your Business" : dataManager.businessInfo.name)"
    }
    
    private var emailPreview: String {
        let greeting = "Hello \(invoice.client.name), Thank you for your business! Please find your invoice attached."
        let customPart = customMessage.isEmpty ? "" : " \(customMessage)"
        return greeting + customPart
    }
    
    private var canSendInvoice: Bool {
        !recipientEmail.isEmpty && 
        isValidEmail(recipientEmail) && 
        generatedPDFData != nil && 
        !isGeneratingPDF
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func generatePDF() {
        isGeneratingPDF = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let pdfData = PDFGenerator.shared.generateInvoicePDF(
                invoice: invoice,
                businessInfo: dataManager.businessInfo,
                template: selectedTemplate
            ) {
                DispatchQueue.main.async {
                    self.generatedPDFData = pdfData
                    self.isGeneratingPDF = false
                    print("✅ PDF generated for sending: \(pdfData.count.decimalFormatted) bytes")
                }
            } else {
                DispatchQueue.main.async {
                    self.isGeneratingPDF = false
                    print("❌ Failed to generate PDF for sending")
                }
            }
        }
    }
    
    private func sendInvoice() {
        showingSendConfirmation = true
    }
    
    private func performSend() {
        guard let pdfData = generatedPDFData else {
            sendResult = .failed("PDF not generated")
            return
        }
        
        emailService.sendInvoice(
            invoice,
            pdfData: pdfData,
            businessInfo: dataManager.businessInfo,
            customMessage: customMessage
        ) { result in
            DispatchQueue.main.async {
                self.sendResult = result
                
                // Record the email in DataManager
                if case .sent(let emailRecord) = result {
                    self.dataManager.recordInvoiceEmailSent(self.invoice, emailRecord: emailRecord)
                }
            }
        }
    }
}

// MARK: - Send Quick Actions View
struct InvoiceQuickSendView: View {
    let invoice: Invoice
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var emailService = InvoiceEmailService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isGeneratingPDF = false
    @State private var generatedPDFData: Data?
    @State private var sendResult: EmailSendResult?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.xl) {
                
                // Quick Send Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Send Invoice")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                    
                    Text("Quickly send \(invoice.invoiceNumber) to \(invoice.client.name)")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Quick Actions
                VStack(spacing: DesignSystem.Spacing.md) {
                    
                    // Send with Default Template
                    Button(action: {
                        quickSend()
                    }) {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "paperplane.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.textInverse)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Send Now")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textInverse)
                                
                                Text("Send with default template and message")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.textInverse.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .background(DesignSystem.Colors.primary)
                        .cornerRadius(DesignSystem.CornerRadius.lg)
                    }
                    .disabled(isGeneratingPDF)
                    
                    // Send Payment Reminder
                    if invoice.status == .sent || invoice.status == .overdue {
                        Button(action: {
                            sendReminder()
                        }) {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.warning)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Send Reminder")
                                        .font(DesignSystem.Typography.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                    
                                    Text("Send payment reminder email")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(DesignSystem.CornerRadius.lg)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                    .stroke(DesignSystem.Colors.warning.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Progress Indicator
                if isGeneratingPDF {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating PDF...")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding(DesignSystem.Spacing.screenPadding)
            .navigationTitle("Quick Send")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            generatePDF()
        }
        .alert("Send Result", isPresented: .constant(sendResult != nil)) {
            Button("OK") {
                if case .sent = sendResult {
                    dismiss()
                }
                sendResult = nil
            }
        } message: {
            if let result = sendResult {
                switch result {
                case .sent:
                    Text("✅ Email sent successfully!")
                case .cancelled:
                    Text("📭 Email sending was cancelled.")
                case .failed(let error):
                    Text("❌ Failed to send: \(error)")
                }
            }
        }
    }
    
    private func generatePDF() {
        isGeneratingPDF = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let pdfData = PDFGenerator.shared.generateInvoicePDF(
                invoice: invoice,
                businessInfo: dataManager.businessInfo,
                template: invoice.template
            ) {
                DispatchQueue.main.async {
                    self.generatedPDFData = pdfData
                    self.isGeneratingPDF = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isGeneratingPDF = false
                }
            }
        }
    }
    
    private func quickSend() {
        guard let pdfData = generatedPDFData else {
            sendResult = .failed("PDF not ready")
            return
        }
        
        emailService.sendInvoice(
            invoice,
            pdfData: pdfData,
            businessInfo: dataManager.businessInfo
        ) { result in
            DispatchQueue.main.async {
                self.sendResult = result
                
                if case .sent(let emailRecord) = result {
                    self.dataManager.recordInvoiceEmailSent(self.invoice, emailRecord: emailRecord)
                }
            }
        }
    }
    
    private func sendReminder() {
        emailService.sendPaymentReminder(
            for: invoice,
            businessInfo: dataManager.businessInfo
        ) { result in
            DispatchQueue.main.async {
                self.sendResult = result
                
                if case .sent(let emailRecord) = result {
                    self.dataManager.recordInvoiceEmailSent(self.invoice, emailRecord: emailRecord)
                }
            }
        }
    }
}

#Preview {
    InvoiceSendView(invoice: Invoice())
}