import SwiftUI

// MARK: - Estimate List View
struct EstimateListView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddEstimate = false
    @State private var searchText = ""
    @State private var selectedStatus: EstimateStatus?
    @State private var showingFilters = false
    @State private var sortOption: EstimateSortOption = .dateNewest
    
    var filteredEstimates: [Estimate] {
        var estimates = dataManager.estimates
        
        // Filter by status
        if let status = selectedStatus {
            estimates = estimates.filter { $0.effectiveStatus == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            estimates = estimates.filter { 
                $0.estimateNumber.localizedCaseInsensitiveContains(searchText) ||
                $0.client.name.localizedCaseInsensitiveContains(searchText) ||
                $0.client.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort estimates
        return sortEstimates(estimates)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                if dataManager.estimates.isEmpty {
                    ModernEmptyEstimateView {
                        showingAddEstimate = true
                    }
                } else {
                    VStack(spacing: 0) {
                        // Modern Search and Filter Header
                        ModernEstimateHeader(
                            searchText: $searchText,
                            selectedStatus: $selectedStatus,
                            showingFilters: $showingFilters,
                            sortOption: $sortOption,
                            showingAddEstimate: $showingAddEstimate
                        )
                        
                        // Estimate Statistics Bar
                        ModernEstimateStatsBar()
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            .padding(.bottom, DesignSystem.Spacing.md)
                        
                        // Modern Estimate List
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: DesignSystem.Spacing.md) {
                                ForEach(Array(filteredEstimates.enumerated()), id: \.element.id) { index, estimate in
                                    NavigationLink(destination: EstimateDetailView(estimate: estimate)) {
                                        SimplifiedEstimateRow(estimate: estimate)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        ModernEstimateContextMenu(estimate: estimate)
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            .padding(.bottom, DesignSystem.Spacing.massive)
                        }
                        .refreshable {
                            await refreshEstimates()
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddEstimate) {
            AddEditEstimateView()
        }
        .sheet(isPresented: $showingFilters) {
            ModernEstimateFiltersView(
                selectedStatus: $selectedStatus,
                sortOption: $sortOption
            )
        }
    }
    
    private func sortEstimates(_ estimates: [Estimate]) -> [Estimate] {
        switch sortOption {
        case .dateNewest:
            return estimates.sorted { $0.createdDate > $1.createdDate }
        case .dateOldest:
            return estimates.sorted { $0.createdDate < $1.createdDate }
        case .amountHighest:
            return estimates.sorted { $0.total > $1.total }
        case .amountLowest:
            return estimates.sorted { $0.total < $1.total }
        case .clientName:
            return estimates.sorted { $0.client.name < $1.client.name }
        case .validUntil:
            return estimates.sorted { $0.validUntil < $1.validUntil }
        }
    }
    
    private func refreshEstimates() async {
        // Simulate refresh delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // Refresh logic would go here
    }
}

// MARK: - Estimate Sort Options
enum EstimateSortOption: String, CaseIterable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case amountHighest = "Amount (Highest)"
    case amountLowest = "Amount (Lowest)"
    case clientName = "Client Name"
    case validUntil = "Valid Until"
    
    var icon: String {
        switch self {
        case .dateNewest, .dateOldest: return "calendar"
        case .amountHighest, .amountLowest: return "dollarsign.circle"
        case .clientName: return "person.circle"
        case .validUntil: return "clock"
        }
    }
}

// MARK: - Simplified Estimate Row (One-Line)
struct SimplifiedEstimateRow: View {
    let estimate: Estimate
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            
            // Status Circle
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            // Estimate Number
            Text(estimate.estimateNumber)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: 80, alignment: .leading)
            
            // Client Name
            Text(estimate.client.name)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Amount
            Text(estimate.total.currencyFormatted)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: 90, alignment: .trailing)
            
            // Status Badge (Small)
            Text(estimate.effectiveStatus.rawValue.prefix(3).uppercased())
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
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        estimate.effectiveStatus.color
    }
}

// MARK: - Modern Estimate Header
struct ModernEstimateHeader: View {
    @Binding var searchText: String
    @Binding var selectedStatus: EstimateStatus?
    @Binding var showingFilters: Bool
    @Binding var sortOption: EstimateSortOption
    @Binding var showingAddEstimate: Bool
    
    @State private var isSearchFocused = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            
            // Title and Add Button
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Estimates")
                        .font(DesignSystem.Typography.display2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Create and manage estimates")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: { showingAddEstimate = true }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: DesignSystem.Icons.add)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textInverse)
                        Text("New Estimate")
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
                    
                    TextField("Search estimates, clients...", text: $searchText)
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
            if !EstimateStatus.allCases.isEmpty {
                ModernEstimateStatusFilterChips(selectedStatus: $selectedStatus)
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

// MARK: - Modern Estimate Status Filter Chips
struct ModernEstimateStatusFilterChips: View {
    @Binding var selectedStatus: EstimateStatus?
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                
                // All Estimates Chip
                ModernFilterChip(
                    title: "All",
                    count: dataManager.estimates.count,
                    isSelected: selectedStatus == nil,
                    color: DesignSystem.Colors.primary
                ) {
                    selectedStatus = nil
                }
                
                // Status-specific chips
                ForEach(EstimateStatus.allCases, id: \.self) { status in
                    let count = dataManager.estimates.filter { $0.effectiveStatus == status }.count
                    if count > 0 {
                        ModernFilterChip(
                            title: status.rawValue.capitalized,
                            count: count,
                            isSelected: selectedStatus == status,
                            color: status.color
                        ) {
                            selectedStatus = selectedStatus == status ? nil : status
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        }
    }
}

// MARK: - Modern Estimate Stats Bar
struct ModernEstimateStatsBar: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            
            ModernStatItem(
                icon: DesignSystem.Icons.currency,
                title: "Total Value",
                value: dataManager.totalEstimateValue.currencyFormatted,
                color: DesignSystem.Colors.primary
            )
            
            Divider()
                .frame(height: 30)
                .background(DesignSystem.Colors.borderLight)
            
            ModernStatItem(
                icon: "checkmark.circle.fill",
                title: "Accepted",
                value: dataManager.acceptedEstimatesValue.currencyFormatted,
                color: DesignSystem.Colors.success
            )
            
            Divider()
                .frame(height: 30)
                .background(DesignSystem.Colors.borderLight)
            
            ModernStatItem(
                icon: "clock.fill",
                title: "Pending",
                value: dataManager.pendingEstimatesCount.decimalFormatted,
                color: DesignSystem.Colors.warning
            )
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.cardPadding)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .modernCard(elevation: 1)
    }
}

// MARK: - Modern Empty Estimate View
struct ModernEmptyEstimateView: View {
    let onCreateEstimate: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxxl) {
            
            Spacer()
            
            // Professional Illustration
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryUltraLight)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            // Empty State Content
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("No Estimates Yet")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Create your first estimate to provide professional quotes to potential clients.")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxxl)
            }
            
            // Create Estimate Button
            Button(action: onCreateEstimate) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: DesignSystem.Icons.add)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textInverse)
                    Text("Create Your First Estimate")
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

