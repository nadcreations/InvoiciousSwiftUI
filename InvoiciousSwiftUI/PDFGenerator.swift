import Foundation
import UIKit
import PDFKit

class PDFGenerator {
    static let shared = PDFGenerator()
    
    private init() {}
    
    func generateInvoicePDF(invoice: Invoice, businessInfo: BusinessInfo, template: InvoiceTemplate = .classic) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // 8.5" x 11" in points
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        UIGraphicsBeginPDFPage()
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to get graphics context")
            UIGraphicsEndPDFContext()
            return nil
        }
        
        // Set up fonts
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let headerFont = UIFont.boldSystemFont(ofSize: 16)
        let bodyFont = UIFont.systemFont(ofSize: 12)
        let smallFont = UIFont.systemFont(ofSize: 10)
        
        var yPosition: CGFloat = 50
        
        // HEADER SECTION
        drawInvoiceHeader(context: context, pageRect: pageRect, invoice: invoice, businessInfo: businessInfo, template: template, y: &yPosition)
        
        yPosition += 30
        
        // BUSINESS INFO & CLIENT INFO
        drawBusinessAndClientInfo(context: context, pageRect: pageRect, invoice: invoice, businessInfo: businessInfo, y: &yPosition)
        
        yPosition += 40
        
        // INVOICE DETAILS
        drawInvoiceDetails(context: context, pageRect: pageRect, invoice: invoice, y: &yPosition)
        
        yPosition += 30
        
        // LINE ITEMS TABLE
        if template == .finance {
            drawProfessionalLineItemsTable(context: context, pageRect: pageRect, invoice: invoice, y: &yPosition)
        } else {
            drawLineItemsTable(context: context, pageRect: pageRect, invoice: invoice, y: &yPosition)
        }
        
        yPosition += 40
        
        // TOTALS SECTION
        drawTotalsSection(context: context, pageRect: pageRect, invoice: invoice, y: &yPosition)
        
        yPosition += 30
        
        // NOTES SECTION
        if !invoice.notes.isEmpty {
            drawNotesSection(context: context, pageRect: pageRect, invoice: invoice, y: &yPosition)
        }
        
        // FOOTER
        drawFooter(context: context, pageRect: pageRect, businessInfo: businessInfo)
        
        UIGraphicsEndPDFContext()
        
        let finalData = pdfData as Data
        print("PDF generated successfully with \(finalData.count) bytes")
        
        return finalData
    }
    
    private func drawInvoiceHeader(context: CGContext, pageRect: CGRect, invoice: Invoice, businessInfo: BusinessInfo, template: InvoiceTemplate, y: inout CGFloat) {
        switch template {
        case .classic:
            drawClassicHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .minimalist:
            drawMinimalistHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .corporate:
            drawCorporateHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .creative:
            drawCreativeHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .executive:
            drawExecutiveHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .finance:
            drawFinanceHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .consulting:
            drawConsultingHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .technology:
            drawTechnologyHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        case .legal:
            drawLegalHeader(context: context, pageRect: pageRect, businessInfo: businessInfo, y: &y)
        }
    }
    
    private func drawExecutiveHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let headerHeight: CGFloat = 120
        
        // Premium top border with gold accent
        context.setFillColor(UIColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0).cgColor)
        let topBorderRect = CGRect(x: 0, y: y, width: pageRect.width, height: 4)
        context.fill(topBorderRect)
        
        y += 20
        
        // Executive logo area
        let logoSize: CGFloat = 60
        let logoRect = CGRect(x: 50, y: y, width: logoSize, height: 40)
        context.setFillColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
        let logoPath = UIBezierPath(roundedRect: logoRect, cornerRadius: 4)
        context.addPath(logoPath.cgPath)
        context.fillPath()
        
        // Company initials in logo
        let companyName = businessInfo.name.isEmpty ? "EXECUTIVE COMPANY" : businessInfo.name
        let logoText = String(companyName.prefix(3).uppercased())
        let logoAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.white
        ]
        let logoTextSize = logoText.size(withAttributes: logoAttributes)
        let logoTextRect = CGRect(
            x: logoRect.midX - logoTextSize.width/2,
            y: logoRect.midY - logoTextSize.height/2,
            width: logoTextSize.width,
            height: logoTextSize.height
        )
        logoText.draw(in: logoTextRect, withAttributes: logoAttributes)
        
        // Company name
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        ]
        companyName.draw(at: CGPoint(x: 50, y: y + 50), withAttributes: titleAttributes)
        
        // Executive services subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0)
        ]
        "EXECUTIVE SERVICES".draw(at: CGPoint(x: 50, y: y + 75), withAttributes: subtitleAttributes)
        
        // INVOICE text
        let invoiceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .thin),
            .foregroundColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        ]
        let invoiceText = "INVOICE"
        let invoiceSize = invoiceText.size(withAttributes: invoiceAttributes)
        invoiceText.draw(at: CGPoint(x: pageRect.width - invoiceSize.width - 50, y: y + 20), withAttributes: invoiceAttributes)
        
        // Executive separator line
        y += 100
        context.setFillColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 50, y: y, width: pageRect.width - 200, height: 1))
        
        context.setFillColor(UIColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0).cgColor)
        context.fill(CGRect(x: pageRect.width - 140, y: y - 1, width: 40, height: 3))
        
        context.setFillColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(x: pageRect.width - 90, y: y, width: 40, height: 1))
        
        y += 20
    }
    
    private func drawClassicHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let titleFont = UIFont.boldSystemFont(ofSize: 32)
        let companyName = businessInfo.name.isEmpty ? "Your Business Name" : businessInfo.name
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleSize = companyName.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2, y: y, width: titleSize.width, height: titleSize.height)
        companyName.draw(in: titleRect, withAttributes: titleAttributes)
        
        y += titleSize.height + 10
        
        // Classic double line
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2.0)
        context.move(to: CGPoint(x: 50, y: y))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: y))
        context.strokePath()
        
        y += 5
        
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 50, y: y))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: y))
        context.strokePath()
        
        y += 15
        
        // Invoice Title
        let invoiceTitle = "INVOICE"
        let invoiceTitleFont = UIFont.boldSystemFont(ofSize: 20)
        let invoiceTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: invoiceTitleFont,
            .foregroundColor: UIColor.systemOrange
        ]
        
        let invoiceTitleSize = invoiceTitle.size(withAttributes: invoiceTitleAttributes)
        let invoiceTitleRect = CGRect(x: (pageRect.width - invoiceTitleSize.width) / 2, y: y, width: invoiceTitleSize.width, height: invoiceTitleSize.height)
        invoiceTitle.draw(in: invoiceTitleRect, withAttributes: invoiceTitleAttributes)
        
        y += invoiceTitleSize.height + 20
    }
    
    private func drawMinimalistHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let titleFont = UIFont.systemFont(ofSize: 24, weight: .thin)
        let companyName = businessInfo.name.isEmpty ? "Your Business Name" : businessInfo.name
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleSize = companyName.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: 50, y: y, width: titleSize.width, height: titleSize.height)
        companyName.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Simple invoice label
        let invoiceTitle = "Invoice"
        let invoiceTitleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let invoiceTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: invoiceTitleFont,
            .foregroundColor: UIColor.gray
        ]
        
        let invoiceTitleSize = invoiceTitle.size(withAttributes: invoiceTitleAttributes)
        let invoiceTitleRect = CGRect(x: pageRect.width - 50 - invoiceTitleSize.width, y: y + titleSize.height - invoiceTitleSize.height, width: invoiceTitleSize.width, height: invoiceTitleSize.height)
        invoiceTitle.draw(in: invoiceTitleRect, withAttributes: invoiceTitleAttributes)
        
        y += titleSize.height + 30
    }
    
    private func drawCorporateHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        // Corporate blue header bar
        context.setFillColor(UIColor.systemBlue.cgColor)
        let headerBar = CGRect(x: 0, y: y, width: pageRect.width, height: 60)
        context.fill(headerBar)
        
        let titleFont = UIFont.boldSystemFont(ofSize: 26)
        let companyName = businessInfo.name.isEmpty ? "Your Business Name" : businessInfo.name
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.white
        ]
        
        let titleSize = companyName.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: 50, y: y + 15, width: titleSize.width, height: titleSize.height)
        companyName.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Professional Services subtitle
        let subtitle = "Professional Services"
        let subtitleFont = UIFont.systemFont(ofSize: 12)
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: subtitleFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        subtitle.draw(at: CGPoint(x: 50, y: y + 40), withAttributes: subtitleAttributes)
        
        // Invoice title in header
        let invoiceTitle = "INVOICE"
        let invoiceTitleFont = UIFont.boldSystemFont(ofSize: 22)
        let invoiceTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: invoiceTitleFont,
            .foregroundColor: UIColor.white
        ]
        
        let invoiceTitleSize = invoiceTitle.size(withAttributes: invoiceTitleAttributes)
        let invoiceTitleRect = CGRect(x: pageRect.width - 50 - invoiceTitleSize.width, y: y + 18, width: invoiceTitleSize.width, height: invoiceTitleSize.height)
        invoiceTitle.draw(in: invoiceTitleRect, withAttributes: invoiceTitleAttributes)
        
        y += 80
    }
    
    private func drawCreativeHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        // Creative circles background
        context.setFillColor(UIColor.systemPink.withAlphaComponent(0.3).cgColor)
        context.fillEllipse(in: CGRect(x: 30, y: y - 10, width: 80, height: 80))
        
        context.setFillColor(UIColor.systemOrange.withAlphaComponent(0.2).cgColor)
        context.fillEllipse(in: CGRect(x: pageRect.width - 100, y: y + 10, width: 60, height: 60))
        
        let titleFont = UIFont.boldSystemFont(ofSize: 28)
        let companyName = businessInfo.name.isEmpty ? "Your Business Name" : businessInfo.name
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.systemPink
        ]
        
        let titleSize = companyName.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: 120, y: y + 15, width: titleSize.width, height: titleSize.height)
        companyName.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Creative Invoice text
        let invoiceTitle = "Creative Invoice"
        let invoiceTitleFont = UIFont.italicSystemFont(ofSize: 16)
        let invoiceTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: invoiceTitleFont,
            .foregroundColor: UIColor.systemOrange
        ]
        
        invoiceTitle.draw(at: CGPoint(x: 120, y: y + 45), withAttributes: invoiceTitleAttributes)
        
        y += 90
    }
    
    private func drawFinanceHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let headerHeight: CGFloat = 140
        
        // Financial icon background
        let iconSize: CGFloat = 50
        let iconRect = CGRect(x: 50, y: y + 20, width: iconSize, height: iconSize)
        context.setFillColor(UIColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 1.0).cgColor)
        let iconPath = UIBezierPath(roundedRect: iconRect, cornerRadius: 8)
        context.addPath(iconPath.cgPath)
        context.fillPath()
        
        // Company name
        let companyName = businessInfo.name.isEmpty ? "FINANCIAL SERVICES" : businessInfo.name
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 1.0)
        ]
        companyName.draw(at: CGPoint(x: 110, y: y + 30), withAttributes: titleAttributes)
        
        // Certified Accounting subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(red: 0.0, green: 0.6, blue: 0.3, alpha: 1.0)
        ]
        "CERTIFIED ACCOUNTING".draw(at: CGPoint(x: 110, y: y + 55), withAttributes: subtitleAttributes)
        
        // INVOICE text
        let invoiceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 1.0)
        ]
        let invoiceText = "INVOICE"
        let invoiceSize = invoiceText.size(withAttributes: invoiceAttributes)
        invoiceText.draw(at: CGPoint(x: pageRect.width - invoiceSize.width - 50, y: y + 20), withAttributes: invoiceAttributes)
        
        // Financial Statement subtitle
        let statementAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(red: 0.0, green: 0.6, blue: 0.3, alpha: 1.0)
        ]
        "FINANCIAL STATEMENT".draw(at: CGPoint(x: pageRect.width - 150, y: y + 55), withAttributes: statementAttributes)
        
        // Financial grid separator
        y += 90
        let gridY = y
        for i in 0..<20 {
            let barColor = i % 3 == 0 ? UIColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 1.0) : UIColor(red: 0.0, green: 0.6, blue: 0.3, alpha: 0.3)
            context.setFillColor(barColor.cgColor)
            let barRect = CGRect(x: 50 + CGFloat(i * 25), y: gridY, width: 2, height: 12)
            context.fill(barRect)
        }
        
        y += 30
    }
    
    private func drawConsultingHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let headerHeight: CGFloat = 130
        
        // Professional consulting icon
        let iconSize: CGFloat = 55
        let iconRect = CGRect(x: 50, y: y + 20, width: iconSize, height: iconSize)
        context.setFillColor(UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 1.0).cgColor)
        let iconPath = UIBezierPath(ovalIn: iconRect)
        context.addPath(iconPath.cgPath)
        context.fillPath()
        
        // Inner circle stroke
        let innerIconRect = CGRect(x: 55, y: y + 25, width: 45, height: 45)
        context.setStrokeColor(UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0).cgColor)
        context.setLineWidth(2.0)
        let innerPath = UIBezierPath(ovalIn: innerIconRect)
        context.addPath(innerPath.cgPath)
        context.strokePath()
        
        // Company name
        let companyName = businessInfo.name.isEmpty ? "CONSULTING GROUP" : businessInfo.name
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 1.0)
        ]
        companyName.draw(at: CGPoint(x: 115, y: y + 35), withAttributes: titleAttributes)
        
        // Professional services subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0)
        ]
        "PROFESSIONAL SERVICES".draw(at: CGPoint(x: 115, y: y + 58), withAttributes: subtitleAttributes)
        
        // INVOICE text
        let invoiceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 1.0)
        ]
        let invoiceText = "INVOICE"
        let invoiceSize = invoiceText.size(withAttributes: invoiceAttributes)
        invoiceText.draw(at: CGPoint(x: pageRect.width - invoiceSize.width - 50, y: y + 25), withAttributes: invoiceAttributes)
        
        // Consulting services subtitle
        let consultingAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0)
        ]
        "CONSULTING SERVICES".draw(at: CGPoint(x: pageRect.width - 150, y: y + 58), withAttributes: consultingAttributes)
        
        // Professional consulting divider
        y += 90
        context.setFillColor(UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 50, y: y, width: pageRect.width - 100, height: 2))
        
        // Decorative dots
        y += 10
        let dotY = y
        let dotPositions: [CGFloat] = [100, 200, 300, 400]
        for (index, xPos) in dotPositions.enumerated() {
            context.setFillColor(UIColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0).cgColor)
            context.fill(CGRect(x: xPos, y: dotY, width: pageRect.width - 200, height: 1))
            
            context.setFillColor(UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 1.0).cgColor)
            context.fillEllipse(in: CGRect(x: xPos + 40, y: dotY - 2, width: 6, height: 6))
        }
        
        y += 20
    }
    
    private func drawBusinessAndClientInfo(context: CGContext, pageRect: CGRect, invoice: Invoice, businessInfo: BusinessInfo, y: inout CGFloat) {
        let headerFont = UIFont.boldSystemFont(ofSize: 14)
        let bodyFont = UIFont.systemFont(ofSize: 11)
        
        let startY = y
        
        // Business Info (Left Side)
        let fromAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        "FROM:".draw(at: CGPoint(x: 50, y: y), withAttributes: fromAttributes)
        y += 20
        
        let businessLines = [
            businessInfo.name.isEmpty ? "Your Business Name" : businessInfo.name,
            businessInfo.address.isEmpty ? "" : businessInfo.address,
            [businessInfo.city, businessInfo.state, businessInfo.zipCode].filter { !$0.isEmpty }.joined(separator: ", "),
            businessInfo.country.isEmpty ? "" : businessInfo.country,
            businessInfo.email.isEmpty ? "" : businessInfo.email,
            businessInfo.phone.isEmpty ? "" : businessInfo.phone
        ].filter { !$0.isEmpty }
        
        for line in businessLines {
            line.draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttributes)
            y += 15
        }
        
        // Client Info (Right Side)
        let billToX: CGFloat = pageRect.width / 2 + 25
        var clientY = startY
        
        "BILL TO:".draw(at: CGPoint(x: billToX, y: clientY), withAttributes: fromAttributes)
        clientY += 20
        
        let clientLines = [
            invoice.client.name,
            invoice.client.address.isEmpty ? "" : invoice.client.address,
            [invoice.client.city, invoice.client.state, invoice.client.zipCode].filter { !$0.isEmpty }.joined(separator: ", "),
            invoice.client.country.isEmpty ? "" : invoice.client.country,
            invoice.client.email.isEmpty ? "" : invoice.client.email,
            invoice.client.phone.isEmpty ? "" : invoice.client.phone
        ].filter { !$0.isEmpty }
        
        for line in clientLines {
            line.draw(at: CGPoint(x: billToX, y: clientY), withAttributes: bodyAttributes)
            clientY += 15
        }
        
        y = max(y, clientY)
    }
    
    private func drawInvoiceDetails(context: CGContext, pageRect: CGRect, invoice: Invoice, y: inout CGFloat) {
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let bodyFont = UIFont.systemFont(ofSize: 11)
        
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        // Invoice details in a row
        let detailsY = y
        
        // Invoice Number
        "Invoice #:".draw(at: CGPoint(x: 50, y: detailsY), withAttributes: headerAttributes)
        invoice.invoiceNumber.draw(at: CGPoint(x: 50, y: detailsY + 15), withAttributes: bodyAttributes)
        
        // Issue Date
        "Issue Date:".draw(at: CGPoint(x: 180, y: detailsY), withAttributes: headerAttributes)
        DateFormatter.mediumDateFormatter.string(from: invoice.issueDate).draw(at: CGPoint(x: 180, y: detailsY + 15), withAttributes: bodyAttributes)
        
        // Due Date
        "Due Date:".draw(at: CGPoint(x: 310, y: detailsY), withAttributes: headerAttributes)
        DateFormatter.mediumDateFormatter.string(from: invoice.dueDate).draw(at: CGPoint(x: 310, y: detailsY + 15), withAttributes: bodyAttributes)
        
        // Status
        "Status:".draw(at: CGPoint(x: 440, y: detailsY), withAttributes: headerAttributes)
        invoice.status.rawValue.draw(at: CGPoint(x: 440, y: detailsY + 15), withAttributes: bodyAttributes)
        
        y += 45
    }
    
    private func drawLineItemsTable(context: CGContext, pageRect: CGRect, invoice: Invoice, y: inout CGFloat) {
        let headerFont = UIFont.boldSystemFont(ofSize: 11)
        let bodyFont = UIFont.systemFont(ofSize: 10)
        
        let tableWidth = pageRect.width - 100
        let startX: CGFloat = 50
        
        // Table header background
        context.setFillColor(UIColor.systemGray6.cgColor)
        let headerRect = CGRect(x: startX, y: y, width: tableWidth, height: 25)
        context.fill(headerRect)
        
        // Table border
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        context.stroke(headerRect)
        
        // Column headers
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        "Description".draw(at: CGPoint(x: startX + 10, y: y + 7), withAttributes: headerAttributes)
        "Qty".draw(at: CGPoint(x: startX + 300, y: y + 7), withAttributes: headerAttributes)
        "Rate".draw(at: CGPoint(x: startX + 350, y: y + 7), withAttributes: headerAttributes)
        "Amount".draw(at: CGPoint(x: startX + 420, y: y + 7), withAttributes: headerAttributes)
        
        y += 25
        
        // Line items
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.black
        ]
        
        for item in invoice.lineItems {
            let rowHeight: CGFloat = 25
            let rowRect = CGRect(x: startX, y: y, width: tableWidth, height: rowHeight)
            
            // Alternate row background
            if invoice.lineItems.firstIndex(where: { $0.id == item.id })! % 2 == 1 {
                context.setFillColor(UIColor.systemGray6.withAlphaComponent(0.3).cgColor)
                context.fill(rowRect)
            }
            
            // Row border
            context.setStrokeColor(UIColor.lightGray.cgColor)
            context.setLineWidth(0.5)
            context.stroke(rowRect)
            
            // Item data
            item.description.draw(at: CGPoint(x: startX + 10, y: y + 7), withAttributes: bodyAttributes)
            item.quantity.decimalFormatted.draw(at: CGPoint(x: startX + 300, y: y + 7), withAttributes: bodyAttributes)
            item.unitPrice.currencyFormatted.draw(at: CGPoint(x: startX + 350, y: y + 7), withAttributes: bodyAttributes)
            item.total.currencyFormatted.draw(at: CGPoint(x: startX + 420, y: y + 7), withAttributes: bodyAttributes)
            
            y += rowHeight
        }
    }
    
    private func drawProfessionalLineItemsTable(context: CGContext, pageRect: CGRect, invoice: Invoice, y: inout CGFloat) {
        let headerFont = UIFont.boldSystemFont(ofSize: 11)
        let bodyFont = UIFont.systemFont(ofSize: 10)
        
        let tableWidth = pageRect.width - 100
        let startX: CGFloat = 50
        let cornerRadius: CGFloat = 15
        
        // Calculate total table height
        let headerHeight: CGFloat = 25
        let rowHeight: CGFloat = 40
        let totalRowsHeight = CGFloat(invoice.lineItems.count) * rowHeight
        let footerHeight: CGFloat = 50
        let totalTableHeight = headerHeight + totalRowsHeight + footerHeight
        
        // Draw rounded background for entire table
        let tablePath = UIBezierPath(roundedRect: CGRect(x: startX, y: y, width: tableWidth, height: totalTableHeight), cornerRadius: cornerRadius)
        context.setFillColor(UIColor.white.cgColor)
        context.addPath(tablePath.cgPath)
        context.fillPath()
        
        // Draw border
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.addPath(tablePath.cgPath)
        context.strokePath()
        
        // Table header
        let headerPath = UIBezierPath()
        headerPath.move(to: CGPoint(x: startX + cornerRadius, y: y))
        headerPath.addLine(to: CGPoint(x: startX + tableWidth - cornerRadius, y: y))
        headerPath.addQuadCurve(to: CGPoint(x: startX + tableWidth, y: y + cornerRadius), controlPoint: CGPoint(x: startX + tableWidth, y: y))
        headerPath.addLine(to: CGPoint(x: startX + tableWidth, y: y + headerHeight))
        headerPath.addLine(to: CGPoint(x: startX, y: y + headerHeight))
        headerPath.addLine(to: CGPoint(x: startX, y: y + cornerRadius))
        headerPath.addQuadCurve(to: CGPoint(x: startX + cornerRadius, y: y), controlPoint: CGPoint(x: startX, y: y))
        headerPath.close()
        
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.addPath(headerPath.cgPath)
        context.fillPath()
        
        // Column headers
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        "Description".draw(at: CGPoint(x: startX + 15, y: y + 7), withAttributes: headerAttributes)
        "Unit Price".draw(at: CGPoint(x: startX + 280, y: y + 7), withAttributes: headerAttributes)
        "Qty".draw(at: CGPoint(x: startX + 360, y: y + 7), withAttributes: headerAttributes)
        "Cost".draw(at: CGPoint(x: startX + 420, y: y + 7), withAttributes: headerAttributes)
        
        y += headerHeight
        
        // Line items
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.black
        ]
        
        let descriptionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.gray
        ]
        
        for (index, item) in invoice.lineItems.enumerated() {
            let rowRect = CGRect(x: startX, y: y, width: tableWidth, height: rowHeight)
            
            // Alternate row background (very light gray)
            if index % 2 == 1 {
                context.setFillColor(UIColor.systemGray6.withAlphaComponent(0.3).cgColor)
                context.fill(rowRect)
            }
            
            // Item data
            item.description.draw(at: CGPoint(x: startX + 15, y: y + 8), withAttributes: bodyAttributes)
            
            // Small description text
            "Lorem ipsum is simply dummy text of the printing.".draw(at: CGPoint(x: startX + 15, y: y + 22), withAttributes: descriptionAttributes)
            
            item.unitPrice.currencyFormatted.draw(at: CGPoint(x: startX + 280, y: y + 15), withAttributes: bodyAttributes)
            item.quantity.decimalFormatted.draw(at: CGPoint(x: startX + 370, y: y + 15), withAttributes: bodyAttributes)
            item.total.currencyFormatted.draw(at: CGPoint(x: startX + 420, y: y + 15), withAttributes: bodyAttributes)
            
            y += rowHeight
            
            // Draw separator line if not last item
            if index < invoice.lineItems.count - 1 {
                context.setStrokeColor(UIColor.lightGray.cgColor)
                context.setLineWidth(0.5)
                context.move(to: CGPoint(x: startX + 15, y: y))
                context.addLine(to: CGPoint(x: startX + tableWidth - 15, y: y))
                context.strokePath()
            }
        }
        
        // Subtotal and Total section
        let subtotalY = y + 10
        
        // Subtotal
        context.setFillColor(UIColor.systemGray6.withAlphaComponent(0.5).cgColor)
        let subtotalRect = CGRect(x: startX, y: subtotalY, width: tableWidth, height: 25)
        context.fill(subtotalRect)
        
        "Subtotal price".draw(at: CGPoint(x: startX + tableWidth - 180, y: subtotalY + 7), withAttributes: bodyAttributes)
        invoice.subtotal.currencyFormatted.draw(at: CGPoint(x: startX + tableWidth - 80, y: subtotalY + 7), withAttributes: bodyAttributes)
        
        // Total
        context.setFillColor(UIColor.systemGray6.cgColor)
        let totalRect = CGRect(x: startX, y: subtotalY + 25, width: tableWidth, height: 25)
        context.fill(totalRect)
        
        let totalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        
        "TOTAL PRICE".draw(at: CGPoint(x: startX + tableWidth - 180, y: subtotalY + 32), withAttributes: totalAttributes)
        invoice.total.currencyFormatted.draw(at: CGPoint(x: startX + tableWidth - 80, y: subtotalY + 32), withAttributes: totalAttributes)
        
        y = subtotalY + 50
    }
    
    private func drawTotalsSection(context: CGContext, pageRect: CGRect, invoice: Invoice, y: inout CGFloat) {
        let boldFont = UIFont.boldSystemFont(ofSize: 12)
        let bodyFont = UIFont.systemFont(ofSize: 11)
        
        let rightX: CGFloat = pageRect.width - 50
        let labelX: CGFloat = rightX - 150
        let valueX: CGFloat = rightX - 80
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        // Subtotal
        "Subtotal:".draw(at: CGPoint(x: labelX, y: y), withAttributes: bodyAttributes)
        invoice.subtotal.currencyFormatted.draw(at: CGPoint(x: valueX, y: y), withAttributes: bodyAttributes)
        y += 20
        
        // Tax
        "Tax (\((invoice.taxRate * 100).decimalFormatted)%):".draw(at: CGPoint(x: labelX, y: y), withAttributes: bodyAttributes)
        invoice.taxAmount.currencyFormatted.draw(at: CGPoint(x: valueX, y: y), withAttributes: bodyAttributes)
        y += 20
        
        // Horizontal line
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: labelX, y: y))
        context.addLine(to: CGPoint(x: rightX, y: y))
        context.strokePath()
        y += 10
        
        // Total
        "TOTAL:".draw(at: CGPoint(x: labelX, y: y), withAttributes: boldAttributes)
        invoice.total.currencyFormatted.draw(at: CGPoint(x: valueX, y: y), withAttributes: boldAttributes)
        y += 25
    }
    
    private func drawNotesSection(context: CGContext, pageRect: CGRect, invoice: Invoice, y: inout CGFloat) {
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let bodyFont = UIFont.systemFont(ofSize: 10)
        
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        "Notes:".draw(at: CGPoint(x: 50, y: y), withAttributes: headerAttributes)
        y += 20
        
        let notesRect = CGRect(x: 50, y: y, width: pageRect.width - 100, height: 60)
        invoice.notes.draw(in: notesRect, withAttributes: bodyAttributes)
        y += 60
    }
    
    private func drawFooter(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo) {
        let footerFont = UIFont.systemFont(ofSize: 9)
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.gray
        ]
        
        let footerY = pageRect.height - 50
        
        // Horizontal line
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 50, y: footerY - 10))
        context.addLine(to: CGPoint(x: pageRect.width - 50, y: footerY - 10))
        context.strokePath()
        
        let footerText = "Thank you for your business!"
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerX = (pageRect.width - footerSize.width) / 2
        
        footerText.draw(at: CGPoint(x: footerX, y: footerY), withAttributes: footerAttributes)
        
        // Website/contact info
        if !businessInfo.website.isEmpty {
            businessInfo.website.draw(at: CGPoint(x: 50, y: footerY + 15), withAttributes: footerAttributes)
        }
        
        "Generated by Invoicious".draw(at: CGPoint(x: pageRect.width - 150, y: footerY + 15), withAttributes: footerAttributes)
    }
    
    private func drawTechnologyHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let headerHeight: CGFloat = 140
        
        // Technology gradient background for icon
        let iconSize: CGFloat = 60
        let iconRect = CGRect(x: 50, y: y + 20, width: iconSize, height: iconSize)
        
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), 
                                colors: [UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor, 
                                        UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0).cgColor] as CFArray, 
                                locations: nil)!
        context.saveGState()
        let iconPath = UIBezierPath(roundedRect: iconRect, cornerRadius: 12)
        context.addPath(iconPath.cgPath)
        context.clip()
        context.drawLinearGradient(gradient, 
                                 start: CGPoint(x: iconRect.minX, y: iconRect.minY), 
                                 end: CGPoint(x: iconRect.maxX, y: iconRect.maxY), 
                                 options: [])
        context.restoreGState()
        
        // Company name
        let companyName = businessInfo.name.isEmpty ? "TECH SOLUTIONS" : businessInfo.name
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        ]
        companyName.draw(at: CGPoint(x: 120, y: y + 35), withAttributes: titleAttributes)
        
        // Technology services subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
        ]
        "TECHNOLOGY SERVICES".draw(at: CGPoint(x: 120, y: y + 58), withAttributes: subtitleAttributes)
        
        // INVOICE text
        let invoiceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        ]
        let invoiceText = "INVOICE"
        let invoiceSize = invoiceText.size(withAttributes: invoiceAttributes)
        invoiceText.draw(at: CGPoint(x: pageRect.width - invoiceSize.width - 50, y: y + 25), withAttributes: invoiceAttributes)
        
        // Tech-style bars
        y += 90
        let barsY = y
        let barColors = [UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0), 
                        UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.6)]
        
        for i in 0..<30 {
            let barHeight = CGFloat.random(in: 4...12)
            let barColor = i % 4 == 0 ? barColors[0] : barColors[1]
            context.setFillColor(barColor.cgColor)
            let barRect = CGRect(x: 50 + CGFloat(i * 17), y: barsY, width: 1, height: barHeight)
            let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 0.5)
            context.addPath(barPath.cgPath)
            context.fillPath()
        }
        
        y += 30
    }
    
    private func drawLegalHeader(context: CGContext, pageRect: CGRect, businessInfo: BusinessInfo, y: inout CGFloat) {
        let headerHeight: CGFloat = 140
        
        // Formal legal icon background
        let iconSize: CGFloat = 50
        let iconRect = CGRect(x: 50, y: y + 20, width: iconSize, height: iconSize)
        context.setFillColor(UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
        let iconPath = UIBezierPath(roundedRect: iconRect, cornerRadius: 2)
        context.addPath(iconPath.cgPath)
        context.fillPath()
        
        // Company name
        let companyName = businessInfo.name.isEmpty ? "LAW OFFICES" : businessInfo.name
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        ]
        companyName.draw(at: CGPoint(x: 110, y: y + 30), withAttributes: titleAttributes)
        
        // Attorneys at law subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        ]
        "ATTORNEYS AT LAW".draw(at: CGPoint(x: 110, y: y + 55), withAttributes: subtitleAttributes)
        
        // INVOICE text
        let invoiceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        ]
        let invoiceText = "INVOICE"
        let invoiceSize = invoiceText.size(withAttributes: invoiceAttributes)
        invoiceText.draw(at: CGPoint(x: pageRect.width - invoiceSize.width - 50, y: y + 20), withAttributes: invoiceAttributes)
        
        // Legal services subtitle
        let legalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        ]
        "LEGAL SERVICES".draw(at: CGPoint(x: pageRect.width - 120, y: y + 55), withAttributes: legalAttributes)
        
        // Formal legal separator
        y += 90
        context.setFillColor(UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 50, y: y, width: pageRect.width - 100, height: 3))
        
        y += 5
        context.setFillColor(UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 50, y: y, width: pageRect.width - 100, height: 1))
        
        // Decorative legal elements
        y += 10
        let decorativeY = y
        let decorativeElements: [CGFloat] = [150, 300, 450]
        for xPos in decorativeElements {
            context.setFillColor(UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
            context.fill(CGRect(x: xPos, y: decorativeY, width: 80, height: 1))
            
            // Decorative dot
            let dotAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
            ]
            "•".draw(at: CGPoint(x: xPos + 90, y: decorativeY - 8), withAttributes: dotAttributes)
        }
        
        y += 25
    }
}

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}