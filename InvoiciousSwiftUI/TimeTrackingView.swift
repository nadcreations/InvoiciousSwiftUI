import SwiftUI
import RevenueCat

struct TimeTrackingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingStartTimer = false
    @State private var showingCreateInvoice = false
    @State private var selectedTimeEntries: Set<TimeEntry> = []
    @State private var searchText = ""
    
    private var filteredTimeEntries: [TimeEntry] {
        let entries = dataManager.timeEntries.sorted { $0.startTime > $1.startTime }
        
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.projectName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var totalHoursThisWeek: Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return dataManager.timeEntries
            .filter { $0.startTime >= startOfWeek }
            .reduce(0) { $0 + $1.hours }
    }
    
    private var totalValueThisWeek: Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return dataManager.timeEntries
            .filter { $0.startTime >= startOfWeek }
            .reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Active Timer Section
                if let activeEntry = dataManager.activeTimeEntry {
                    ActiveTimerCard(timeEntry: activeEntry)
                        .padding()
                }
                
                // Statistics
                HStack(spacing: 16) {
                    StatCard(
                        title: "This Week",
                        value: String(format: "%.1fh", totalHoursThisWeek),
                        subtitle: totalValueThisWeek.currencyFormatted,
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Total Entries",
                        value: dataManager.timeEntries.count.decimalFormatted,
                        subtitle: "All time",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                // Time Entries List
                List {
                    if filteredTimeEntries.isEmpty {
                        EmptyTimeTrackingView {
                            showingStartTimer = true
                        }
                    } else {
                        ForEach(filteredTimeEntries) { entry in
                            TimeEntryRow(
                                timeEntry: entry,
                                isSelected: selectedTimeEntries.contains(entry)
                            ) { selected in
                                if selected {
                                    selectedTimeEntries.insert(entry)
                                } else {
                                    selectedTimeEntries.remove(entry)
                                }
                            }
                        }
                        .onDelete(perform: deleteTimeEntries)
                    }
                }
                .searchable(text: $searchText, prompt: "Search time entries...")
            }
            .navigationTitle("Time Tracking")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !selectedTimeEntries.isEmpty {
                        Button("Create Invoice") {
                            showingCreateInvoice = true
                        }
                    }
                    
                    Button(action: { showingStartTimer = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingStartTimer) {
                StartTimerView()
            }
            .sheet(isPresented: $showingCreateInvoice) {
                CreateInvoiceFromTimeView(timeEntries: Array(selectedTimeEntries)) {
                    selectedTimeEntries.removeAll()
                }
            }
        }
    }
    
    private func deleteTimeEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = filteredTimeEntries[index]
            dataManager.deleteTimeEntry(entry)
            selectedTimeEntries.remove(entry)
        }
    }
}

struct ActiveTimerCard: View {
    let timeEntry: TimeEntry
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Currently Tracking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(timeEntry.description)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    if !timeEntry.projectName.isEmpty {
                        Text(timeEntry.projectName)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button(action: dataManager.stopActiveTimeEntry) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(timeEntry.duration))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timeEntry.hourlyRate.currencyFormatted + "/hr")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .trailing) {
                    Text("Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timeEntry.total.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 2)
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct TimeEntryRow: View {
    let timeEntry: TimeEntry
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack {
            Button(action: { onSelectionChanged(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(timeEntry.description)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if timeEntry.isRunning {
                        Text("RUNNING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                if !timeEntry.projectName.isEmpty {
                    Text(timeEntry.projectName)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text(timeEntry.startTime, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1fh", timeEntry.hours))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(timeEntry.total.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyTimeTrackingView: View {
    let onStartTimer: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Time Entries Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your time to create accurate invoices")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start Timer", action: onStartTimer)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct StartTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var description = ""
    @State private var hourlyRate: Double = 0
    @State private var projectName = ""
    @State private var selectedClientId: UUID?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Time Entry Details") {
                    TextField("What are you working on?", text: $description)
                    
                    TextField("Project Name (Optional)", text: $projectName)
                    
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        TextField("Rate", value: $hourlyRate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Client") {
                    Picker("Select Client", selection: $selectedClientId) {
                        Text("No Client").tag(nil as UUID?)
                        ForEach(dataManager.clients) { client in
                            Text(client.name).tag(client.id as UUID?)
                        }
                    }
                }
                
                if hourlyRate == 0 {
                    Section {
                        Button("Use Default Rate (\(dataManager.businessInfo.defaultHourlyRate.currencyFormatted)/hr)") {
                            hourlyRate = dataManager.businessInfo.defaultHourlyRate
                        }
                    }
                }
            }
            .navigationTitle("Start Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        startTimer()
                    }
                    .disabled(description.isEmpty || hourlyRate <= 0)
                }
            }
        }
        .onAppear {
            hourlyRate = dataManager.businessInfo.defaultHourlyRate
        }
    }
    
    private func startTimer() {
        dataManager.startTimeEntry(
            description: description,
            hourlyRate: hourlyRate,
            projectName: projectName,
            clientId: selectedClientId
        )
        dismiss()
    }
}

struct CreateInvoiceFromTimeView: View {
    let timeEntries: [TimeEntry]
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingPaywall = false
    
    @State private var selectedClient: Client?
    @State private var showingClientPicker = false
    
    var totalHours: Double {
        timeEntries.reduce(0) { $0 + $1.hours }
    }
    
    var totalValue: Double {
        timeEntries.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Time Summary") {
                    HStack {
                        Text("Total Hours")
                        Spacer()
                        Text(String(format: "%.1f hours", totalHours))
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text(totalValue.currencyFormatted)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                Section("Client") {
                    if let client = selectedClient {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(client.name)
                                    .fontWeight(.medium)
                                if !client.email.isEmpty {
                                    Text(client.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button("Change") {
                                showingClientPicker = true
                            }
                            .font(.caption)
                        }
                    } else {
                        Button("Select Client") {
                            showingClientPicker = true
                        }
                    }
                }
                
                Section("Time Entries") {
                    ForEach(timeEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.description)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text(entry.startTime, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(String(format: "%.1fh × %@ = %@", entry.hours, entry.hourlyRate.currencyFormatted, entry.total.currencyFormatted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("Create Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createInvoice()
                    }
                    .disabled(selectedClient == nil)
                }
            }
            .sheet(isPresented: $showingClientPicker) {
                ClientPickerView(selectedClient: $selectedClient)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    private func createInvoice() {
        guard let client = selectedClient else { return }

        // Check if this feature requires premium subscription
        if !subscriptionManager.hasAccess(to: .timeTracking) {
            showingPaywall = true
            return
        }

        // Check invoice limit for non-subscribers
        if !subscriptionManager.isSubscribed {
            let freeInvoiceLimit = 3
            if dataManager.invoices.count >= freeInvoiceLimit {
                showingPaywall = true
                return
            }
        }

        let invoice = dataManager.createInvoiceFromTimeEntries(timeEntries, client: client)
        dataManager.addInvoice(invoice)

        onComplete()
        dismiss()
    }
}