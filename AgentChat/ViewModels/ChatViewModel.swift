//
//  ChatViewModel.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI
import PhotosUI
import Combine

// MARK: - Chat ViewModel
@MainActor
class ChatViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showCamera: Bool = false
    @Published var showAttachmentOptions: Bool = false
    @Published var selectedImage: UIImage?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isTyping: Bool = false
    
    // MARK: - Private Properties
    private let storage = MessageStorage.shared
    private let imageCache = ImageCacheService.shared
    
    // MARK: - Initialization
    init() {
        loadMessages()
    }
    
    // MARK: - Message Loading
    
    /// Load messages from storage or seed data
    func loadMessages() {
        isLoading = true
        
        // Check if we have cached messages
        let cachedMessages = storage.loadMessages()
        
        if cachedMessages.isEmpty {
            // First launch - load seed data
            messages = SeedData.getMessages()
            storage.saveMessages(messages)
            storage.markSeededDataLoaded()
        } else {
            messages = cachedMessages
        }
        
        // Sort messages by timestamp
        messages.sort { $0.timestamp < $1.timestamp }
        
        isLoading = false
    }
    
    // MARK: - Sending Messages
    
    /// Send a text message
    func sendTextMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newMessage = Message.createTextMessage(content: trimmedText, sender: .user)
        addMessage(newMessage, animated: true)
        
        // Clear input
        messageText = ""
        
        // Simulate agent typing
        simulateAgentTyping()
    }
    
    /// Send an image message
    func sendImageMessage(image: UIImage, caption: String = "") {
        // Save image locally with thumbnail
        guard let savedImage = imageCache.saveImageLocally(image) else {
            showErrorMessage("Failed to save image")
            return
        }
        
        let newMessage = Message.createFileMessage(
            caption: caption,
            path: savedImage.path,
            fileSize: savedImage.fileSize,
            thumbnailPath: savedImage.thumbnailPath,
            sender: .user
        )
        
        addMessage(newMessage, animated: true)
        
        // Clear selected image
        selectedImage = nil
        
        // Simulate agent typing
        simulateAgentTyping()
    }
    
    /// Add a message and persist
    private func addMessage(_ message: Message, animated: Bool = false) {
        if animated {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                messages.append(message)
            }
        } else {
            messages.append(message)
        }
        
        // Persist to storage
        storage.saveMessages(messages)
    }
    
    // MARK: - Agent Response Simulation
    
    /// Simulate agent typing and then send response
    private func simulateAgentTyping() {
        // Show typing indicator after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.isTyping = true
            }
        }
        
        // Send response after typing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isTyping = false
            }
            
            self.sendAgentResponse()
        }
    }
    
    /// Send a simulated agent response
    private func sendAgentResponse() {
        let responses = [
            "Thank you for your message! I'm here to help.",
            "I understand. Let me look into that for you.",
            "Got it! Is there anything else you'd like to know?",
            "I appreciate you sharing that. Here's what I found...",
            "Great question! Let me assist you with that.",
            "Thanks for the image! I can see the details clearly.",
            "I'll process this information right away.",
            "Perfect! I'm updating your request now."
        ]
        
        let randomResponse = responses.randomElement() ?? "Thank you for your message!"
        let agentMessage = Message.createTextMessage(content: randomResponse, sender: .agent)
        
        // Add agent response with animation
        addMessage(agentMessage, animated: true)
    }
    
    // MARK: - Image Handling
    
    /// Handle selected image from picker
    func handleSelectedImage(_ image: UIImage?) {
        guard let image = image else { return }
        selectedImage = image
        sendImageMessage(image: image)
    }
    
    /// Handle photo picker selection
    func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    handleSelectedImage(image)
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    /// Show error message
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Utility
    
    /// Check if send button should be enabled
    var canSendMessage: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Copy message text to clipboard
    func copyMessageText(_ message: Message) {
        UIPasteboard.general.string = message.message
    }
    
    /// Refresh messages from storage
    func refreshMessages() {
        loadMessages()
    }
}
