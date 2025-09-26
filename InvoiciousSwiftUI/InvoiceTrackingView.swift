import SwiftUI

struct InvoiceTrackingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTimeRange: TrackingTimeRange = .last7Days
    @State private var selectedInvoice: Invoice?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TrackingTimeRange.allCases) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    
                    // Analytics Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.md) {
                        
                        // Email Stats Card
                        TrackingMetricCard(
                            title: "Emails Sent",
                            value: String(filteredSentCount),
                            subtitle: "invoices sent",
                            icon: "paperplane.fill",
                            color: DesignSystem.Colors.primary
                        )
                        
                        // View Stats Card
                        TrackingMetricCard(
                            title: "Invoice Views",
                            value: String(totalViewCount),
                            subtitle: "total views",
                            icon: "eye.fill",
                            color: DesignSystem.Colors.success
                        )
                        
                        // Open Rate Card
                        TrackingMetricCard(
                            title: "Open Rate",
                            value: String(format: "%.1f%%", openRate),
                            subtitle: "emails opened",
                            icon: "envelope.open.fill",
                            color: DesignSystem.Colors.warning
                        )
                        
                        // Recent Activity Card
                        TrackingMetricCard(
                            title: "Recent Views",
                            value: String(recentViewsCount),
                            subtitle: "last 24 hours",
                            icon: "clock.fill",
                            color: DesignSystem.Colors.secondary
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    
                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Text("Recent Activity")
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        
                        ForEach(recentlyViewedInvoices) { invoice in
                            InvoiceTrackingRow(invoice: invoice) {
                                selectedInvoice = invoice
                            }
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        }
                        
                        if recentlyViewedInvoices.isEmpty {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 48))
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                
                                Text("No Recent Activity")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text("Invoice views and activity will appear here")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.xl)
                        }
                    }
                    
                    // All Tracked Invoices
                    if !trackedInvoices.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            HStack {
                                Text("All Tracked Invoices")
                                    .font(DesignSystem.Typography.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            
                            ForEach(trackedInvoices) { invoice in
                                InvoiceTrackingRow(invoice: invoice) {
                                    selectedInvoice = invoice
                                }
                                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .navigationTitle("Invoice Tracking")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                // Simulate refresh - in real app, this would sync with server
                await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
        .sheet(item: $selectedInvoice) { invoice in
            InvoiceTrackingDetailView(invoice: invoice)
        }
    }
    
    // MARK: - Computed Properties
    
    private var trackedInvoices: [Invoice] {
        dataManager.invoices.filter { invoice in
            !invoice.emailsSent.isEmpty || invoice.viewCount > 0 || invoice.downloadCount > 0
        }
        .sorted { $0.lastViewedDate ?? $0.sentDate ?? Date.distantPast > $1.lastViewedDate ?? $1.sentDate ?? Date.distantPast }
    }
    
    private var filteredInvoices: [Invoice] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeRange {
        case .last24Hours:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            return dataManager.invoices.filter { invoice in
                invoice.emailsSent.contains { $0.sentDate >= yesterday } ||
                (invoice.lastViewedDate ?? Date.distantPast) >= yesterday ||
                invoice.createdDate >= yesterday
            }
        case .last7Days:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return dataManager.invoices.filter { invoice in
                invoice.emailsSent.contains { $0.sentDate >= weekAgo } ||
                (invoice.lastViewedDate ?? Date.distantPast) >= weekAgo ||
                invoice.createdDate >= weekAgo
            }
        case .last30Days:
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return dataManager.invoices.filter { invoice in
                invoice.emailsSent.contains { $0.sentDate >= monthAgo } ||
                (invoice.lastViewedDate ?? Date.distantPast) >= monthAgo ||
                invoice.createdDate >= monthAgo
            }
        case .allTime:
            return dataManager.invoices
        }
    }

    private var recentlyViewedInvoices: [Invoice] {
        filteredInvoices.filter { $0.lastViewedDate != nil }
            .sorted { ($0.lastViewedDate ?? Date.distantPast) > ($1.lastViewedDate ?? Date.distantPast) }
            .prefix(5)
            .map { $0 }
    }

    private var totalViewCount: Int {
        filteredInvoices.reduce(0) { $0 + $1.viewCount }
    }

    private var filteredSentCount: Int {
        filteredInvoices.filter { !$0.emailsSent.isEmpty }.count
    }

    private var filteredViewedCount: Int {
        filteredInvoices.filter { $0.lastViewedDate != nil }.count
    }

    private var openRate: Double {
        let sentCount = filteredSentCount
        let viewedCount = filteredViewedCount
        return sentCount > 0 ? Double(viewedCount) / Double(sentCount) * 100 : 0.0
    }

    private var recentViewsCount: Int {
        recentlyViewedInvoices.count
    }
}

// MARK: - Tracking Time Range (moved to DataModels.swift)

// MARK: - Tracking Metric Card
// TrackingMetricCard now defined in ContentView.swift to avoid cross-file dependency issues

// MARK: - Invoice Tracking Row (now defined in ContentView.swift)
// InvoiceTrackingRow moved to ContentView.swift to avoid cross-file dependency issues

// MARK: - Invoice Tracking Detail View (now defined in ContentView.swift)
// InvoiceTrackingDetailView moved to ContentView.swift to avoid cross-file dependency issues

// MARK: - Supporting Views
struct TrackingStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(DesignSystem.Typography.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}

struct EmailRecordRow: View {
    let emailRecord: InvoiceEmailRecord
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: emailRecord.deliveryStatus.icon)
                .foregroundColor(emailRecord.deliveryStatus.color)
                .font(.callout)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(emailRecord.deliveryStatus.rawValue)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(emailRecord.sentDate, style: .relative)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                Text(emailRecord.recipientEmail)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                if let openedDate = emailRecord.openedDate {
                    Text("Opened \(openedDate, style: .relative)")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}

#Preview {
    InvoiceTrackingView()
}