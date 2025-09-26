import Foundation

// MARK: - Help & Support Content
struct HelpSupportContent {
    
    // MARK: - FAQ Data Structure
    struct FAQItem: Identifiable, Hashable {
        let id = UUID()
        let question: String
        let answer: String
        let category: FAQCategory
        let tags: [String]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: FAQItem, rhs: FAQItem) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum FAQCategory: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case invoices = "Invoices & Billing" 
        case payments = "Payments & Tracking"
        case templates = "Templates & Customization"
        case clients = "Client Management"
        case estimates = "Estimates & Quotes"
        case troubleshooting = "Troubleshooting"
        case advanced = "Advanced Features"
    }
    
    // MARK: - Complete FAQ Database
    static let allFAQs: [FAQItem] = [
        
        // MARK: - Getting Started
        FAQItem(
            question: "How do I create my first invoice?",
            answer: """
            Creating your first invoice is easy:
            
            1. **Setup Business Information**: Go to Settings → Business Info and enter your business name, address, email, and contact details.
            
            2. **Add a Client**: Go to Clients tab and tap "Add Client" to create your first client with their contact information.
            
            3. **Create Invoice**: 
               • Tap the "+" button on the Dashboard or Invoices tab
               • Select your client from the list
               • Add line items with descriptions, quantities, and rates
               • Set payment terms and due date
               • Add any notes or special instructions
               • Tap "Save" to create the invoice
            
            4. **Send to Client**: Use the "Send" option to email the invoice directly to your client with professional PDF attachment.
            
            Your invoice will start as "Draft" status and automatically change to "Sent" when emailed to the client.
            """,
            category: .gettingStarted,
            tags: ["first invoice", "create", "setup", "business info"]
        ),
        
        FAQItem(
            question: "What information do I need to set up my business profile?",
            answer: """
            For professional invoices, you should set up:
            
            **Required Information:**
            • Business/Company Name
            • Business Email Address
            • Business Phone Number
            
            **Recommended Information:**
            • Complete Business Address
            • City, State, ZIP Code
            • Country
            • Website URL
            • Business Logo (if available)
            • Tax ID/EIN Number
            • Payment Terms and Instructions
            
            **How to Add:**
            1. Go to Settings tab
            2. Tap "Business Information"
            3. Fill in all relevant fields
            4. Tap "Save"
            
            This information will appear on all your invoices and estimates, making them look professional and complete.
            """,
            category: .gettingStarted,
            tags: ["business info", "setup", "profile", "company details"]
        ),
        
        // MARK: - Invoices & Billing
        FAQItem(
            question: "How do I send an invoice to a client?",
            answer: """
            There are two ways to send invoices:
            
            **Method 1: Detailed Send (Recommended)**
            1. Open the invoice from your Invoices list
            2. Tap the "Share" button in the action buttons
            3. Choose "Send Invoice"
            4. Verify client email address
            5. Select PDF template (Classic, Corporate, Creative, etc.)
            6. Add a personal message (optional)
            7. Enable tracking options:
               • Include Payment Instructions
               • Enable Read Receipts
            8. Review the email preview
            9. Tap "Send Now"
            
            **Method 2: Quick Send**
            1. Open the invoice
            2. Use "Quick Send" for immediate sending with default settings
            
            **Status Changes:**
            • Invoice status automatically changes from "Draft" → "Sent"
            • You'll receive delivery confirmations and read receipts
            • Track opens, downloads, and payment status
            
            The client receives a professional PDF attachment with payment instructions.
            """,
            category: .invoices,
            tags: ["send invoice", "email", "client", "PDF", "status"]
        ),
        
        FAQItem(
            question: "What do the different invoice statuses mean?",
            answer: """
            Invoice statuses help you track the billing process:
            
            **📝 Draft**
            • Newly created invoice not yet sent
            • Can be edited, modified, or deleted
            • Not visible to client
            
            **📤 Sent** 
            • Invoice emailed to client successfully
            • Changes from Draft automatically when sent
            • Client can view and download
            • Payment is pending
            
            **👀 Viewed**
            • Client has opened/viewed the invoice
            • Tracked via email read receipts
            • Shows engagement but no payment yet
            
            **💰 Paid**
            • Full payment received and recorded
            • Invoice balance is $0.00
            • Automatically set when payments equal total amount
            
            **⚠️ Overdue**
            • Due date has passed without full payment
            • Automatically calculated based on due date
            • Requires follow-up action
            
            **❌ Cancelled**
            • Invoice voided or cancelled
            • No payment expected
            • Can be manually set
            
            **🔄 Partially Paid**
            • Some payment received, but balance remains
            • Shows in payment tracking
            • Requires additional payment
            
            Status changes happen automatically based on actions (sending, payments) or dates (overdue).
            """,
            category: .invoices,
            tags: ["status", "draft", "sent", "paid", "overdue", "workflow"]
        ),
        
        FAQItem(
            question: "How do I edit or modify an existing invoice?",
            answer: """
            Invoice editing depends on the current status:
            
            **Draft Invoices (Full Editing)**
            1. Go to Invoices tab
            2. Tap the Draft invoice
            3. Tap "Edit" button (top right)
            4. Modify any details:
               • Client information
               • Line items (add, edit, delete)
               • Amounts and quantities
               • Due date and terms
               • Notes and descriptions
            5. Tap "Save" to update
            
            **Sent/Paid Invoices (Limited Editing)**
            • Cannot modify amounts or line items
            • Can update notes and internal information
            • For major changes, consider:
              - Creating a credit memo
              - Issuing a new corrected invoice
              - Adding payment adjustments
            
            **Best Practices:**
            • Review carefully before sending
            • Use Draft status for work-in-progress
            • Communicate changes with clients
            • Keep audit trail of modifications
            
            **Duplicate Feature:**
            • Use "Duplicate" to create similar invoices
            • Saves time for recurring clients
            • Creates new Draft with same details
            """,
            category: .invoices,
            tags: ["edit invoice", "modify", "draft", "changes", "duplicate"]
        ),
        
        // MARK: - Payments & Tracking  
        FAQItem(
            question: "How does the Pay option work?",
            answer: """
            The **Pay** button opens the Payment Tracking system where you can:
            
            **Payment Management:**
            • Record payments received from clients
            • Track multiple partial payments
            • Monitor remaining balance
            • View complete payment history
            
            **Recording Payments:**
            1. Open invoice → Tap "Pay" button
            2. Tap "Add Payment"
            3. Enter payment details:
               • Amount received
               • Payment date
               • Payment method (Cash, Check, Credit Card, Bank Transfer, PayPal, etc.)
               • Reference number (check #, transaction ID)
               • Optional notes
            4. Tap "Save"
            
            **Automatic Status Updates:**
            • **Partial Payment**: Status → "Partially Paid"
            • **Full Payment**: Status → "Paid" 
            • Balance automatically calculated
            • Dashboard metrics updated
            
            **Payment History:**
            • View all payments in chronological order
            • Edit or delete payment records
            • Export payment data
            • Generate payment reports
            
            **Quick Actions:**
            • "Quick Fill Remaining Balance" button
            • Payment method icons and organization
            • Real-time balance calculations
            
            This system helps you maintain accurate financial records and track which invoices need follow-up.
            """,
            category: .payments,
            tags: ["pay button", "payment tracking", "record payment", "balance", "status"]
        ),
        
        FAQItem(
            question: "How can I track if clients have viewed my invoices?",
            answer: """
            Invoicious provides comprehensive invoice tracking:
            
            **Email Tracking Features:**
            • **Delivery Confirmations**: Know when email was delivered
            • **Read Receipts**: See when client opened the email
            • **PDF Download Tracking**: Track when invoice PDF is downloaded
            • **View Count**: Number of times invoice was viewed
            • **Last Viewed Date**: Most recent viewing timestamp
            
            **How to Enable Tracking:**
            1. When sending invoice, ensure "Enable Read Receipts" is ON
            2. This is enabled by default for all invoices
            3. Tracking works automatically once enabled
            
            **Viewing Tracking Data:**
            
            **Method 1: Invoice Detail View**
            • Open any invoice
            • Scroll to "Send History" section  
            • See delivery status, open dates, and view counts
            
            **Method 2: Invoice Tracking Page**
            • Go to More → Invoice Tracking
            • Comprehensive tracking dashboard
            • Filter by status, date ranges
            • Export tracking reports
            
            **Method 3: Send View**
            • When preparing to send/resend
            • Shows previous send history
            • Tracking stats and engagement metrics
            
            **Tracking Insights:**
            • **Green checkmarks**: Successfully delivered and opened
            • **Clock icons**: Delivered but not yet opened  
            • **View counts**: Client engagement level
            • **Time stamps**: When actions occurred
            
            Use this data to follow up appropriately and improve client communication.
            """,
            category: .payments,
            tags: ["tracking", "read receipts", "client views", "email tracking", "engagement"]
        ),
        
        // MARK: - Templates & Customization
        FAQItem(
            question: "What invoice templates are available and how do I choose one?",
            answer: """
            Invoicious offers 9 professional invoice templates:
            
            **Available Templates:**
            
            **📋 Classic** - Timeless and professional design
            • Traditional layout with clean typography
            • Suitable for most business types
            • Default template for new invoices
            
            **✨ Minimalist** - Clean and simple layout  
            • Ultra-clean design with minimal elements
            • Perfect for modern, tech-focused businesses
            • Emphasizes content over decoration
            
            **🏢 Corporate** - Formal business style
            • Professional blue header
            • Ideal for large corporations and formal industries
            • Structured, traditional appearance
            
            **🎨 Creative** - Modern and artistic approach
            • Colorful circles and creative elements
            • Great for design agencies, studios, and creative services
            • Eye-catching and memorable
            
            **👔 Executive** - Premium executive style
            • Gold accents and premium feel
            • Perfect for high-end services and consulting
            • Sophisticated and luxurious appearance
            
            **💰 Finance** - Professional financial format
            • Green color scheme with financial icons
            • Ideal for accounting, bookkeeping, and financial services
            • Includes professional grid elements
            
            **🤝 Consulting** - Clean consulting style
            • Professional circles and structured layout
            • Perfect for consulting and professional services
            • Balanced design with clear information hierarchy
            
            **💻 Technology** - Modern tech-focused design
            • Blue gradient and technical elements
            • Great for IT services, software companies, and tech startups
            • Contemporary and innovative feel
            
            **⚖️ Legal** - Formal legal document style
            • Traditional brown/gold legal colors
            • Designed for law firms and legal services
            • Formal, authoritative appearance
            
            **How to Choose Templates:**
            
            **For New Invoices:**
            1. During invoice creation, select template in the details section
            2. Preview shows how your invoice will look
            3. Can change before sending
            
            **When Sending:**
            1. In Send view, use template dropdown
            2. Preview regenerates automatically
            3. Choose best template for specific client
            
            **Tips for Template Selection:**
            • Match your industry and brand
            • Consider client expectations
            • Use consistent templates for brand recognition
            • Creative templates for creative industries
            • Conservative templates for traditional businesses
            """,
            category: .templates,
            tags: ["templates", "PDF", "design", "customization", "branding"]
        ),
        
        // MARK: - Client Management
        FAQItem(
            question: "How do I manage and organize my clients?",
            answer: """
            Effective client management is key to streamlined invoicing:
            
            **Adding New Clients:**
            1. Go to Clients tab
            2. Tap "Add Client" (+) button
            3. Enter client information:
               • **Required**: Name and Email
               • **Optional**: Company, Phone, Address
               • Complete address for professional invoices
            4. Tap "Save"
            
            **Client Information Fields:**
            • **Personal**: First Name, Last Name
            • **Business**: Company Name
            • **Contact**: Email (required for sending), Phone
            • **Address**: Street, City, State, ZIP, Country
            • **Notes**: Internal notes and special instructions
            
            **Managing Existing Clients:**
            • **Edit**: Tap client → "Edit" → Update information
            • **View History**: See all invoices and estimates for client
            • **Communication**: Track email history and interactions
            • **Notes**: Add internal notes for team reference
            
            **Client Search & Organization:**
            • **Search Bar**: Find clients by name, company, or email
            • **Sort Options**: Alphabetical, recent activity, total billed
            • **Filters**: Active clients, recent clients, top clients
            
            **Client Analytics:**
            • Total amount billed per client
            • Payment history and reliability
            • Average invoice amount
            • Outstanding balance
            • Most recent activity
            
            **Best Practices:**
            • Keep client information updated
            • Use consistent naming conventions
            • Add detailed contact information
            • Include billing addresses for accuracy
            • Use notes for special payment terms or preferences
            • Regular cleanup of inactive clients
            
            **Bulk Operations:**
            • Export client list to CSV
            • Import clients from spreadsheet
            • Mass email capabilities for announcements
            """,
            category: .clients,
            tags: ["clients", "contact management", "customer database", "organization"]
        ),
        
        // MARK: - Estimates & Quotes
        FAQItem(
            question: "What's the difference between estimates and invoices, and how do I convert them?",
            answer: """
            **Estimates vs Invoices:**
            
            **📋 Estimates (Quotes)**
            • **Purpose**: Propose pricing before work begins
            • **Legal Status**: Not a demand for payment
            • **Client Action**: Client can accept, decline, or negotiate
            • **Timeline**: Include expiration date
            • **Status**: Draft → Sent → Accepted/Declined/Expired
            
            **💰 Invoices** 
            • **Purpose**: Request payment for completed work/services
            • **Legal Status**: Formal payment request
            • **Client Action**: Payment due by specified date
            • **Timeline**: Include due date for payment
            • **Status**: Draft → Sent → Paid/Overdue
            
            **Creating Estimates:**
            1. Go to Estimates tab
            2. Tap "Add Estimate" (+)
            3. Select client and add line items
            4. Set expiration date (validity period)
            5. Add terms and conditions
            6. Save and send to client
            
            **Converting Estimates to Invoices:**
            
            **One-Click Conversion:**
            1. Open accepted estimate
            2. Tap the prominent "Convert to Invoice" button
            3. System automatically:
               • Creates new invoice with same details
               • Copies all line items and amounts
               • Sets client information
               • Marks estimate as "Accepted"
               • Assigns new invoice number
               • Sets draft status for review before sending
            
            **Manual Process:**
            1. Create new invoice
            2. Copy details from estimate
            3. Update amounts if needed
            4. Send to client
            
            **Status Management:**
            • **Estimate**: Draft → Sent → Accepted → Converted
            • **Invoice**: Draft → Sent → Paid
            
            **Best Practices:**
            • Always get estimate approval before starting work
            • Include clear scope and terms in estimates
            • Set reasonable expiration dates (30-60 days)
            • Convert accepted estimates promptly
            • Keep estimate and invoice numbering separate
            • Track conversion rates for business insights
            
            **Workflow Benefits:**
            • Clear project approval process
            • Reduced payment disputes
            • Professional client communication
            • Accurate project scoping
            • Better cash flow management
            """,
            category: .estimates,
            tags: ["estimates", "quotes", "conversion", "workflow", "approval process"]
        ),
        
        // MARK: - Troubleshooting
        FAQItem(
            question: "Why are my invoices not sending via email?",
            answer: """
            Common email sending issues and solutions:
            
            **Check Email Address:**
            • Verify client email is correct and complete
            • Look for typos in email address
            • Ensure no spaces before/after email
            • Valid format: user@domain.com
            
            **Device Settings:**
            • **iPhone/iPad**: Go to Settings → Mail → Default Account
            • Ensure you have a configured email account
            • Check if email account is active and working
            • Try sending a regular email to test
            
            **Network Connection:**
            • Ensure stable Wi-Fi or cellular connection
            • Try switching between Wi-Fi and cellular
            • Test internet connection with other apps
            
            **PDF Generation Issues:**
            • Large invoices may take time to generate PDF
            • Wait for "PDF generated successfully" message
            • Try simpler template if having issues
            • Restart app if PDF generation fails
            
            **Email Provider Issues:**
            • Some corporate email servers block automated emails
            • Try different email account if available
            • Check with IT department for restrictions
            • Gmail, iCloud, and Outlook generally work well
            
            **Troubleshooting Steps:**
            1. **Test with Simple Invoice**: Create basic invoice and try sending
            2. **Check Send History**: Look for error messages in send history
            3. **Try Different Template**: Use Classic template to rule out template issues
            4. **Manual Alternative**: Export PDF and send manually via regular email
            5. **Restart App**: Close and reopen Invoicious
            6. **Update App**: Ensure you have latest version
            
            **Alternative Solutions:**
            • Use "Share" → "Save to Files" → Email manually
            • Print invoice and deliver physically
            • Share PDF via messaging apps
            • Use cloud storage links (Dropbox, Google Drive)
            
            **Success Indicators:**
            • Green checkmark = Email sent successfully
            • Delivery confirmation in send history
            • Client confirmation of receipt
            
            If problems persist, try the manual export option or contact support with specific error messages.
            """,
            category: .troubleshooting,
            tags: ["email problems", "sending issues", "troubleshooting", "PDF", "technical support"]
        ),
        
        FAQItem(
            question: "How do I backup and restore my invoice data?",
            answer: """
            Data protection is crucial for your business records:
            
            **Automatic iCloud Backup:**
            • Invoicious automatically syncs with iCloud when enabled
            • Backs up invoices, clients, estimates, and settings
            • Works across all your iOS devices
            • Enable: Settings → [Your Name] → iCloud → Invoicious (ON)
            
            **Manual Export Options:**
            
            **Export Individual Invoices:**
            1. Open invoice → Share → Save PDF
            2. Choose location (Files, Dropbox, etc.)
            3. Creates permanent PDF record
            
            **Bulk Data Export:**
            1. Go to Settings → Export Data
            2. Select data types:
               • All Invoices and line items
               • Client contact database  
               • Payment history and records
               • Estimates and quotes
               • Business information and settings
               • Financial summary reports
            3. Choose format: CSV spreadsheet
            4. Export creates comprehensive backup file
            5. Save to secure location (cloud storage recommended)
            
            **What Gets Exported:**
            • Complete invoice details and line items
            • Client information and contacts
            • Payment records and history
            • Estimate data and conversions
            • Financial metrics and totals
            • Send history and tracking data
            
            **Restoration Process:**
            • **Same Device**: Data restores automatically from iCloud
            • **New Device**: Sign in with same Apple ID, enable iCloud sync
            • **Manual Restore**: Import CSV data into new installation
            
            **Best Backup Practices:**
            1. **Enable iCloud Sync**: Primary backup method
            2. **Regular Exports**: Monthly CSV exports to external storage
            3. **PDF Archives**: Save important invoices as PDFs
            4. **Multiple Locations**: Store backups in 2-3 different places
            5. **Test Restores**: Periodically verify backups work
            
            **Storage Recommendations:**
            • **iCloud Drive**: Automatic, secure, accessible
            • **Dropbox/Google Drive**: Cross-platform access
            • **External Drive**: Local backup for extra security
            • **Email to Self**: Quick backup for critical data
            
            **Security Notes:**
            • All exports are encrypted and secure
            • Client data protected with privacy safeguards
            • Only you have access to your business data
            • Regular backups prevent data loss from device issues
            
            **Recovery Scenarios:**
            • **Lost Device**: Restore from iCloud to new device
            • **Corrupted Data**: Import from CSV backup
            • **Accidental Deletion**: Recover from recent export
            • **Device Upgrade**: Transfer via iCloud sync
            """,
            category: .troubleshooting,
            tags: ["backup", "export", "data recovery", "iCloud", "restore"]
        ),
        
        // MARK: - Advanced Features
        FAQItem(
            question: "How do I set up recurring invoices for regular clients?",
            answer: """
            Recurring invoices automate billing for regular services:
            
            **When to Use Recurring Invoices:**
            • Monthly retainer clients
            • Subscription services
            • Regular maintenance contracts
            • Ongoing consulting agreements
            • Gym memberships, software licenses
            • Any predictable, repeating billing
            
            **Setting Up Recurring Invoices:**
            1. Create a standard invoice template with your regular client
            2. Go to More → Recurring Invoices
            3. Tap "Add Recurring Invoice"
            4. Configure settings:
               • **Client**: Select from your client list
               • **Invoice Template**: Choose existing invoice to repeat
               • **Frequency**: Weekly, Monthly, Quarterly, Annually
               • **Start Date**: When recurring billing begins
               • **End Date**: When to stop (optional)
               • **Auto-Send**: Automatically email to client
            5. Save configuration
            
            **Frequency Options:**
            • **Weekly**: Every 7 days
            • **Monthly**: Same date each month
            • **Quarterly**: Every 3 months  
            • **Annually**: Same date each year
            • **Custom**: Set specific day intervals
            
            **Automated Features:**
            • **Auto-Generation**: Creates new invoice automatically
            • **Smart Numbering**: Sequential invoice numbers
            • **Auto-Send Option**: Emails client automatically
            • **Status Tracking**: Monitors all generated invoices
            • **Payment Tracking**: Links to payment system
            
            **Managing Recurring Invoices:**
            • **View Schedule**: See all upcoming recurring bills
            • **Modify Settings**: Change frequency, amounts, or clients
            • **Pause/Resume**: Temporarily stop without deleting
            • **End Series**: Stop recurring with end date
            • **Manual Generation**: Create next invoice early
            
            **Generated Invoice Features:**
            • Creates as "Draft" status for review
            • Uses current business information
            • Updates dates automatically
            • Maintains line items and amounts
            • Can be edited before sending
            • Full tracking and payment features
            
            **Monitoring & Reports:**
            • Dashboard shows recurring revenue metrics
            • Track success rate of recurring billing
            • View client payment reliability
            • Export recurring billing reports
            • Monitor overdue recurring payments
            
            **Best Practices:**
            • Review generated invoices before auto-sending
            • Update recurring invoice templates when rates change
            • Set clear payment terms with recurring clients
            • Monitor for failed payments or declined cards
            • Communicate any changes to clients in advance
            • Use consistent invoice templates for brand recognition
            
            **Troubleshooting:**
            • **Missed Generation**: Check app regularly to ensure proper operation
            • **Email Failures**: Monitor send history for delivery issues
            • **Amount Changes**: Update template and it applies to future invoices
            • **Client Changes**: Update client info in recurring settings
            """,
            category: .advanced,
            tags: ["recurring invoices", "automation", "regular billing", "subscriptions", "retainers"]
        ),
        
        FAQItem(
            question: "What reports and analytics are available?",
            answer: """
            Invoicious provides comprehensive business analytics:
            
            **Dashboard Overview:**
            • **Total Revenue**: All-time earnings with growth trends
            • **Pending Amount**: Outstanding invoices awaiting payment  
            • **Active Clients**: Current client count with monthly growth
            • **Total Invoices**: Invoice volume with tracking metrics
            
            **Financial Reports:**
            
            **Revenue Analysis:**
            • Monthly/quarterly/yearly revenue trends
            • Paid vs pending amounts breakdown
            • Revenue by client rankings
            • Average invoice amount calculations
            • Payment timeline analysis
            
            **Invoice Analytics:**
            • Invoice status distribution (Draft, Sent, Paid, Overdue)
            • Sending success rates and delivery metrics
            • Average time from send to payment
            • Most used invoice templates
            • Invoice volume trends over time
            
            **Client Performance:**
            • Top clients by revenue
            • Payment reliability scores
            • Client lifetime value
            • New vs returning client ratios
            • Client growth and retention rates
            
            **Payment Insights:**
            • Payment method preferences
            • Average payment collection time
            • Overdue payment patterns
            • Partial payment frequency
            • Collection success rates
            
            **Tracking & Engagement:**
            • Email delivery success rates
            • Invoice view and open rates
            • PDF download statistics
            • Client engagement metrics
            • Follow-up effectiveness
            
            **Accessing Reports:**
            
            **Dashboard Cards:**
            • Real-time key metrics on home screen
            • Tap any metric for detailed breakdown
            • Visual charts and trend indicators
            
            **Invoice Tracking:**
            • Go to More → Invoice Tracking
            • Comprehensive tracking dashboard
            • Filter by date ranges, status, clients
            • Export detailed tracking reports
            
            **Export Features:**
            • CSV export with complete transaction data
            • Filter by date ranges and criteria
            • Include line-item details
            • Financial summaries and totals
            • Import into Excel, QuickBooks, or other systems
            
            **Report Categories in Export:**
            • **Invoice Data**: Complete invoice details and history
            • **Client Information**: Contact details and communication history
            • **Payment Records**: All payment transactions and methods
            • **Line Items**: Detailed product/service breakdown
            • **Financial Summary**: Revenue, pending, overdue totals
            • **Tracking Data**: Email sends, opens, downloads
            
            **Business Intelligence:**
            • Identify best-performing clients
            • Optimize invoice templates and timing
            • Improve collection processes
            • Track business growth trends
            • Plan cash flow and forecasting
            • Monitor client satisfaction indicators
            
            **Custom Analysis:**
            • Export data to Excel for custom reports
            • Create pivot tables for advanced analysis
            • Track specific metrics important to your business
            • Compare performance across time periods
            • Analyze seasonal business patterns
            
            Use these insights to make informed business decisions and optimize your invoicing processes.
            """,
            category: .advanced,
            tags: ["reports", "analytics", "dashboard", "metrics", "business intelligence", "export"]
        )
    ]
    
    // MARK: - Helper Methods
    static func getFAQs(for category: FAQCategory) -> [FAQItem] {
        return allFAQs.filter { $0.category == category }
    }
    
    static func searchFAQs(_ searchText: String) -> [FAQItem] {
        guard !searchText.isEmpty else { return allFAQs }
        
        let lowercasedSearch = searchText.lowercased()
        return allFAQs.filter { faq in
            faq.question.lowercased().contains(lowercasedSearch) ||
            faq.answer.lowercased().contains(lowercasedSearch) ||
            faq.tags.contains { $0.lowercased().contains(lowercasedSearch) }
        }
    }
    
    static func getMostRelevantFAQs() -> [FAQItem] {
        // Return most commonly needed FAQs
        let priorityQuestions = [
            "How do I create my first invoice?",
            "How do I send an invoice to a client?",
            "How does the Pay option work?",
            "What do the different invoice statuses mean?",
            "How do I manage and organize my clients?"
        ]
        
        return allFAQs.filter { faq in
            priorityQuestions.contains(faq.question)
        }
    }
}

// MARK: - Support Contact Information
struct SupportInfo {
    static let websiteURL = "https://invoicious.app"
    static let supportEmail = "support@invoicious.app"
    static let documentationURL = "https://help.invoicious.app"
    
    struct ContactOption {
        let title: String
        let subtitle: String
        let icon: String
        let action: ContactAction
    }
    
    enum ContactAction {
        case website
        case email
        case documentation
        case inAppFAQ
    }
    
    static let contactOptions: [ContactOption] = [
        ContactOption(
            title: "FAQ", 
            subtitle: "Find answers to common questions",
            icon: "questionmark.circle.fill",
            action: .inAppFAQ
        ),
        ContactOption(
            title: "Email Support",
            subtitle: "Get help from our support team", 
            icon: "envelope.fill",
            action: .email
        ),
        ContactOption(
            title: "Website",
            subtitle: "Visit our website for more information",
            icon: "globe",
            action: .website
        ),
        ContactOption(
            title: "Documentation", 
            subtitle: "Detailed guides and tutorials",
            icon: "book.fill",
            action: .documentation
        )
    ]
}