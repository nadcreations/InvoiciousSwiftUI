import SwiftUI
import RevenueCat

struct RecurringInvoicesView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingCreateRecurring = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            Group {
                if dataManager.recurringInvoices.isEmpty {
                    EmptyRecurringView {
                        if subscriptionManager.hasAccess(to: .recurringInvoices) {
                            showingCreateRecurring = true
                        } else {
                            showingPaywall = true
                        }
                    }
                } else {
                    List {
                        ForEach(dataManager.recurringInvoices.sorted { $0.nextDueDate < $1.nextDueDate }) { recurring in
                            RecurringInvoiceRow(recurringInvoice: recurring)
                        }
                        .onDelete(perform: deleteRecurringInvoices)
                    }
                }
            }
            .navigationTitle("Recurring Invoices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if subscriptionManager.hasAccess(to: .recurringInvoices) {
                            showingCreateRecurring = true
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateRecurring) {
                CreateRecurringInvoiceView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    private func deleteRecurringInvoices(at offsets: IndexSet) {
        let sortedInvoices = dataManager.recurringInvoices.sorted { $0.nextDueDate < $1.nextDueDate }
        for index in offsets {
            let recurring = sortedInvoices[index]
            dataManager.deleteRecurringInvoice(recurring)
        }
    }
}

struct EmptyRecurringView: View {
    let onCreateRecurring: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Recurring Invoices")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Set up automatic invoices for your regular clients")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Recurring Invoice", action: onCreateRecurring)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct RecurringInvoiceRow: View {
    let recurringInvoice: RecurringInvoice
    @StateObject private var dataManager = DataManager.shared
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(recurringInvoice.templateInvoice.client.name)
                        .font(.headline)
                    
                    Text("Every \(recurringInvoice.frequency.rawValue)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", recurringInvoice.templateInvoice.total))
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    StatusIndicator(isActive: recurringInvoice.isActive)
                }
            }
            
            HStack {
                Label("Next Due", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(recurringInvoice.nextDueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if recurringInvoice.generatedInvoiceIds.count > 0 {
                    Text("\(recurringInvoice.generatedInvoiceIds.count) generated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let lastGenerated = recurringInvoice.lastGeneratedDate {
                Text("Last generated: \(lastGenerated, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            RecurringInvoiceDetailView(recurringInvoice: recurringInvoice)
        }
    }
}

struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(isActive ? "Active" : "Inactive")
                .font(.caption)
                .foregroundColor(isActive ? .green : .red)
        }
    }
}

struct CreateRecurringInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var selectedInvoice: Invoice?
    @State private var frequency: RecurrenceFrequency = .monthly
    @State private var endDate: Date?
    @State private var hasEndDate = false
    @State private var showingInvoicePicker = false
    
    var availableInvoices: [Invoice] {
        dataManager.invoices.filter { invoice in
            !dataManager.recurringInvoices.contains { $0.templateInvoice.id == invoice.id }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Template Invoice") {
                    if let invoice = selectedInvoice {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(invoice.invoiceNumber)
                                .fontWeight(.medium)
                            Text(invoice.client.name)
                                .foregroundColor(.secondary)
                            Text(String(format: "$%.2f", invoice.total))
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    } else {
                        Button("Select Invoice Template") {
                            showingInvoicePicker = true
                        }
                    }
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section("End Date") {
                    Toggle("Set End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                if let invoice = selectedInvoice {
                    Section("Preview") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("This will create:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("• \(frequency.rawValue) invoices for \(invoice.client.name)")
                            Text("• Amount: \(String(format: "$%.2f", invoice.total)) each")
                            Text("• Next invoice: \(Calendar.current.date(byAdding: .day, value: frequency.dayInterval, to: Date())?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                            
                            if hasEndDate, let end = endDate {
                                Text("• Ending: \(end.formatted(date: .abbreviated, time: .omitted))")
                            } else {
                                Text("• No end date (continues indefinitely)")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Create Recurring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createRecurringInvoice()
                    }
                    .disabled(selectedInvoice == nil)
                }
            }
            .sheet(isPresented: $showingInvoicePicker) {
                InvoicePickerView(
                    invoices: availableInvoices,
                    selectedInvoice: $selectedInvoice
                )
            }
        }
    }
    
    private func createRecurringInvoice() {
        guard let invoice = selectedInvoice else { return }
        
        let recurring = RecurringInvoice(templateInvoice: invoice, frequency: frequency)
        var newRecurring = recurring
        newRecurring.endDate = hasEndDate ? endDate : nil
        
        dataManager.addRecurringInvoice(newRecurring)
        dismiss()
    }
}

struct InvoicePickerView: View {
    let invoices: [Invoice]
    @Binding var selectedInvoice: Invoice?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if invoices.isEmpty {
                    VStack(spacing: 16) {
                        Text("No Available Invoices")
                            .font(.headline)
                        Text("Create some invoices first to use as templates")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(invoices) { invoice in
                        Button(action: {
                            selectedInvoice = invoice
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(invoice.invoiceNumber)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "$%.2f", invoice.total))
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                
                                Text(invoice.client.name)
                                    .foregroundColor(.secondary)
                                
                                Text("Created: \(invoice.createdDate, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Select Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RecurringInvoiceDetailView: View {
    @State var recurringInvoice: RecurringInvoice
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Template Invoice") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(recurringInvoice.templateInvoice.invoiceNumber)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", recurringInvoice.templateInvoice.total))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Text(recurringInvoice.templateInvoice.client.name)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Schedule") {
                    HStack {
                        Text("Frequency")
                        Spacer()
                        Text(recurringInvoice.frequency.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Next Due Date")
                        Spacer()
                        Text(recurringInvoice.nextDueDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        StatusIndicator(isActive: recurringInvoice.isActive)
                    }
                    
                    if let endDate = recurringInvoice.endDate {
                        HStack {
                            Text("End Date")
                            Spacer()
                            Text(endDate, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("History") {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(recurringInvoice.createdDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastGenerated = recurringInvoice.lastGeneratedDate {
                        HStack {
                            Text("Last Generated")
                            Spacer()
                            Text(lastGenerated, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Total Generated")
                        Spacer()
                        Text("\(recurringInvoice.generatedInvoiceIds.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(recurringInvoice.isActive ? "Pause Recurring" : "Resume Recurring") {
                        toggleActiveStatus()
                    }
                    .foregroundColor(recurringInvoice.isActive ? .orange : .green)
                    
                    Button("Generate Invoice Now") {
                        generateInvoiceNow()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Recurring Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleActiveStatus() {
        recurringInvoice.isActive.toggle()
        dataManager.updateRecurringInvoice(recurringInvoice)
    }
    
    private func generateInvoiceNow() {
        // This would trigger the generation logic manually
        // For now, just show it's possible
    }
}