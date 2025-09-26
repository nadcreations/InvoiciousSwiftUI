import SwiftUI

struct AddEditEstimateView: View {
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedClient: Client?
    @State private var showingClientPicker = false
    @State private var lineItems: [LineItem] = [LineItem()]
    @State private var taxRate: Double = 0.08
    @State private var validDays: Int = 30
    @State private var notes: String = ""
    @State private var showingAddClient = false
    
    private var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }
    
    private var taxAmount: Double {
        subtotal * taxRate
    }
    
    private var total: Double {
        subtotal + taxAmount
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Client Information") {
                    if let client = selectedClient {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(client.name)
                                    .font(.headline)
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
                        }
                    } else {
                        Button("Select Client") {
                            showingClientPicker = true
                        }
                    }
                    
                    Button("Add New Client") {
                        showingAddClient = true
                    }
                }
                
                Section("Line Items") {
                    ForEach(lineItems.indices, id: \.self) { index in
                        VStack {
                            TextField("Description", text: $lineItems[index].description)
                            
                            HStack {
                                TextField("Qty", value: $lineItems[index].quantity, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 60)
                                
                                TextField("Unit Price", value: $lineItems[index].unitPrice, format: .currency(code: "USD"))
                                    .keyboardType(.decimalPad)
                                
                                Text(lineItems[index].total.currencyFormatted)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                            }
                        }
                    }
                    .onDelete(perform: removeLineItem)
                    
                    Button("Add Line Item") {
                        lineItems.append(LineItem())
                    }
                }
                
                Section("Estimate Details") {
                    HStack {
                        Text("Tax Rate")
                        Spacer()
                        TextField("Tax Rate", value: $taxRate, format: .percent.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Valid for")
                        Spacer()
                        TextField("Days", value: $validDays, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("days")
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Total") {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(subtotal.currencyFormatted)
                    }
                    
                    HStack {
                        Text("Tax")
                        Spacer()
                        Text(taxAmount.currencyFormatted)
                    }
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(total.currencyFormatted)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("New Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEstimate()
                    }
                    .disabled(selectedClient == nil || lineItems.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingClientPicker) {
            EstimateClientPickerView(selectedClient: $selectedClient)
        }
        .sheet(isPresented: $showingAddClient) {
            AddEditClientView()
        }
    }
    
    private func removeLineItem(at offsets: IndexSet) {
        if lineItems.count > 1 {
            lineItems.remove(atOffsets: offsets)
        }
    }
    
    private func saveEstimate() {
        guard let client = selectedClient else { return }
        
        var estimate = Estimate(client: client, notes: notes)
        estimate.lineItems = lineItems.filter { !$0.description.isEmpty }
        estimate.taxRate = taxRate
        estimate.validUntil = Calendar.current.date(byAdding: .day, value: validDays, to: Date()) ?? Date()
        
        dataManager.addEstimate(estimate)
        dismiss()
    }
}

struct EstimateClientPickerView: View {
    @StateObject private var dataManager = DataManager.shared
    @Binding var selectedClient: Client?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(dataManager.clients) { client in
                Button(action: {
                    selectedClient = client
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(client.name)
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
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddEditEstimateView()
}