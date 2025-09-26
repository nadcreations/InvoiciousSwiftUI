import SwiftUI

struct PaymentTrackingView: View {
    @Binding var invoice: Invoice
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddPayment = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Invoice Summary") {
                    HStack {
                        Text("Total Amount")
                        Spacer()
                        Text(invoice.total.currencyFormatted)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Total Paid")
                        Spacer()
                        Text(invoice.totalPaid.currencyFormatted)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Remaining Balance")
                        Spacer()
                        Text(invoice.remainingBalance.currencyFormatted)
                            .foregroundColor(invoice.remainingBalance > 0 ? .red : .green)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        ModernStatusBadge(status: invoice.effectiveStatus)
                    }
                }
                
                Section("Payment History") {
                    if invoice.payments.isEmpty {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(.gray)
                            Text("No payments recorded")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(invoice.payments.sorted { $0.paymentDate > $1.paymentDate }) { payment in
                            PaymentRowView(payment: payment)
                        }
                        .onDelete(perform: deletePayment)
                    }
                }
            }
            .navigationTitle("Payment Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Payment") {
                        showingAddPayment = true
                    }
                    .disabled(invoice.isFullyPaid)
                }
            }
            .sheet(isPresented: $showingAddPayment) {
                AddPaymentView(invoice: $invoice)
            }
        }
    }
    
    private func deletePayment(at offsets: IndexSet) {
        let sortedPayments = invoice.payments.sorted { $0.paymentDate > $1.paymentDate }
        for index in offsets {
            let paymentToDelete = sortedPayments[index]
            invoice.payments.removeAll { $0.id == paymentToDelete.id }
        }
        dataManager.updateInvoice(invoice)
    }
}

struct PaymentRowView: View {
    let payment: Payment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(payment.amount.currencyFormatted)
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(payment.paymentDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(payment.paymentMethod.rawValue, systemImage: paymentMethodIcon(payment.paymentMethod))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !payment.reference.isEmpty {
                    Text("Ref: \(payment.reference)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !payment.notes.isEmpty {
                Text(payment.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
    
    private func paymentMethodIcon(_ method: PaymentMethod) -> String {
        switch method {
        case .cash:
            return "banknote"
        case .check:
            return "doc.text"
        case .creditCard:
            return "creditcard"
        case .bankTransfer:
            return "building.columns"
        case .paypal:
            return "globe"
        case .other:
            return "questionmark.circle"
        }
    }
}

struct AddPaymentView: View {
    @Binding var invoice: Invoice
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: Double = 0
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var reference: String = ""
    @State private var notes: String = ""
    @State private var paymentDate = Date()
    
    var maxAmount: Double {
        invoice.remainingBalance
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Payment Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Remaining Balance")
                        Spacer()
                        Text(maxAmount.currencyFormatted)
                            .foregroundColor(.secondary)
                    }
                    
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                    
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }
                
                Section("Additional Information") {
                    TextField("Reference Number (Optional)", text: $reference)
                    
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Quick Fill Remaining Balance") {
                        amount = maxAmount
                    }
                    .disabled(maxAmount <= 0)
                }
            }
            .navigationTitle("Add Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePayment()
                    }
                    .disabled(amount <= 0 || amount > maxAmount)
                }
            }
        }
        .onAppear {
            amount = maxAmount
        }
    }
    
    private func savePayment() {
        let payment = Payment(
            amount: amount,
            paymentMethod: paymentMethod,
            reference: reference,
            notes: notes
        )
        
        var updatedPayment = payment
        updatedPayment.paymentDate = paymentDate
        
        invoice.payments.append(updatedPayment)
        
        // Update invoice status based on payment
        if invoice.isFullyPaid {
            invoice.status = .paid
        } else if invoice.isPartiallyPaid {
            invoice.status = .partiallyPaid
        }
        
        // Note: Invoice will be saved by parent view via binding
        dismiss()
    }
}