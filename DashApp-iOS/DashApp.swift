//
//  DashApp.swift
//  DashApp iOS
//
//  Main application entry point with splash screen and tab navigation
//

import SwiftUI

@main
struct DashApp: App {
    @StateObject private var authManager = AuthManager.shared
    @State private var showSplash = true
    @State private var selectedTab = 2 // Default to Chat (index 2)

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    if authManager.isAuthenticated {
                        MainTabView(selectedTab: $selectedTab)
                            .transition(.opacity)
                    } else {
                        AuthView()
                            .transition(.opacity)
                    }
                }
            }
            .onAppear {
                // Show splash for 2 seconds then check auth
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }

                // Check auth session
                authManager.checkSession()
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "3A86FF"),
                    Color(hex: "8338EC")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Lightning bolt logo
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)

                Text("DASH")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @Binding var selectedTab: Int
    @State private var showMapMenu = false
    @State private var showChatMenu = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                RSSFeedView()
                    .tag(0)

                ChatScreen()
                    .tag(1)

                ScanScreen()
                    .tag(2)

                MapScreen()
                    .tag(3)

                SettingsView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, showMapMenu: $showMapMenu, showChatMenu: $showChatMenu)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showChatMenu) {
            ChatMenuSheet()
        }
        .sheet(isPresented: $showMapMenu) {
            MapMenuSheet()
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showMapMenu: Bool
    @Binding var showChatMenu: Bool

    let tabs = [
        ("RSS", "newspaper", 0),
        ("Chat", "message", 1),
        ("Scan", "camera.viewfinder", 2),
        ("Map", "map", 3),
        ("Settings", "gearshape", 4)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.2) { tab in
                Button(action: {
                    selectedTab = tab.2
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.1)
                            .font(.system(size: 20))
                        Text(tab.0)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == tab.2 ? Color(hex: "3A86FF") : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            if tab.0 == "Map" {
                                showMapMenu = true
                            } else if tab.0 == "Chat" {
                                showChatMenu = true
                            }
                        }
                )
            }
        }
        .frame(height: 60)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// MARK: - Context Menus
struct ChatMenuSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Button("New Group Chat") {
                    dismiss()
                }
                Button("Mute Notifications") {
                    dismiss()
                }
                Button("Mark All as Read") {
                    dismiss()
                }
                Button("Chat Settings") {
                    dismiss()
                }
            }
            .navigationTitle("Chat Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct MapMenuSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Button("Share Location") {
                    dismiss()
                }
                Button("Save to Favorites") {
                    dismiss()
                }
                Button("View History") {
                    dismiss()
                }
                Button("Settings") {
                    dismiss()
                }
            }
            .navigationTitle("Map Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
