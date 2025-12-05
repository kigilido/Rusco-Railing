//
//  ScanScreen.swift
//  DashApp iOS
//
//  License plate scanner with camera, OCR, and user lookup
//

import SwiftUI
import AVFoundation

struct ScanScreen: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cameraManager = CameraManager()

    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var detectedPlate: String?
    @State private var rawText: String?
    @State private var retryCount = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToChat = false
    @State private var conversationId: String?

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("License Plate Scanner")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)

                    if let image = capturedImage {
                        // Show captured image
                        VStack(spacing: 20) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .shadow(radius: 5)

                            if isProcessing {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                    Text("Processing license plate...")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            } else if let plate = detectedPlate {
                                VStack(spacing: 16) {
                                    Text("Detected Plate")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Text(plate)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color(hex: "3A86FF"))

                                    if let raw = rawText {
                                        Text("Raw: \(raw)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    // Buttons
                                    HStack(spacing: 12) {
                                        Button(action: retake) {
                                            Label("Retake", systemImage: "camera.rotate")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.gray.opacity(0.2))
                                                .foregroundColor(.primary)
                                                .cornerRadius(12)
                                        }

                                        Button(action: confirmPlate) {
                                            Label("Confirm", systemImage: "checkmark.circle")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color(hex: "3A86FF"))
                                                .foregroundColor(.white)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding()
                            }

                            Spacer()

                            Button(action: retake) {
                                Text("Take Another Photo")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        // Show camera button
                        VStack(spacing: 30) {
                            Spacer()

                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 80))
                                .foregroundColor(Color(hex: "3A86FF").opacity(0.3))

                            Text("Scan a license plate to find and chat with the vehicle owner")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Button(action: {
                                cameraManager.requestPermission { granted in
                                    if granted {
                                        showCamera = true
                                    } else {
                                        alertMessage = "Camera access is required to scan license plates"
                                        showAlert = true
                                    }
                                }
                            }) {
                                Label("Open Camera", systemImage: "camera.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
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
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)

                            Spacer()
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    capturedImage = image
                    showCamera = false
                    performOCR(image: image)
                }
            }
            .alert("Notice", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    func retake() {
        capturedImage = nil
        detectedPlate = nil
        rawText = nil
        isProcessing = false
        retryCount = 0
    }

    func performOCR(image: UIImage) {
        isProcessing = true

        Task {
            do {
                // Convert image to base64
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
                }
                let base64Image = "data:image/jpeg;base64," + imageData.base64EncodedString()

                // Create request ID
                let requestId = UUID().uuidString

                // Insert pending result
                let insertData: [String: Any] = [
                    "license_plate": "PROCESSING",
                    "status": "pending",
                    "request_id": requestId,
                    "raw_text": NSNull()
                ]

                try await authManager.client
                    .from("license_plate_results")
                    .insert(insertData)
                    .execute()

                // Call Supabase Edge Function
                let response = try await authManager.client.functions.invoke(
                    "process-license-plate",
                    options: FunctionInvokeOptions(
                        body: [
                            "image": base64Image,
                            "requestId": requestId
                        ]
                    )
                )

                // Poll for results
                try await pollForResults(requestId: requestId)

            } catch {
                await MainActor.run {
                    isProcessing = false
                    alertMessage = "Error processing image: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    func pollForResults(requestId: String, maxAttempts: Int = 30, interval: TimeInterval = 2.0) async throws {
        for attempt in 0..<maxAttempts {
            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            let response: [LicensePlateResult] = try await authManager.client
                .from("license_plate_results")
                .select()
                .eq("request_id", value: requestId)
                .eq("status", value: "completed")
                .limit(1)
                .execute()
                .value

            if let result = response.first {
                await MainActor.run {
                    isProcessing = false

                    if result.license_plate == "NO_PLATE_FOUND" {
                        retryCount += 1
                        if retryCount >= 2 {
                            alertMessage = "No license plate detected. Please try again with better lighting."
                            showAlert = true
                            retake()
                        } else {
                            alertMessage = "No plate found. Please retake the photo."
                            showAlert = true
                        }
                    } else {
                        detectedPlate = result.license_plate
                        rawText = result.raw_text
                    }
                }
                return
            }

            print("Polling attempt \(attempt + 1): No results yet")
        }

        // Timeout
        await MainActor.run {
            isProcessing = false
            alertMessage = "Processing timeout. Please try again."
            showAlert = true
        }
    }

    func confirmPlate() {
        guard let plate = detectedPlate else { return }

        isProcessing = true

        Task {
            do {
                // Find user by license plate
                let profiles: [UserProfile] = try await authManager.client
                    .from("profiles")
                    .select()
                    .eq("license_plate", value: plate)
                    .limit(1)
                    .execute()
                    .value

                guard let profile = profiles.first else {
                    await MainActor.run {
                        isProcessing = false
                        alertMessage = "No registered user found with license plate: \(plate)"
                        showAlert = true
                    }
                    return
                }

                // Create conversation
                let convId = try await createConversation(targetUserId: profile.id)

                await MainActor.run {
                    isProcessing = false
                    conversationId = convId
                    alertMessage = "Vehicle found! Starting chat..."
                    showAlert = true
                    navigateToChat = true
                }

            } catch {
                await MainActor.run {
                    isProcessing = false
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    func createConversation(targetUserId: String) async throws -> String {
        guard let userId = authManager.userId else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        // Create conversation
        let conversationData: [String: Any] = [
            "type": "direct",
            "title": "Vehicle Chat",
            "creator_id": userId
        ]

        let conversations: [Conversation] = try await authManager.client
            .from("conversations")
            .insert(conversationData)
            .select()
            .execute()
            .value

        guard let conversation = conversations.first else {
            throw NSError(domain: "ConversationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create conversation"])
        }

        // Add participants
        let participants: [[String: Any]] = [
            ["conversation_id": conversation.id, "user_id": userId],
            ["conversation_id": conversation.id, "user_id": targetUserId]
        ]

        try await authManager.client
            .from("conversation_participants")
            .insert(participants)
            .execute()

        return conversation.id
    }
}

// MARK: - Models
struct LicensePlateResult: Codable {
    let id: String
    let license_plate: String
    let status: String
    let raw_text: String?
    let request_id: String
}

struct UserProfile: Codable {
    let id: String
    let email: String?
    let license_plate: String?
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    func requestPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

#Preview {
    ScanScreen()
}
