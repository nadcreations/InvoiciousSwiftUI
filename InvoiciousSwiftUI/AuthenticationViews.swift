import SwiftUI
import FirebaseAuth

// MARK: - Authentication Root View
struct AuthenticationView: View {
    @StateObject private var authManager = FirebaseAuthManager()
    @State private var showingSignUp = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // User is logged in - show main app
                ContentView()
                    .environmentObject(authManager)
            } else {
                // User is not logged in - show sign in
                if showingSignUp {
                    SignUpView(authManager: authManager, showingSignUp: $showingSignUp)
                } else {
                    SignInView(authManager: authManager, showingSignUp: $showingSignUp)
                }
            }
        }
    }
}

// MARK: - Sign In View
struct SignInView: View {
    @ObservedObject var authManager: FirebaseAuthManager
    @Binding var showingSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    
                    // Header Section
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // App Logo/Icon
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primaryGradient)
                                .frame(width: 120, height: 120)

                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Welcome to Invoicious")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Professional invoice management made simple")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xxxl)
                    
                    // Sign In Form
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            // Email Field
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Email Address")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .focused($focusedField, equals: .email)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Password")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($focusedField, equals: .password)
                            }
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showingForgotPassword = true
                            }
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        // Error Message
                        if !authManager.errorMessage.isEmpty {
                            Text(authManager.errorMessage)
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.error)
                                .padding()
                                .background(DesignSystem.Colors.errorLight.opacity(0.1))
                                .cornerRadius(DesignSystem.CornerRadius.md)
                        }
                        
                        // Sign In Button
                        Button(action: signIn) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(authManager.isLoading ? "Signing In..." : "Sign In")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .professionalButton(style: .primary, size: .large)
                        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .sleekCard(elevation: 2)
                    
                    // Sign Up Section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Don't have an account?")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Button("Create Account") {
                            showingSignUp = true
                        }
                        .professionalButton(style: .ghost, size: .medium)
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.massive)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarHidden(true)
            .onSubmit {
                switch focusedField {
                case .email:
                    focusedField = .password
                case .password:
                    signIn()
                case .none:
                    break
                }
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView(authManager: authManager)
        }
    }
    
    private func signIn() {
        focusedField = nil
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

// MARK: - Sign Up View
struct SignUpView: View {
    @ObservedObject var authManager: FirebaseAuthManager
    @Binding var showingSignUp: Bool
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case fullName, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    
                    // Header Section
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // App Logo/Icon
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primaryGradient)
                                .frame(width: 100, height: 100)

                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Create Your Account")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Join thousands of professionals using Invoicious")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    
                    // Sign Up Form
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            // Full Name Field
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Full Name")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                TextField("Enter your full name", text: $fullName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($focusedField, equals: .fullName)
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Email Address")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .focused($focusedField, equals: .email)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Password")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                SecureField("Create a password", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($focusedField, equals: .password)
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Confirm Password")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($focusedField, equals: .confirmPassword)
                            }
                        }
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password Requirements:")
                                .font(DesignSystem.Typography.caption1)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(password.count >= 6 ? .green : DesignSystem.Colors.textTertiary)
                                Text("At least 6 characters")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                Spacer()
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(passwordsMatch ? .green : DesignSystem.Colors.textTertiary)
                                Text("Passwords match")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                Spacer()
                            }
                        }
                        
                        // Error Message
                        if !authManager.errorMessage.isEmpty {
                            Text(authManager.errorMessage)
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.error)
                                .padding()
                                .background(DesignSystem.Colors.errorLight.opacity(0.1))
                                .cornerRadius(DesignSystem.CornerRadius.md)
                        }
                        
                        // Create Account Button
                        Button(action: signUp) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(authManager.isLoading ? "Creating Account..." : "Create Account")
                                    .font(DesignSystem.Typography.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .professionalButton(style: .primary, size: .large)
                        .disabled(authManager.isLoading || !canCreateAccount)
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                    .sleekCard(elevation: 2)
                    
                    // Sign In Section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Already have an account?")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Button("Sign In") {
                            showingSignUp = false
                        }
                        .professionalButton(style: .ghost, size: .medium)
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.massive)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarHidden(true)
            .onSubmit {
                switch focusedField {
                case .fullName:
                    focusedField = .email
                case .email:
                    focusedField = .password
                case .password:
                    focusedField = .confirmPassword
                case .confirmPassword:
                    if canCreateAccount {
                        signUp()
                    }
                case .none:
                    break
                }
            }
        }
    }
    
    private var passwordsMatch: Bool {
        !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    private var canCreateAccount: Bool {
        !fullName.isEmpty && 
        !email.isEmpty && 
        password.count >= 6 && 
        passwordsMatch
    }
    
    private func signUp() {
        focusedField = nil
        Task {
            await authManager.signUp(email: email, password: password, fullName: fullName)
        }
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @ObservedObject var authManager: FirebaseAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.xl) {
                
                // Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Reset Password")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Enter your email address and we'll send you a link to reset your password.")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Email Input
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Email Address")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                // Error Message
                if !authManager.errorMessage.isEmpty {
                    Text(authManager.errorMessage)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.error)
                        .padding()
                        .background(DesignSystem.Colors.errorLight.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.md)
                }
                
                // Send Reset Email Button
                Button(action: sendResetEmail) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(authManager.isLoading ? "Sending..." : "Send Reset Email")
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                    }
                }
                .professionalButton(style: .primary, size: .large)
                .disabled(authManager.isLoading || email.isEmpty)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.screenPadding)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Password Reset Sent", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("We've sent a password reset link to \(email). Please check your email and follow the instructions.")
        }
    }
    
    private func sendResetEmail() {
        Task {
            await authManager.resetPassword(email: email)
            if authManager.errorMessage.isEmpty {
                showingSuccessAlert = true
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.borderLight, lineWidth: 1)
            )
    }
}

#Preview {
    AuthenticationView()
}