//
//  AuthView.swift
//  DashApp iOS
//
//  Login and signup screens
//

import SwiftUI

struct AuthView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showError = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "3A86FF").opacity(0.1),
                    Color(hex: "8338EC").opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Logo
                VStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "3A86FF"))

                    Text("DASH")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "3A86FF"))
                }
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 20) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    // Error message
                    if let error = authManager.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Sign In/Up Button
                    Button(action: {
                        Task {
                            do {
                                if isSignUp {
                                    try await authManager.signUp(email: email, password: password)
                                } else {
                                    try await authManager.signIn(email: email, password: password)
                                }
                            } catch {
                                showError = true
                            }
                        }
                    }) {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "3A86FF"),
                                Color(hex: "8338EC")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)

                    // Toggle between Sign In and Sign Up
                    Button(action: {
                        isSignUp.toggle()
                        authManager.errorMessage = nil
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "3A86FF"))
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
                Spacer()
            }
        }
    }
}

// Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    AuthView()
}
