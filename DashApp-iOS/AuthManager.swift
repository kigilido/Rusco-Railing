//
//  AuthManager.swift
//  DashApp iOS
//
//  Supabase authentication manager with your actual credentials
//

import Foundation
import Supabase

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Your actual Supabase credentials from the conversation
    private let supabaseURL = "https://klrqtalpeudkuotsoaik.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtscnF0YWxwZXVka3VvdHNvYWlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgyODE0NzQsImV4cCI6MjA1Mzg1NzQ3NH0.kjrxlWT58g9wIkKdbeiN1ZVDNbk6dsthgQCpzhWBmWE"

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }

    // Check current session
    func checkSession() {
        Task {
            do {
                let session = try await client.auth.session
                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = session.user
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }

    // Sign in with email and password
    func signIn(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )

            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = session.user
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    // Sign up with email and password
    func signUp(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password
            )

            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = session.user
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }

    // Sign out
    func signOut() async {
        do {
            try await client.auth.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }

    // Get current user ID
    var userId: String? {
        return currentUser?.id.uuidString
    }
}
