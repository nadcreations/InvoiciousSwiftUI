import SwiftUI
import PDFKit

// MARK: - Modern Invoice List View
struct InvoiceListView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddInvoice = false
    @State private var searchText = ""
    @State private var selectedStatus: InvoiceStatus?
    @State private var showingFilters = false
    @State private var sortOption: InvoiceSortOption = .dateNewest
    @State private var animateList = false
    
    var filteredInvoices: [Invoice] {
        var invoices = dataManager.invoices
        
        // Filter by status
        if let status = selectedStatus {
            invoices = invoices.filter { $0.effectiveStatus == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            invoices = invoices.filter { 
                $0.invoiceNumber.localizedCaseInsensitiveContains(searchText) ||
                $0.client.name.localizedCaseInsensitiveContains(searchText) ||
                $0.client.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort invoices
        return sortInvoices(invoices)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                if dataManager.invoices.isEmpty {
                    ModernEmptyInvoiceView {
                        showingAddInvoice = true
                    }
                } else {
                    VStack(spacing: 0) {
                        // Modern Search and Filter Header
                        ModernInvoiceHeader(
                            searchText: $searchText,
                            selectedStatus: $selectedStatus,
                            showingFilters: $showingFilters,
                            sortOption: $sortOption,
                            showingAddInvoice: $showingAddInvoice
                        )
                        
                        // Invoice Statistics Bar
                        ModernInvoiceStatsBar()
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            .padding(.bottom, DesignSystem.Spacing.md)
                        
                        // Modern Invoice List
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: DesignSystem.Spacing.md) {
                                ForEach(Array(filteredInvoices.enumerated()), id: \.element.id) { index, invoice in
                                    NavigationLink(destination: InvoiceDetailView(invoice: invoice)) {
                                        SimplifiedInvoiceRow(invoice: invoice, index: index)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        ModernInvoiceContextMenu(invoice: invoice)
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            .padding(.bottom, DesignSystem.Spacing.massive)
                        }
                        .refreshable {
                            await refreshInvoices()
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                // Professional appearance without animations
            }
            .sheet(isPresented: $showingAddInvoice) {
                AddEditInvoiceView()
            }
            .sheet(isPresented: $showingFilters) {
                ModernInvoiceFiltersView(
                    selectedStatus: $selectedStatus,
                    sortOption: $sortOption
                )
            }
        }
    }
    
    private func sortInvoices(_ invoices: [Invoice]) -> [Invoice] {
        switch sortOption {
        case .dateNewest:
            return invoices.sorted { $0.createdDate > $1.createdDate }
        case .dateOldest:
            return invoices.sorted { $0.createdDate < $1.createdDate }
        case .amountHighest:
            return invoices.sorted { $0.total > $1.total }
        case .amountLowest:
            return invoices.sorted { $0.total < $1.total }
        case .clientName:
            return invoices.sorted { $0.client.name < $1.client.name }
        case .dueDate:
            return invoices.sorted { $0.dueDate < $1.dueDate }
        }
    }
    
    private func refreshInvoices() async {
        // Simulate refresh delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // Refresh logic would go here
    }
}

// MARK: - Invoice Sort Options
enum InvoiceSortOption: String, CaseIterable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case amountHighest = "Amount (Highest)"
    case amountLowest = "Amount (Lowest)"
    case clientName = "Client Name"
    case dueDate = "Due Date"
    
    var icon: String {
        switch self {
        case .dateNewest, .dateOldest: return "calendar"
        case .amountHighest, .amountLowest: return "dollarsign.circle"
        case .clientName: return "person.circle"
        case .dueDate: return "clock"
        }
    }
}

// MARK: - Modern Invoice Header
struct ModernInvoiceHeader: View {
    @Binding var searchText: String
    @Binding var selectedStatus: InvoiceStatus?
    @Binding var showingFilters: Bool
    @Binding var sortOption: InvoiceSortOption
    @Binding var showingAddInvoice: Bool
    
    @State private var isSearchFocused = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            // Title and Add Button
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Invoices")
                        .font(DesignSystem.Typography.display2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Manage your invoices")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: { showingAddInvoice = true }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: DesignSystem.Icons.add)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textInverse)
                        Text("New Invoice")
                            .font(DesignSystem.Typography.label2)
                            .fontWeight(.semibold)
                    }
                }
                .professionalButton(style: .primary, size: .medium)
            }
            
            // Search Bar
            HStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSearchFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    
                    TextField("Search invoices, clients...", text: $searchText)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .onTapGesture {
                            isSearchFocused = true
                        }
                        .onSubmit {
                            isSearchFocused = false
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.input)
                        .stroke(
                            isSearchFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.borderLight,
                            lineWidth: isSearchFocused ? 2 : 1
                        )
                )
                .cornerRadius(DesignSystem.CornerRadius.input)
                
                // Filter Button
                Button(action: { showingFilters = true }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedStatus != nil ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                        if selectedStatus != nil {
                            Circle()
                                .fill(DesignSystem.Colors.accent)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.surface)
                .modernCard(elevation: 1)
            }
            
            // Status Filter Chips
            if !InvoiceStatus.allCases.isEmpty {
                ModernStatusFilterChips(selectedStatus: $selectedStatus)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.surface,
                    DesignSystem.Colors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Modern Status Filter Chips
struct ModernStatusFilterChips: View {
    @Binding var selectedStatus: InvoiceStatus?
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                
                // All Invoices Chip
                ModernFilterChip(
                    title: "All",
                    count: dataManager.invoices.count,
                    isSelected: selectedStatus == nil,
                    color: DesignSystem.Colors.primary
                ) {
                    selectedStatus = nil
                }
                
                // Status-specific chips
                ForEach(InvoiceStatus.allCases, id: \.self) { status in
                    let count = dataManager.invoices.filter { $0.effectiveStatus == status }.count
                    if count > 0 {
                        ModernFilterChip(
                            title: status.rawValue.capitalized,
                            count: count,
                            isSelected: selectedStatus == status,
                            color: statusColor(for: status)
                        ) {
                            selectedStatus = selectedStatus == status ? nil : status
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        }
    }
    
    private func statusColor(for status: InvoiceStatus) -> Color {
        switch status {
        case .draft: return DesignSystem.Colors.statusDraft
        case .sent: return DesignSystem.Colors.statusSent
        case .paid: return DesignSystem.Colors.statusPaid
        case .overdue: return DesignSystem.Colors.statusOverdue
        case .cancelled: return DesignSystem.Colors.statusCancelled
        case .partiallyPaid: return DesignSystem.Colors.statusPartiallyPaid
        }
    }
}

// MARK: - Modern Filter Chip (moved to DataModels.swift)

// MARK: - Modern Invoice Stats Bar
struct ModernInvoiceStatsBar: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack(spacing: 0) {

            ModernStatItem(
                icon: DesignSystem.Icons.currency,
                title: "Total",
                value: dataManager.totalRevenue.currencyFormatted,
                color: DesignSystem.Colors.success
            )

            Divider()
                .frame(height: 40)
                .background(DesignSystem.Colors.borderLight)

            ModernStatItem(
                icon: "clock.fill",
                title: "Pending",
                value: dataManager.pendingAmount.currencyFormatted,
                color: DesignSystem.Colors.warning
            )

            Divider()
                .frame(height: 40)
                .background(DesignSystem.Colors.borderLight)

            ModernStatItem(
                icon: DesignSystem.Icons.warning,
                title: "Overdue",
                value: dataManager.overdueInvoicesCount.decimalFormatted,
                color: DesignSystem.Colors.error
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.cardPadding)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .modernCard(elevation: 1)
    }
}

// MARK: - Modern Stat Item (moved to DataModels.swift)

// MARK: - Simplified Invoice Row (One-Line)
struct SimplifiedInvoiceRow: View {
    let invoice: Invoice
    let index: Int

    init(invoice: Invoice, index: Int = 0) {
        self.invoice = invoice
        self.index = index
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            
            // Status Circle
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            // Invoice Number
            Text(invoice.invoiceNumber)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: 80, alignment: .leading)
            
            // Client Name
            Text(invoice.client.name)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Amount
            Text(invoice.total.currencyFormatted)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: 90, alignment: .trailing)
            
            // Status Badge (Small)
            Text(invoice.effectiveStatus.rawValue.prefix(3).uppercased())
                .font(DesignSystem.Typography.caption2)
                .fontWeight(.bold)
                .foregroundColor(statusColor)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.1))
                .cornerRadius(4)
                .frame(width: 45)
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.cardPadding)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(index % 2 == 0 ? DesignSystem.Colors.surface : DesignSystem.Colors.primaryUltraLight)
        .cornerRadius(DesignSystem.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        switch invoice.effectiveStatus {
        case .draft: return DesignSystem.Colors.statusDraft
        case .sent: return DesignSystem.Colors.statusSent
        case .paid: return DesignSystem.Colors.statusPaid
        case .overdue: return DesignSystem.Colors.statusOverdue
        case .cancelled: return DesignSystem.Colors.statusCancelled
        case .partiallyPaid: return DesignSystem.Colors.statusPartiallyPaid
        }
    }
}

