//
//  SettingsViews.swift
//  DashApp iOS
//
//  RSS Feed and all Settings screens (Account, General, Privacy, Admin)
//

import SwiftUI

// MARK: - RSS Feed View
struct RSSFeedView: View {
    @State private var newsItems: [NewsItem] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if newsItems.isEmpty {
                        // Placeholder content
                        VStack(spacing: 20) {
                            Image(systemName: "newspaper.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "3A86FF").opacity(0.3))

                            Text("News Feed")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Your personalized news feed will appear here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(newsItems) { item in
                            NewsCard(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("News Feed")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewsCard: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)

            HStack {
                Text(item.source)
                    .font(.caption)
                    .foregroundColor(Color(hex: "3A86FF"))

                Spacer()

                Text(item.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let source: String
    let date: String
}

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showSignOutAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: AccountSettingsView()) {
                        SettingsRow(icon: "person.fill", title: "Account Settings", color: Color(hex: "3A86FF"))
                    }

                    NavigationLink(destination: GeneralSettingsView()) {
                        SettingsRow(icon: "gearshape.fill", title: "General Settings", color: .gray)
                    }

                    NavigationLink(destination: PrivacySettingsView()) {
                        SettingsRow(icon: "lock.fill", title: "Privacy Settings", color: .green)
                    }

                    NavigationLink(destination: AdminSettingsView()) {
                        SettingsRow(icon: "shield.fill", title: "Admin Settings", color: Color(hex: "8338EC"))
                    }
                }

                Section {
                    Button(action: {
                        showSignOutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Account Settings View
struct AccountSettingsView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var licensePlate = ""
    @State private var displayName = ""
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Profile Information")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(authManager.currentUser?.email ?? "N/A")
                        .foregroundColor(.gray)
                }

                TextField("Display Name", text: $displayName)

                TextField("License Plate", text: $licensePlate)
                    .autocapitalization(.allCharacters)
            }

            Section {
                Button(action: saveProfile) {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(hex: "3A86FF"))
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Account Settings")
        .onAppear(perform: loadProfile)
        .alert("Account", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    func loadProfile() {
        guard let userId = authManager.userId else { return }

        Task {
            do {
                let profiles: [UserProfile] = try await authManager.client
                    .from("profiles")
                    .select()
                    .eq("id", value: userId)
                    .execute()
                    .value

                if let profile = profiles.first {
                    await MainActor.run {
                        self.displayName = profile.display_name ?? ""
                        self.licensePlate = profile.license_plate ?? ""
                    }
                }
            } catch {
                print("Error loading profile: \(error)")
            }
        }
    }

    func saveProfile() {
        guard let userId = authManager.userId else { return }

        isSaving = true

        Task {
            do {
                let profileData: [String: Any] = [
                    "id": userId,
                    "display_name": displayName,
                    "license_plate": licensePlate.uppercased()
                ]

                try await authManager.client
                    .from("profiles")
                    .upsert(profileData)
                    .execute()

                await MainActor.run {
                    isSaving = false
                    alertMessage = "Profile updated successfully!"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    alertMessage = "Error saving profile: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct UserProfile: Codable {
    let id: String
    let email: String?
    let display_name: String?
    let license_plate: String?
}

// MARK: - General Settings View
struct GeneralSettingsView: View {
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var autoUpdateLocation = true

    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Sound", isOn: $soundEnabled)
                    .disabled(!notificationsEnabled)
                Toggle("Vibration", isOn: $vibrationEnabled)
                    .disabled(!notificationsEnabled)
            }

            Section(header: Text("Location")) {
                Toggle("Auto-update Location", isOn: $autoUpdateLocation)

                Text("Your location will be updated automatically when using the map.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Section(header: Text("Appearance")) {
                HStack {
                    Text("Theme")
                    Spacer()
                    Text("System")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("General Settings")
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    @State private var shareLocation = true
    @State private var showOnlineStatus = true
    @State private var allowContactRequests = true

    var body: some View {
        Form {
            Section(header: Text("Location Privacy")) {
                Toggle("Share Location with Contacts", isOn: $shareLocation)

                Text("When enabled, your contacts can see your vehicle location on the map.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Section(header: Text("Chat Privacy")) {
                Toggle("Show Online Status", isOn: $showOnlineStatus)
                Toggle("Allow Contact Requests", isOn: $allowContactRequests)
            }

            Section(header: Text("License Plate")) {
                Toggle("Show in Directory", isOn: .constant(true))

                Text("Your license plate is visible to others for chat purposes.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Section {
                Button("Clear Chat History") {
                    // Clear chat history
                }
                .foregroundColor(.red)

                Button("Delete Account") {
                    // Delete account
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Privacy Settings")
    }
}

// MARK: - Admin Settings View
struct AdminSettingsView: View {
    @State private var debugMode = false
    @State private var showLogs = false

    var body: some View {
        Form {
            Section(header: Text("Developer Options")) {
                Toggle("Debug Mode", isOn: $debugMode)
                Toggle("Show Logs", isOn: $showLogs)
            }

            Section(header: Text("Database")) {
                Button("Clear Cache") {
                    // Clear cache
                }

                Button("Sync Data") {
                    // Sync data
                }
            }

            Section(header: Text("Diagnostics")) {
                HStack {
                    Text("Supabase Status")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                HStack {
                    Text("API Version")
                    Spacer()
                    Text("v1.0")
                        .foregroundColor(.gray)
                }
            }

            Section {
                Button("Export Logs") {
                    // Export logs
                }
                .foregroundColor(Color(hex: "3A86FF"))
            }
        }
        .navigationTitle("Admin Settings")
    }
}

#Preview("RSS Feed") {
    RSSFeedView()
}

#Preview("Settings") {
    SettingsView()
}

#Preview("Account Settings") {
    AccountSettingsView()
}
