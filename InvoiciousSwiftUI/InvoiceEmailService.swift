import Foundation
import UIKit
import MessageUI

// MARK: - Invoice Email Service
class InvoiceEmailService: NSObject, ObservableObject {
    static let shared = InvoiceEmailService()
    
    @Published var isComposingEmail = false
    @Published var lastEmailResult: EmailSendResult?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Send Invoice via Email
    func sendInvoice(
        _ invoice: Invoice,
        pdfData: Data,
        businessInfo: BusinessInfo,
        customMessage: String = "",
        completion: @escaping (EmailSendResult) -> Void
    ) {
        guard MFMailComposeViewController.canSendMail() else {
            completion(.failed("Mail not configured on device"))
            return
        }
        
        let subject = "Invoice \(invoice.invoiceNumber) from \(businessInfo.name.isEmpty ? "Your Business" : businessInfo.name)"
        let messageBody = generateEmailBody(invoice: invoice, businessInfo: businessInfo, customMessage: customMessage)
        
        // Create email record for tracking
        let emailRecord = InvoiceEmailRecord(
            recipientEmail: invoice.client.email,
            subject: subject
        )
        
        DispatchQueue.main.async {
            self.presentEmailComposer(
                subject: subject,
                messageBody: messageBody,
                recipientEmail: invoice.client.email,
                pdfData: pdfData,
                fileName: "\(invoice.invoiceNumber).pdf",
                emailRecord: emailRecord,
                completion: completion
            )
        }
    }
    
    // MARK: - Present Email Composer
    private func presentEmailComposer(
        subject: String,
        messageBody: String,
        recipientEmail: String,
        pdfData: Data,
        fileName: String,
        emailRecord: InvoiceEmailRecord,
        completion: @escaping (EmailSendResult) -> Void
    ) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            completion(.failed("Cannot present email composer"))
            return
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = EmailComposeDelegate(
            emailRecord: emailRecord,
            completion: completion
        )
        