// MARK: - Modern Invoice Context Menu
struct ModernInvoiceContextMenu: View {
    let invoice: Invoice
    
    var body: some View {
        VStack {
            contextMenuButtons
        }
    }
    
    @ViewBuilder
    private var contextMenuButtons: some View {
        Button(action: { editInvoice() }) {
            Label("Edit", systemImage: DesignSystem.Icons.edit)
        }
        
        Button(action: { duplicateInvoice() }) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        Button(action: { shareInvoice() }) {
            Label("Share", systemImage: DesignSystem.Icons.share)
        }
        
        Divider()
        
        if invoice.status != .paid {
            Button(action: { markAsPaid() }) {
                Label("Mark as Paid", systemImage: "checkmark.circle")
            }
        }
        
        Button(role: .destructive, action: { deleteInvoice() }) {
            Label("Delete", systemImage: DesignSystem.Icons.delete)
        }
    }
    
    private func editInvoice() {
        // Edit invoice logic
    }
    
    private func duplicateInvoice() {
        // Duplicate invoice logic
    }
    
    private func shareInvoice() {
        // Share invoice logic
    }
    
    private func markAsPaid() {
        var updatedInvoice = invoice
        updatedInvoice.status = .paid
        DataManager.shared.updateInvoice(updatedInvoice)
    }
    
