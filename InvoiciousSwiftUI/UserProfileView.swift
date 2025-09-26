import SwiftUI
import FirebaseAuth

// MARK: - User Profile View
struct UserProfileView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingErrorAlert = false
    @State private var isEditingProfile = false
    @State private var newDisplayName = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                    
                    // Profile Header
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primaryGradient)
                                .frame(width: 100, height: 100)
                            
                            Text(authManager.currentUserDisplayName.prefix(2).uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            if isEditingProfile {
                                TextField("Display Name", text: $newDisplayName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .frame(maxWidth: 200)
                            } else {
                                Text(authManager.currentUserDisplayName)
                                    .font(DesignSystem.Typography.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            
                            Text(authManager.currentUserEmail)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            if isEditingProfile {
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    Button("Cancel") {
                                        isEditingProfile = false
                                        newDisplayName = authManager.currentUserDisplayName
                                    }
                                    .professionalButton(style: .ghost, size: .small)
                                    
                                    Button("Save") {
                                        updateDisplayName()
                                    }
                                    .professionalButton(style: .primary, size: .small)
                                    .disabled(newDisplayName.isEmpty)
                                }
                            } else {
                                Button("Edit Profile") {
                                    isEditingProfile = true
                                    newDisplayName = authManager.currentUserDisplayName
                                }
                                .professionalButton(style: .ghost, size: .small)
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.xxxl)
                    .background(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primaryUltraLight,
                                DesignSystem.Colors.background
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Account Information
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Account Information")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ProfileInfoRow(
                                title: "User ID",
                                value: authManager.currentUserId,
                                icon: "person.circle"
                            )
                            
                            ProfileInfoRow(
                                title: "Account Created",
                                value: formatAccountCreationDate(),
                                icon: "calendar"
                            )
                            
                            ProfileInfoRow(
                                title: "Authentication",
                                value: "Email & Password",
                                icon: "key"
                            )
                        }
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .sleekCard(elevation: 1)
                    
                    // Account Actions
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Account Actions")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ProfileActionRow(
                                title: "Change Password",
                                subtitle: "Update your account password",
                                icon: "lock.rotation",
                                action: resetPassword
                            )
                            
                            ProfileActionRow(
                                title: "Sign Out",
                                subtitle: "Sign out of your account",
                                icon: "rectangle.portrait.and.arrow.right",
                                action: { showingSignOutAlert = true },
                                destructive: false
                            )
                            
                            ProfileActionRow(
                                title: "Delete Account",
                                subtitle: "Permanently delete your account and all data",
                                icon: "trash",
                                action: { showingDeleteAccountAlert = true },
                                destructive: true,
                                isLoading: authManager.isLoading
                            )
                        }
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .sleekCard(elevation: 1)
                    
                    Spacer(minLength: DesignSystem.Spacing.massive)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .professionalButton(style: .ghost, size: .small)
                }
            }
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                Task {
                    await authManager.deleteAccount()
                    if !authManager.errorMessage.isEmpty {
                        showingErrorAlert = true
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. All your invoices, clients, business data, and account information will be permanently deleted from this device and our servers.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") {
                authManager.errorMessage = ""
            }
        } message: {
            Text(authManager.errorMessage)
        }
    }
    
    private func updateDisplayName() {
        guard let user = Auth.auth().currentUser else { return }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newDisplayName
        
        changeRequest.commitChanges { error in
            if let error = error {
                print("❌ Error updating display name: \(error.localizedDescription)")
            } else {
                print("✅ Display name updated successfully")
                isEditingProfile = false
            }
        }
    }
    
    private func resetPassword() {
        Task {
            await authManager.resetPassword(email: authManager.currentUserEmail)
        }
    }
    
    private func formatAccountCreationDate() -> String {
        guard let user = Auth.auth().currentUser,
              let creationDate = user.metadata.creationDate else {
            return "Unknown"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: creationDate)
    }
}

// MARK: - Profile Info Row
struct ProfileInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text(value)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Profile Action Row
struct ProfileActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    let destructive: Bool
    let isLoading: Bool

    init(title: String, subtitle: String, icon: String, action: @escaping () -> Void, destructive: Bool = false, isLoading: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
        self.destructive = destructive
        self.isLoading = isLoading
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: destructive ? DesignSystem.Colors.error : DesignSystem.Colors.primary))
                        .scaleEffect(0.8)
                        .frame(width: 24)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(destructive ? DesignSystem.Colors.error : DesignSystem.Colors.primary)
                        .frame(width: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(destructive ? DesignSystem.Colors.error : DesignSystem.Colors.textPrimary)

                    Text(isLoading ? "Processing..." : subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()

                if !isLoading {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    UserProfileView()
}