        // Set email properties
        mailComposer.setToRecipients([recipientEmail])
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: true)
        
        // Attach PDF
        mailComposer.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: fileName)
        
        self.isComposingEmail = true
        rootVC.present(mailComposer, animated: true)
    }
    
    // MARK: - Generate Professional Email Body
    private func generateEmailBody(invoice: Invoice, businessInfo: BusinessInfo, customMessage: String) -> String {
        let businessName = businessInfo.name.isEmpty ? "Your Business" : businessInfo.name
        let clientName = invoice.client.name
        
        let customMessageHTML = customMessage.isEmpty ? "" : """
        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <p style="margin: 0; color: #495057;">\(customMessage)</p>
        </div>
        """
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Invoice \(invoice.invoiceNumber)</title>
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
            
            <!-- Header -->
            <div style="text-align: center; padding: 30px 0; border-bottom: 2px solid #e9ecef;">
                <h1 style="color: #113760; margin: 0; font-size: 28px; font-weight: 700;">\(businessName)</h1>
                <p style="color: #6c757d; margin: 5px 0 0 0;">Professional Invoice</p>
            </div>
            
            <!-- Greeting -->
            <div style="padding: 30px 0 20px 0;">
                <h2 style="color: #113760; margin: 0 0 15px 0;">Hello \(clientName),</h2>
                <p style="margin: 0; font-size: 16px;">Thank you for your business! Please find your invoice attached.</p>
            </div>
            
            <!-- Invoice Summary -->
            <div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 20px 0;">
                <h3 style="margin: 0 0 20px 0; color: #113760;">Invoice Summary</h3>
                <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; font-weight: 600;">Invoice Number:</td>
                        <td style="padding: 8px 0; text-align: right;">\(invoice.invoiceNumber)</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; font-weight: 600;">Issue Date:</td>
                        <td style="padding: 8px 0; text-align: right;">\(DateFormatter.mediumDateFormatter.string(from: invoice.issueDate))</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; font-weight: 600;">Due Date:</td>
                        <td style="padding: 8px 0; text-align: right; color: #dc3545; font-weight: 600;">\(DateFormatter.mediumDateFormatter.string(from: invoice.dueDate))</td>
                    </tr>
                    <tr style="border-top: 2px solid #dee2e6;">
                        <td style="padding: 15px 0 8px 0; font-weight: 700; font-size: 18px;">Total Amount:</td>
                        <td style="padding: 15px 0 8px 0; text-align: right; font-weight: 700; font-size: 18px; color: #28a745;">\(invoice.total.currencyFormatted)</td>
                    </tr>
                </table>
            </div>
            
            <!-- Custom Message -->
            \(customMessageHTML)
            
            <!-- Payment Instructions -->
            <div style="background-color: #e3f2fd; padding: 25px; border-radius: 8px; margin: 20px 0;">
                <h3 style="margin: 0 0 15px 0; color: #1565c0;">💳 Payment Options</h3>
                <ul style="margin: 0; padding-left: 20px; color: #1976d2;">
                    <li style="margin: 5px 0;">💰 Cash</li>
                    <li style="margin: 5px 0;">💳 Credit Card</li>
                    <li style="margin: 5px 0;">🏦 Bank Transfer</li>
                    <li style="margin: 5px 0;">📝 Check</li>
                    <li style="margin: 5px 0;">💎 PayPal</li>
                </ul>
                <p style="margin: 15px 0 0 0; font-size: 14px; color: #1976d2;">
                    <strong>Please ensure payment is received by the due date to avoid late fees.</strong>
                </p>
            </div>
            
            <!-- Call to Action -->
            <div style="text-align: center; padding: 30px 0;">
                <div style="background: linear-gradient(135deg, #28a745, #00B176); padding: 15px 30px; border-radius: 25px; display: inline-block;">
                    <p style="margin: 0; color: white; font-weight: 600;">📄 Invoice PDF attached above ☝️</p>
                </div>
            </div>
            
            <!-- Contact Information -->
            <div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 30px 0;">
                <h3 style="margin: 0 0 15px 0; color: #113760;">📞 Questions?</h3>
                <p style="margin: 0 0 10px 0;">If you have any questions about this invoice, please don't hesitate to contact us:</p>
                <ul style="list-style: none; padding: 0; margin: 10px 0;">
                    \(businessInfo.email.isEmpty ? "" : "<li style=\"margin: 5px 0;\">📧 Email: \(businessInfo.email)</li>")
                    \(businessInfo.phone.isEmpty ? "" : "<li style=\"margin: 5px 0;\">📱 Phone: \(businessInfo.phone)</li>")
                    \(businessInfo.website.isEmpty ? "" : "<li style=\"margin: 5px 0;\">🌐 Website: \(businessInfo.website)</li>")
                </ul>
            </div>
            
            <!-- Footer -->
            <div style="text-align: center; padding: 30px 0; border-top: 1px solid #dee2e6; color: #6c757d; font-size: 14px;">
                <p style="margin: 0;">Thank you for choosing \(businessName)!</p>
                <p style="margin: 10px 0 0 0;">Generated by Invoicious • Professional Invoicing Made Simple</p>
            </div>
            
            <!-- Tracking Pixel (for read receipts) -->
            <img src="https://invoicious-tracking.com/track/\(UUID().uuidString)" width="1" height="1" style="display: none;" alt="">
            
        </body>
        </html>
        """
    }
    
    // MARK: - Send Quick Reminder
    func sendPaymentReminder(
        for invoice: Invoice,
        businessInfo: BusinessInfo,
        completion: @escaping (EmailSendResult) -> Void
    ) {
        guard MFMailComposeViewController.canSendMail() else {
            completion(.failed("Mail not configured on device"))
            return
        }
        
        let subject = "Payment Reminder: Invoice \(invoice.invoiceNumber)"
        let messageBody = generateReminderEmailBody(invoice: invoice, businessInfo: businessInfo)
        
        let emailRecord = InvoiceEmailRecord(
            recipientEmail: invoice.client.email,
            subject: subject
        )
        
        DispatchQueue.main.async {
            self.presentEmailComposer(
                subject: subject,
                messageBody: messageBody,
                recipientEmail: invoice.client.email,
                pdfData: Data(), // No attachment for reminders
                fileName: "",
                emailRecord: emailRecord,
                completion: completion
            )
        }
    }
    
    private func generateReminderEmailBody(invoice: Invoice, businessInfo: BusinessInfo) -> String {
        let businessName = businessInfo.name.isEmpty ? "Your Business" : businessInfo.name
        let daysOverdue = Calendar.current.dateComponents([.day], from: invoice.dueDate, to: Date()).day ?? 0
        
        let overdueText = daysOverdue > 0 
            ? "This invoice is \(daysOverdue) days overdue." 
            : "This invoice is due on \(DateFormatter.mediumDateFormatter.string(from: invoice.dueDate))."
        
        return """
        <!DOCTYPE html>
        <html>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
            
            <div style="text-align: center; padding: 20px 0; border-bottom: 2px solid #e9ecef;">
                <h1 style="color: #dc3545; margin: 0;">⏰ Payment Reminder</h1>
            </div>
            
            <div style="padding: 30px 0;">
                <h2 style="color: #113760;">Hello \(invoice.client.name),</h2>
                <p>This is a friendly reminder about invoice <strong>\(invoice.invoiceNumber)</strong>.</p>
                <p style="color: #dc3545; font-weight: 600;">\(overdueText)</p>
            </div>
            
            <div style="background-color: #fff3cd; padding: 20px; border-radius: 8px; border-left: 4px solid #ffc107;">
                <h3 style="margin: 0 0 10px 0;">Invoice Details:</h3>
                <p><strong>Amount Due:</strong> \(invoice.remainingBalance.currencyFormatted)</p>
                <p><strong>Original Due Date:</strong> \(DateFormatter.mediumDateFormatter.string(from: invoice.dueDate))</p>
            </div>
            
            <div style="text-align: center; padding: 30px 0;">
                <p>Please process payment at your earliest convenience.</p>
                <p style="color: #6c757d;">Thank you for your prompt attention to this matter.</p>
            </div>
            
            <div style="text-align: center; color: #6c757d; font-size: 14px;">
                <p>Best regards,<br>\(businessName)</p>
            </div>
            
        </body>
        </html>
        """
    }
}

// MARK: - Email Send Result
enum EmailSendResult {
    case sent(InvoiceEmailRecord)
    case cancelled
    case failed(String)
    
    var isSuccess: Bool {
        switch self {
        case .sent: return true
        case .cancelled, .failed: return false
        }
    }
}

// MARK: - Email Compose Delegate
class EmailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate {
    private let emailRecord: InvoiceEmailRecord
    private let completion: (EmailSendResult) -> Void
    
    init(emailRecord: InvoiceEmailRecord, completion: @escaping (EmailSendResult) -> Void) {
        self.emailRecord = emailRecord
        self.completion = completion
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        var emailResult: EmailSendResult
        var updatedRecord = emailRecord
        
        switch result {
        case .sent:
            updatedRecord.deliveryStatus = .delivered
            emailResult = .sent(updatedRecord)
            print("✅ Invoice email sent successfully to \(emailRecord.recipientEmail)")
            
        case .cancelled:
            emailResult = .cancelled
            print("📭 Email sending cancelled by user")
            
        case .failed:
            updatedRecord.deliveryStatus = .failed
            let errorMessage = error?.localizedDescription ?? "Unknown error"
            emailResult = .failed(errorMessage)
            print("❌ Email sending failed: \(errorMessage)")
            
        case .saved:
            emailResult = .cancelled // Treat saved as cancelled for now
            print("💾 Email saved to drafts")
            
        @unknown default:
            emailResult = .failed("Unknown result")
        }
        
        controller.dismiss(animated: true) {
            self.completion(emailResult)
        }
    }
}

// MARK: - Date Formatter Extension
// DateFormatter.mediumDateFormatter is defined in PDFGenerator.swift