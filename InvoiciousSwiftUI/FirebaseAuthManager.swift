import Foundation
import FirebaseAuth
import SwiftUI

// MARK: - Authentication Manager
@MainActor
class FirebaseAuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update user profile with full name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            print("✅ User registered successfully: \(result.user.email ?? "")")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign up error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ User signed in successfully: \(result.user.email ?? "")")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign in error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("✅ User signed out successfully")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("✅ Password reset email sent to: \(email)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Password reset error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Account (Apple App Store Compliance)
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }

        isLoading = true
        errorMessage = ""

        do {
            // Step 1: Delete all local user data first
            DataManager.shared.deleteAllUserData()
            print("✅ Local user data deleted successfully")

            // Step 2: Delete Firebase Auth account
            try await user.delete()
            print("✅ Firebase user account deleted successfully")

            // Step 3: Update authentication state
            self.user = nil
            self.isAuthenticated = false

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Account deletion error: \(error.localizedDescription)")

            // If Firebase deletion fails but local data was cleared,
            // we should inform the user appropriately
            if errorMessage.contains("requires-recent-login") {
                errorMessage = "For security reasons, please sign out and sign back in, then try deleting your account again."
            }
        }

        isLoading = false
    }
    
    // MARK: - Helper Methods
    var currentUserEmail: String {
        return user?.email ?? ""
    }
    
    var currentUserDisplayName: String {
        return user?.displayName ?? "User"
    }
    
    var currentUserId: String {
        return user?.uid ?? ""
    }
}

// MARK: - Authentication State
enum AuthState {
    case loading
    case authenticated
    case unauthenticated
}