import SwiftUI
import RevenueCat

struct AddEditInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingPaywall = false
    
    @State private var invoice: Invoice
    @State private var selectedClient: Client?
    @State private var showingClientPicker = false
    
    private let isEditing: Bool
    
    init(invoice: Invoice? = nil) {
        self.isEditing = invoice != nil
        self._invoice = State(initialValue: invoice ?? Invoice())
        if let invoice = invoice {
            self._selectedClient = State(initialValue: invoice.client)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice Details") {
                    TextField("Invoice Number", text: $invoice.invoiceNumber)
                    
                    DatePicker("Issue Date", selection: $invoice.issueDate, displayedComponents: .date)
                    
                    DatePicker("Due Date", selection: $invoice.dueDate, displayedComponents: .date)
                    
                    Picker("Status", selection: $invoice.status) {
                        ForEach(InvoiceStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
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
                
                Section("Line Items") {
                    ForEach(invoice.lineItems.indices, id: \.self) { index in
                        LineItemRow(lineItem: $invoice.lineItems[index])
                    }
                    .onDelete(perform: deleteLineItem)
                    
                    Button("Add Item") {
                        invoice.lineItems.append(LineItem())
                    }
                }
                
                Section("Summary") {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(invoice.subtotal.currencyFormatted)
                    }
                    
                    HStack {
                        Text("Tax Rate")
                        Spacer()
                        TextField("Tax Rate", value: $invoice.taxRate, format: .percent)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Tax Amount")
                        Spacer()
                        Text(invoice.taxAmount.currencyFormatted)
                    }
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(invoice.total.currencyFormatted)
                            .fontWeight(.bold)
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $invoice.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Invoice" : "New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInvoice()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingClientPicker) {
                ClientPickerView(selectedClient: $selectedClient)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .onAppear {
            if selectedClient == nil && !dataManager.clients.isEmpty {
                selectedClient = dataManager.clients.first
            }
        }
    }
    
    private var canSave: Bool {
        selectedClient != nil && 
        !invoice.invoiceNumber.isEmpty && 
        !invoice.lineItems.isEmpty &&
        invoice.lineItems.contains { !$0.description.isEmpty && $0.unitPrice > 0 }
    }
    
    private func deleteLineItem(at offsets: IndexSet) {
        invoice.lineItems.remove(atOffsets: offsets)
        if invoice.lineItems.isEmpty {
            invoice.lineItems.append(LineItem())
        }
    }
    
    private func saveInvoice() {
        guard let client = selectedClient else { return }

        // Check invoice limit for non-subscribers
        if !isEditing && !subscriptionManager.isSubscribed {
            let freeInvoiceLimit = 3
            if dataManager.invoices.count >= freeInvoiceLimit {
                showingPaywall = true
                return
            }
        }

        invoice.client = client

        if isEditing {
            dataManager.updateInvoice(invoice)
        } else {
            dataManager.addInvoice(invoice)
        }
        dismiss()
    }
}

struct LineItemRow: View {
    @Binding var lineItem: LineItem
    
    var body: some View {
        VStack(spacing: 8) {
            TextField("Description", text: $lineItem.description)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Qty", value: $lineItem.quantity, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Unit Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Price", value: $lineItem.unitPrice, format: .currency(code: "USD"))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .trailing) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lineItem.total.currencyFormatted)
                        .fontWeight(.medium)
                        .frame(minWidth: 60, alignment: .trailing)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ClientPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    @Binding var selectedClient: Client?
    @State private var showingAddClient = false
    
    var body: some View {
        NavigationStack {
            List {
                if dataManager.clients.isEmpty {
                    VStack(spacing: 16) {
                        Text("No Clients Available")
                            .font(.headline)
                        Text("Add your first client to create invoices")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Add Client") {
                            showingAddClient = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(dataManager.clients) { client in
                        Button(action: {
                            selectedClient = client
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(client.name)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    if !client.email.isEmpty {
                                        Text(client.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if selectedClient?.id == client.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if !dataManager.clients.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add New") {
                            showingAddClient = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddEditClientView()
            }
        }
    }
}