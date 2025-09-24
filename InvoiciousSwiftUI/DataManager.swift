import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var clients: [Client] = []
    @Published var invoices: [Invoice] = []
    @Published var estimates: [Estimate] = []
    @Published var businessInfo: BusinessInfo = BusinessInfo()
    @Published var timeEntries: [TimeEntry] = []
    @Published var projects: [Project] = []
    @Published var recurringInvoices: [RecurringInvoice] = []
    @Published var activeTimeEntry: TimeEntry?
    
    private let clientsKey = "SavedClients"
    private let invoicesKey = "SavedInvoices"
    private let estimatesKey = "SavedEstimates"
    private let businessInfoKey = "SavedBusinessInfo"
    private let timeEntriesKey = "SavedTimeEntries"
    private let projectsKey = "SavedProjects"
    private let recurringInvoicesKey = "SavedRecurringInvoices"
    
    private var timer: Timer?
    
    init() {
        loadData()
    }
    
    func saveData() {
        saveClients()
        saveInvoices()
        saveEstimates()
        saveBusinessInfo()
        saveTimeEntries()
        saveProjects()
        saveRecurringInvoices()
    }
    
    private func loadData() {
        loadClients()
        loadInvoices()
        loadEstimates()
        loadBusinessInfo()
        loadTimeEntries()
        loadProjects()
        loadRecurringInvoices()
        startRecurringInvoiceTimer()
    }
    
    func saveClients() {
        if let encoded = try? JSONEncoder().encode(clients) {
            UserDefaults.standard.set(encoded, forKey: clientsKey)
        }
    }
    
    private func loadClients() {
        if let data = UserDefaults.standard.data(forKey: clientsKey),
           let decoded = try? JSONDecoder().decode([Client].self, from: data) {
            clients = decoded
        }
    }
    
    func saveInvoices() {
        if let encoded = try? JSONEncoder().encode(invoices) {
            UserDefaults.standard.set(encoded, forKey: invoicesKey)
        }
    }
    
    private func loadInvoices() {
        if let data = UserDefaults.standard.data(forKey: invoicesKey),
           let decoded = try? JSONDecoder().decode([Invoice].self, from: data) {
            invoices = decoded
        }
    }
    
    func saveBusinessInfo() {
        if let encoded = try? JSONEncoder().encode(businessInfo) {
            UserDefaults.standard.set(encoded, forKey: businessInfoKey)
        }
    }
    
    private func loadBusinessInfo() {
        if let data = UserDefaults.standard.data(forKey: businessInfoKey),
           let decoded = try? JSONDecoder().decode(BusinessInfo.self, from: data) {
            businessInfo = decoded
        }
    }
    
    // MARK: - Estimates Persistence
    
    func saveEstimates() {
        if let encoded = try? JSONEncoder().encode(estimates) {
            UserDefaults.standard.set(encoded, forKey: estimatesKey)
        }
    }
    
    private func loadEstimates() {
        if let data = UserDefaults.standard.data(forKey: estimatesKey),
           let decoded = try? JSONDecoder().decode([Estimate].self, from: data) {
            estimates = decoded
        }
    }
    
    func addClient(_ client: Client) {
        clients.append(client)
        saveClients()
    }
    
    func updateClient(_ client: Client) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index] = client
            saveClients()
        }
    }
    
    func deleteClient(_ client: Client) {
        clients.removeAll { $0.id == client.id }
        saveClients()
    }
    
    func addInvoice(_ invoice: Invoice) {
        invoices.append(invoice)
        saveInvoices()
    }
    
    func updateInvoice(_ invoice: Invoice) {
        if let index = invoices.firstIndex(where: { $0.id == invoice.id }) {
            invoices[index] = invoice
            saveInvoices()
        }
    }
    
    func deleteInvoice(_ invoice: Invoice) {
        invoices.removeAll { $0.id == invoice.id }
        saveInvoices()
    }
    
    // MARK: - Estimate Management
    
    func addEstimate(_ estimate: Estimate) {
        estimates.append(estimate)
        saveEstimates()
    }
    
    func updateEstimate(_ estimate: Estimate) {
        if let index = estimates.firstIndex(where: { $0.id == estimate.id }) {
            estimates[index] = estimate
            saveEstimates()
        }
    }
    
    func deleteEstimate(_ estimate: Estimate) {
        estimates.removeAll { $0.id == estimate.id }
        saveEstimates()
    }
    
    // MARK: - One-Click Estimate to Invoice Conversion
    func convertEstimateToInvoice(_ estimate: Estimate) -> Invoice {
        let invoice = estimate.convertToInvoice()
        addInvoice(invoice)
        
        // Update estimate status to accepted
        var updatedEstimate = estimate
        updatedEstimate.status = .accepted
        updateEstimate(updatedEstimate)
        
        print("✅ Converted estimate \(estimate.estimateNumber) to invoice \(invoice.invoiceNumber)")
        return invoice
    }
    
    // MARK: - Invoice Tracking & Communication
    
    func recordInvoiceEmailSent(_ invoice: Invoice, emailRecord: InvoiceEmailRecord) {
        if let index = invoices.firstIndex(where: { $0.id == invoice.id }) {
            invoices[index].emailsSent.append(emailRecord)
            invoices[index].sentDate = emailRecord.sentDate
            if invoices[index].status == .draft {
                invoices[index].status = .sent
            }
            saveInvoices()
            print("✅ Recorded email sent for invoice \(invoice.invoiceNumber)")
        }
    }
    
    func recordInvoiceViewed(_ invoiceId: UUID, viewedDate: Date = Date()) {
        if let index = invoices.firstIndex(where: { $0.id == invoiceId }) {
            invoices[index].lastViewedDate = viewedDate
            invoices[index].viewCount += 1
            
            // Update latest email record if exists
            if let lastEmailIndex = invoices[index].emailsSent.indices.last {
                if invoices[index].emailsSent[lastEmailIndex].openedDate == nil {
                    invoices[index].emailsSent[lastEmailIndex].openedDate = viewedDate
                    invoices[index].emailsSent[lastEmailIndex].deliveryStatus = .opened
                }
            }
            
            saveInvoices()
            print("👁️ Invoice \(invoices[index].invoiceNumber) viewed at \(viewedDate)")
        }
    }
    
    func recordInvoiceDownloaded(_ invoiceId: UUID, downloadedDate: Date = Date()) {
        if let index = invoices.firstIndex(where: { $0.id == invoiceId }) {
            invoices[index].downloadCount += 1
            
            // Update latest email record if exists
            if let lastEmailIndex = invoices[index].emailsSent.indices.last {
                invoices[index].emailsSent[lastEmailIndex].downloadedDate = downloadedDate
            }
            
            saveInvoices()
            print("⬇️ Invoice \(invoices[index].invoiceNumber) downloaded at \(downloadedDate)")
        }
    }
    
    // MARK: - Invoice Status Analytics
    
    var sentInvoicesCount: Int {
        invoices.filter { $0.status == .sent || $0.sentDate != nil }.count
    }
    
    var viewedInvoicesCount: Int {
        invoices.filter { $0.lastViewedDate != nil }.count
    }
    
    var averageViewsPerInvoice: Double {
        let totalViews = invoices.reduce(0) { $0 + $1.viewCount }
        let sentCount = sentInvoicesCount
        return sentCount > 0 ? Double(totalViews) / Double(sentCount) : 0.0
    }
    
    func invoicesViewedInLast24Hours() -> [Invoice] {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return invoices.filter { 
            guard let lastViewed = $0.lastViewedDate else { return false }
            return lastViewed > yesterday
        }
    }
    
    func updateBusinessInfo(_ info: BusinessInfo) {
        businessInfo = info
        saveBusinessInfo()
    }
    
    var totalRevenue: Double {
        invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.total }
    }
    
    var pendingInvoicesCount: Int {
        invoices.filter { !$0.isFullyPaid }.count
    }
    
    var overdueInvoicesCount: Int {
        invoices.filter { $0.status == .overdue || ($0.status == .sent && $0.dueDate < Date()) }.count
    }
    
    var pendingAmount: Double {
        invoices.filter { !$0.isFullyPaid }.reduce(0) { $0 + $1.remainingBalance }
    }
    
    var thisMonthInvoicesCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        return invoices.filter { $0.createdDate >= startOfMonth && $0.createdDate < endOfMonth }.count
    }
    
    // MARK: - Estimate Analytics
    
    var totalEstimateValue: Double {
        estimates.reduce(0) { $0 + $1.total }
    }
    
    var acceptedEstimatesValue: Double {
        estimates.filter { $0.status == .accepted }.reduce(0) { $0 + $1.total }
    }
    
    var pendingEstimatesCount: Int {
        estimates.filter { $0.status == .sent || $0.status == .draft }.count
    }
    
    var expiredEstimatesCount: Int {
        estimates.filter { $0.effectiveStatus == .expired }.count
    }
    
    var estimateConversionRate: Double {
        let totalSent = estimates.filter { $0.status == .sent || $0.status == .accepted || $0.status == .declined }.count
        let accepted = estimates.filter { $0.status == .accepted }.count
        return totalSent > 0 ? Double(accepted) / Double(totalSent) * 100 : 0.0
    }

    // MARK: - Dashboard Trends and Analytics

    var revenueGrowthPercentage: Double {
        let calendar = Calendar.current
        let now = Date()

        // Current month revenue
        let startOfCurrentMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let currentMonthRevenue = invoices.filter { invoice in
            invoice.status == .paid && invoice.payments.contains { payment in
                payment.paymentDate >= startOfCurrentMonth
            }
        }.reduce(0) { $0 + $1.total }

        // Previous month revenue
        let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth) ?? now
        let endOfLastMonth = startOfCurrentMonth
        let lastMonthRevenue = invoices.filter { invoice in
            invoice.status == .paid && invoice.payments.contains { payment in
                payment.paymentDate >= startOfLastMonth && payment.paymentDate < endOfLastMonth
            }
        }.reduce(0) { $0 + $1.total }

        if lastMonthRevenue > 0 {
            return ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100
        }
        return currentMonthRevenue > 0 ? 100 : 0
    }

    var thisMonthClientsCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        return clients.filter { $0.createdDate >= startOfMonth }.count
    }

    var thisMonthRevenueFormatted: String {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        let thisMonthRevenue = invoices.filter { invoice in
            invoice.status == .paid && invoice.payments.contains { payment in
                payment.paymentDate >= startOfMonth
            }
        }.reduce(0) { $0 + $1.total }

        return thisMonthRevenue.currencyFormatted
    }
    
    // MARK: - Time Tracking Methods
    
    private func saveTimeEntries() {
        if let encoded = try? JSONEncoder().encode(timeEntries) {
            UserDefaults.standard.set(encoded, forKey: timeEntriesKey)
        }
    }
    
    private func loadTimeEntries() {
        if let data = UserDefaults.standard.data(forKey: timeEntriesKey),
           let decoded = try? JSONDecoder().decode([TimeEntry].self, from: data) {
            timeEntries = decoded
            
            // Find active time entry if any
            activeTimeEntry = timeEntries.first { $0.isRunning }
            if activeTimeEntry != nil {
                startTimer()
            }
        }
    }
    
    func startTimeEntry(description: String, hourlyRate: Double, projectName: String = "", clientId: UUID? = nil) {
        // Stop any existing timer
        stopActiveTimeEntry()
        
        let timeEntry = TimeEntry(description: description, hourlyRate: hourlyRate, projectName: projectName, clientId: clientId)
        var newEntry = timeEntry
        newEntry.isRunning = true
        newEntry.startTime = Date()
        
        timeEntries.append(newEntry)
        activeTimeEntry = newEntry
        
        startTimer()
        saveTimeEntries()
    }
    
    func stopActiveTimeEntry() {
        guard let activeEntry = activeTimeEntry,
              let index = timeEntries.firstIndex(where: { $0.id == activeEntry.id }) else { return }
        
        timeEntries[index].isRunning = false
        timeEntries[index].endTime = Date()
        
        activeTimeEntry = nil
        stopTimer()
        saveTimeEntries()
    }
    
    func deleteTimeEntry(_ timeEntry: TimeEntry) {
        if timeEntry.isRunning {
            stopActiveTimeEntry()
        }
        timeEntries.removeAll { $0.id == timeEntry.id }
        saveTimeEntries()
    }
    
    func updateTimeEntry(_ timeEntry: TimeEntry) {
        if let index = timeEntries.firstIndex(where: { $0.id == timeEntry.id }) {
            timeEntries[index] = timeEntry
            if timeEntry.isRunning {
                activeTimeEntry = timeEntry
            }
            saveTimeEntries()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.objectWillChange.send()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Project Methods
    
    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    // MARK: - Recurring Invoice Methods
    
    private func saveRecurringInvoices() {
        if let encoded = try? JSONEncoder().encode(recurringInvoices) {
            UserDefaults.standard.set(encoded, forKey: recurringInvoicesKey)
        }
    }
    
    private func loadRecurringInvoices() {
        if let data = UserDefaults.standard.data(forKey: recurringInvoicesKey),
           let decoded = try? JSONDecoder().decode([RecurringInvoice].self, from: data) {
            recurringInvoices = decoded
        }
    }
    
    func addRecurringInvoice(_ recurringInvoice: RecurringInvoice) {
        recurringInvoices.append(recurringInvoice)
        saveRecurringInvoices()
    }
    
    func updateRecurringInvoice(_ recurringInvoice: RecurringInvoice) {
        if let index = recurringInvoices.firstIndex(where: { $0.id == recurringInvoice.id }) {
            recurringInvoices[index] = recurringInvoice
            saveRecurringInvoices()
        }
    }
    
    func deleteRecurringInvoice(_ recurringInvoice: RecurringInvoice) {
        recurringInvoices.removeAll { $0.id == recurringInvoice.id }
        saveRecurringInvoices()
    }
    
    private func startRecurringInvoiceTimer() {
        // Check for due recurring invoices every hour
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.checkAndGenerateRecurringInvoices()
        }
        
        // Also check immediately
        checkAndGenerateRecurringInvoices()
    }
    
    private func checkAndGenerateRecurringInvoices() {
        let now = Date()
        
        for recurringInvoice in recurringInvoices where recurringInvoice.isActive && recurringInvoice.nextDueDate <= now {
            generateInvoiceFromRecurring(recurringInvoice)
        }
    }
    
    private func generateInvoiceFromRecurring(_ recurringInvoice: RecurringInvoice) {
        var newInvoice = recurringInvoice.templateInvoice
        newInvoice = Invoice(client: newInvoice.client, notes: newInvoice.notes)
        newInvoice.lineItems = recurringInvoice.templateInvoice.lineItems
        newInvoice.taxRate = recurringInvoice.templateInvoice.taxRate
        newInvoice.status = .draft
        
        // Generate new invoice number
        newInvoice.invoiceNumber = "REC-\(Int(Date().timeIntervalSince1970))"
        
        addInvoice(newInvoice)
        
        // Update recurring invoice
        var updatedRecurring = recurringInvoice
        updatedRecurring.lastGeneratedDate = Date()
        updatedRecurring.generatedInvoiceIds.append(newInvoice.id)
        updatedRecurring.nextDueDate = Calendar.current.date(
            byAdding: .day,
            value: recurringInvoice.frequency.dayInterval,
            to: recurringInvoice.nextDueDate
        ) ?? Date()
        
        // Check if recurring invoice should end
        if let endDate = updatedRecurring.endDate, updatedRecurring.nextDueDate > endDate {
            updatedRecurring.isActive = false
        }
        
        updateRecurringInvoice(updatedRecurring)
    }
    
    // MARK: - Time Entry to Invoice Conversion
    
    func createInvoiceFromTimeEntries(_ timeEntries: [TimeEntry], client: Client) -> Invoice {
        var invoice = Invoice(client: client, notes: "Time-based invoice")
        
        // Group time entries by project/description
        let groupedEntries = Dictionary(grouping: timeEntries) { entry in
            entry.projectName.isEmpty ? entry.description : entry.projectName
        }
        
        invoice.lineItems = groupedEntries.map { (key, entries) in
            let totalHours = entries.reduce(0) { $0 + $1.hours }
            let averageRate = entries.reduce(0) { $0 + $1.hourlyRate } / Double(entries.count)
            
            return LineItem(
                description: key.isEmpty ? "Consulting Services" : key,
                quantity: totalHours,
                unitPrice: averageRate
            )
        }
        
        return invoice
    }
    
    // MARK: - Account Deletion (Apple App Store Compliance)

    /// Permanently deletes all user data from the device as required by Apple App Store guidelines
    func deleteAllUserData() {
        // Clear all in-memory data
        clients.removeAll()
        invoices.removeAll()
        estimates.removeAll()
        timeEntries.removeAll()
        projects.removeAll()
        recurringInvoices.removeAll()
        activeTimeEntry = nil
        businessInfo = BusinessInfo() // Reset to default

        // Clear all UserDefaults data
        UserDefaults.standard.removeObject(forKey: clientsKey)
        UserDefaults.standard.removeObject(forKey: invoicesKey)
        UserDefaults.standard.removeObject(forKey: estimatesKey)
        UserDefaults.standard.removeObject(forKey: businessInfoKey)
        UserDefaults.standard.removeObject(forKey: timeEntriesKey)
        UserDefaults.standard.removeObject(forKey: projectsKey)
        UserDefaults.standard.removeObject(forKey: recurringInvoicesKey)

        // Stop any active timers
        timer?.invalidate()
        timer = nil

        // Synchronize UserDefaults to ensure immediate persistence
        UserDefaults.standard.synchronize()

        print("🗑️ All user data has been permanently deleted")
    }

    // MARK: - Demo/Testing Methods

    func simulateInvoiceView(_ invoice: Invoice) {
        recordInvoiceViewed(invoice.id)
        print("🎭 Simulated invoice view for \(invoice.invoiceNumber)")
    }
    
    func simulateInvoiceDownload(_ invoice: Invoice) {
        recordInvoiceDownloaded(invoice.id)
        print("🎭 Simulated invoice download for \(invoice.invoiceNumber)")
    }
}