// MARK: - Modern Estimate Context Menu
struct ModernEstimateContextMenu: View {
    let estimate: Estimate
    
    var body: some View {
        VStack {
            contextMenuButtons
        }
    }
    
    @ViewBuilder
    private var contextMenuButtons: some View {
        Button(action: { editEstimate() }) {
            Label("Edit", systemImage: DesignSystem.Icons.edit)
        }
        
        Button(action: { duplicateEstimate() }) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        // One-Click Convert to Invoice
        if estimate.status != .declined && estimate.status != .expired {
            Button(action: { convertToInvoice() }) {
                Label("Convert to Invoice", systemImage: "doc.text.fill")
            }
        }
        
        Button(action: { shareEstimate() }) {
            Label("Share", systemImage: DesignSystem.Icons.share)
        }
        
        Divider()
        
        if estimate.status == .draft {
            Button(action: { markAsSent() }) {
                Label("Mark as Sent", systemImage: "paperplane")
            }
        }
        
        if estimate.status == .sent {
            Button(action: { markAsAccepted() }) {
                Label("Mark as Accepted", systemImage: "checkmark.circle")
            }
            
            Button(action: { markAsDeclined() }) {
                Label("Mark as Declined", systemImage: "xmark.circle")
            }
        }
        
        Button(role: .destructive, action: { deleteEstimate() }) {
            Label("Delete", systemImage: DesignSystem.Icons.delete)
        }
    }
    
    private func editEstimate() {
        print("🔧 Edit estimate: \(estimate.estimateNumber)")
    }
    
    private func duplicateEstimate() {
        print("📋 Duplicate estimate: \(estimate.estimateNumber)")
    }
    
    private func convertToInvoice() {
        print("🔄 Converting estimate \(estimate.estimateNumber) to invoice...")
        let invoice = DataManager.shared.convertEstimateToInvoice(estimate)
        print("✅ Converted to invoice: \(invoice.invoiceNumber)")
    }
    
    private func shareEstimate() {
        print("📤 Share estimate: \(estimate.estimateNumber)")
    }
    
    private func markAsSent() {
        var updatedEstimate = estimate
        updatedEstimate.status = .sent
        DataManager.shared.updateEstimate(updatedEstimate)
    }
    
    private func markAsAccepted() {
        var updatedEstimate = estimate
        updatedEstimate.status = .accepted
        DataManager.shared.updateEstimate(updatedEstimate)
    }
    
    private func markAsDeclined() {
        var updatedEstimate = estimate
        updatedEstimate.status = .declined
        DataManager.shared.updateEstimate(updatedEstimate)
    }
    
    private func deleteEstimate() {
        DataManager.shared.deleteEstimate(estimate)
    }
}

// MARK: - Modern Estimate Filters View
struct ModernEstimateFiltersView: View {
    @Binding var selectedStatus: EstimateStatus?
    @Binding var sortOption: EstimateSortOption
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
                            title: "All Estimates",
                            isSelected: selectedStatus == nil
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(EstimateStatus.allCases, id: \.self) { status in
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
                        ForEach(EstimateSortOption.allCases, id: \.self) { option in
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

// MARK: - Supporting Views

// ModernFilterChip moved to DataModels.swift

// ModernStatItem moved to DataModels.swift

// ModernFilterOption moved to DataModels.swift

// ModernSortOption moved to DataModels.swift

#Preview {
    EstimateListView()
}