import SwiftUI

struct ClientListView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddClient = false
    @State private var searchText = ""
    
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return dataManager.clients
        } else {
            return dataManager.clients.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataManager.clients.isEmpty {
                    EmptyClientView {
                        showingAddClient = true
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(Array(filteredClients.enumerated()), id: \.element.id) { index, client in
                                NavigationLink(destination: ClientDetailView(client: client)) {
                                    ClientRowView(client: client, index: index)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    }
                    .searchable(text: $searchText, prompt: "Search clients...")
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddEditClientView()
            }
        }
    }
    
    private func deleteClients(at offsets: IndexSet) {
        for index in offsets {
            let client = filteredClients[index]
            dataManager.deleteClient(client)
        }
    }
}

struct EmptyClientView: View {
    let onAddClient: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Clients Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add clients to start creating invoices")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Client", action: onAddClient)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct ClientRowView: View {
    let client: Client
    let index: Int

    init(client: Client, index: Int = 0) {
        self.client = client
        self.index = index
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(client.name)
                .font(.headline)
            
            if !client.email.isEmpty {
                Text(client.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !client.phone.isEmpty {
                Text(client.phone)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.cardPadding)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(index % 2 == 0 ? DesignSystem.Colors.surface : DesignSystem.Colors.infoLight)
        .cornerRadius(DesignSystem.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}

struct ClientDetailView: View {
    let client: Client
    @State private var showingEdit = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact Information")
                        .font(.headline)
                    
                    if !client.email.isEmpty {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text(client.email)
                        }
                    }
                    
                    if !client.phone.isEmpty {
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text(client.phone)
                        }
                    }
                }
                
                if !client.address.isEmpty || !client.city.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if !client.address.isEmpty {
                                Text(client.address)
                            }
                            
                            HStack {
                                if !client.city.isEmpty {
                                    Text(client.city)
                                }
                                if !client.state.isEmpty {
                                    Text(client.state)
                                }
                                if !client.zipCode.isEmpty {
                                    Text(client.zipCode)
                                }
                            }
                            
                            if !client.country.isEmpty {
                                Text(client.country)
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(client.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditClientView(client: client)
        }
    }
}

struct AddEditClientView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var client: Client
    
    private let isEditing: Bool
    
    init(client: Client? = nil) {
        self.isEditing = client != nil
        self._client = State(initialValue: client ?? Client())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Client Name", text: $client.name)
                    TextField("Email", text: $client.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $client.phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Address") {
                    TextField("Street Address", text: $client.address)
                    TextField("City", text: $client.city)
                    TextField("State/Province", text: $client.state)
                    TextField("ZIP/Postal Code", text: $client.zipCode)
                    TextField("Country", text: $client.country)
                }
            }
            .navigationTitle(isEditing ? "Edit Client" : "Add Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveClient()
                    }
                    .disabled(client.name.isEmpty)
                }
            }
        }
    }
    
    private func saveClient() {
        if isEditing {
            dataManager.updateClient(client)
        } else {
            dataManager.addClient(client)
        }
        dismiss()
    }
}