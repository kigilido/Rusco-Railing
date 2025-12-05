//
//  ChatScreen.swift
//  DashApp iOS
//
//  Chat screen with Contacts/General toggle and real-time messaging
//

import SwiftUI
import Supabase

struct ChatScreen: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var chatEnvironment: ChatEnvironment = .contacts
    @State private var showConversations = true
    @State private var conversations: [Conversation] = []
    @State private var selectedConversation: Conversation?
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var messageText = ""

    enum ChatEnvironment: String {
        case contacts = "Contacts"
        case general = "General"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Environment Toggle
                Picker("Chat Environment", selection: $chatEnvironment) {
                    Text("Contacts").tag(ChatEnvironment.contacts)
                    Text("General").tag(ChatEnvironment.general)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: chatEnvironment) { _ in
                    showConversations = true
                    selectedConversation = nil
                }

                if showConversations {
                    // Conversations List
                    ConversationsListView(
                        conversations: conversations,
                        onSelect: { conversation in
                            selectedConversation = conversation
                            showConversations = false
                            loadMessages(for: conversation)
                        },
                        onNewConversation: {
                            // Create new conversation
                        }
                    )
                } else {
                    // Chat View
                    ChatMessagesView(
                        messages: messages,
                        messageText: $messageText,
                        isLoading: isLoading,
                        onSend: sendMessage,
                        onBack: {
                            showConversations = true
                            selectedConversation = nil
                        }
                    )
                }
            }
            .navigationTitle(showConversations ? chatEnvironment.rawValue : "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadConversations()
            }
        }
    }

    // Load conversations from Supabase
    func loadConversations() {
        guard let userId = authManager.userId else { return }

        Task {
            isLoading = true
            do {
                // Query conversations where user is a participant
                let response: [Conversation] = try await authManager.client
                    .from("conversations")
                    .select("""
                        id,
                        type,
                        title,
                        created_at,
                        conversation_participants!inner(user_id)
                    """)
                    .eq("conversation_participants.user_id", value: userId)
                    .execute()
                    .value

                await MainActor.run {
                    self.conversations = response
                    self.isLoading = false
                }
            } catch {
                print("Error loading conversations: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }

    // Load messages for a conversation
    func loadMessages(for conversation: Conversation) {
        Task {
            isLoading = true
            do {
                let response: [Message] = try await authManager.client
                    .from("messages")
                    .select()
                    .eq("conversation_id", value: conversation.id)
                    .order("created_at", ascending: true)
                    .execute()
                    .value

                await MainActor.run {
                    self.messages = response
                    self.isLoading = false
                }

                // Subscribe to real-time updates
                subscribeToMessages(conversationId: conversation.id)
            } catch {
                print("Error loading messages: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }

    // Subscribe to real-time message updates
    func subscribeToMessages(conversationId: String) {
        Task {
            let channel = await authManager.client.channel("messages:\(conversationId)")

            await channel.on("INSERT") { message in
                // Handle new message
                if let newMessage = try? JSONDecoder().decode(Message.self, from: JSONEncoder().encode(message.payload)) {
                    Task { @MainActor in
                        if !messages.contains(where: { $0.id == newMessage.id }) {
                            messages.append(newMessage)
                        }
                    }
                }
            }

            await channel.subscribe()
        }
    }

    // Send a message
    func sendMessage() {
        guard let conversationId = selectedConversation?.id,
              let userId = authManager.userId,
              !messageText.isEmpty else { return }

        let content = messageText
        messageText = ""

        Task {
            do {
                let newMessage = MessageInsert(
                    conversation_id: conversationId,
                    sender_id: userId,
                    content: content
                )

                let _: Message = try await authManager.client
                    .from("messages")
                    .insert(newMessage)
                    .select()
                    .single()
                    .execute()
                    .value
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
}

// MARK: - Conversations List View
struct ConversationsListView: View {
    let conversations: [Conversation]
    let onSelect: (Conversation) -> Void
    let onNewConversation: () -> Void

    var body: some View {
        ZStack {
            if conversations.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))

                    Text("No conversations yet")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Button(action: onNewConversation) {
                        Label("Start New Chat", systemImage: "plus.message.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "3A86FF"))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
            } else {
                List {
                    ForEach(conversations) { conversation in
                        Button(action: { onSelect(conversation) }) {
                            ConversationRow(conversation: conversation)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "3A86FF").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(conversation.title?.first?.uppercased() ?? "?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "3A86FF"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title ?? "Conversation")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(conversation.type)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Chat Messages View
struct ChatMessagesView: View {
    let messages: [Message]
    @Binding var messageText: String
    let isLoading: Bool
    let onSend: () -> Void
    let onBack: () -> Void

    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(hex: "3A86FF"))
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5),
                alignment: .bottom
            )

            // Messages
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.sender_id == authManager.userId
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            // Message input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)

                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? .gray : Color(hex: "3A86FF"))
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color(hex: "3A86FF") : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)

                Text(formatDate(message.created_at))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if !isCurrentUser {
                Spacer()
            }
        }
    }

    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return ""
    }
}

// MARK: - Models
struct Conversation: Identifiable, Codable {
    let id: String
    let type: String
    let title: String?
    let created_at: String
}

struct Message: Identifiable, Codable {
    let id: String
    let conversation_id: String
    let sender_id: String
    let content: String
    let created_at: String
}

struct MessageInsert: Codable {
    let conversation_id: String
    let sender_id: String
    let content: String
}

#Preview {
    ChatScreen()
}