    private func deleteInvoice() {
        DataManager.shared.deleteInvoice(invoice)
    }
}

// MARK: - Modern Empty Invoice View
struct ModernEmptyInvoiceView: View {
    let onCreateInvoice: () -> Void
    @State private var animateElements = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxxl) {
            
            Spacer()
            
            // Professional Illustration
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryUltraLight)
                    .frame(width: 120, height: 120)
                
                Image(systemName: DesignSystem.Icons.invoices)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            // Empty State Content
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("No Invoices Yet")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Create your first invoice to get started with professional billing and payment tracking.")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxxl)
            }
            
            // Create Invoice Button
            Button(action: onCreateInvoice) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: DesignSystem.Icons.add)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textInverse)
                    Text("Create Your First Invoice")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                }
            }
            .professionalButton(style: .primary, size: .large)
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
}

// MARK: - Modern Invoice Filters View
struct ModernInvoiceFiltersView: View {
    @Binding var selectedStatus: InvoiceStatus?
    @Binding var sortOption: InvoiceSortOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                
                // Status Filter Section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Filter by Status")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.sm) {
                        
                        ModernFilterOption(
                            title: "All Invoices",
                            isSelected: selectedStatus == nil
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(InvoiceStatus.allCases, id: \.self) { status in
                            ModernFilterOption(
                                title: status.rawValue.capitalized,
                                isSelected: selectedStatus == status
                            ) {
                                selectedStatus = selectedStatus == status ? nil : status
                            }
                        }
                    }
                }
                
                // Sort Options Section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Sort by")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(InvoiceSortOption.allCases, id: \.self) { option in
                            ModernSortOption(
                                title: option.rawValue,
                                icon: option.icon,
                                isSelected: sortOption == option
                            ) {
                                sortOption = option
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            .padding(.top, DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Filters & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .professionalButton(style: .primary, size: .small)
                }
            }
        }
    }
}

// MARK: - Modern Filter Option
// ModernFilterOption moved to DataModels.swift

// MARK: - Modern Sort Option (moved to DataModels.swift)

// MARK: - Legacy Components (Updated with Modern Styling)

struct ProfessionalInvoiceListRow: View {
    let invoice: Invoice
    
    var body: some View {
        SimplifiedInvoiceRow(invoice: invoice)
    }
}

struct StatusBadgeView: View {
    let status: InvoiceStatus
    
    var body: some View {
        ModernStatusBadge(status: status)
    }
}

struct EmptyInvoiceView: View {
    let onCreateInvoice: () -> Void
    
    var body: some View {
        ModernEmptyInvoiceView(onCreateInvoice: onCreateInvoice)
    }
}

struct StatusFilterView: View {
    @Binding var selectedStatus: InvoiceStatus?
    
    var body: some View {
        ModernStatusFilterChips(selectedStatus: $selectedStatus)
    }
}

#Preview {
    InvoiceListView()
}