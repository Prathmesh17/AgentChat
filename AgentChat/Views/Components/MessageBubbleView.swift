//
//  MessageBubbleView.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let onImageTap: (String) -> Void
    
    @State private var isPressed = false
    @State private var showCopied = false
    
    // MARK: - Color Scheme
    private var bubbleGradient: LinearGradient {
        if message.isFromUser {
            return LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.35, blue: 0.95),  // Purple
                    Color(red: 0.45, green: 0.25, blue: 0.85)   // Darker purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var textColor: Color {
        message.isFromUser ? .white : .primary
    }
    
    private var secondaryTextColor: Color {
        message.isFromUser ? .white.opacity(0.7) : .secondary
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser {
                Spacer(minLength: 50)
            } else {
                // Agent avatar
                agentAvatar
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                bubbleContent
                    .scaleEffect(isPressed ? 0.97 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                
                // Smart Timestamp
                Text(message.formattedTimestamp())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
        .overlay(
            Group {
                if showCopied {
                    copiedToast
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    // MARK: - Agent Avatar
    private var agentAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.35, blue: 0.95),
                            Color(red: 0.45, green: 0.25, blue: 0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Bubble Content
    @ViewBuilder
    private var bubbleContent: some View {
        if message.type == .file, let file = message.file {
            fileBubble(file: file)
        } else {
            textBubble
        }
    }
    
    // MARK: - Text Bubble
    private var textBubble: some View {
        Text(message.message)
            .font(.body)
            .foregroundColor(textColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(bubbleGradient)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: message.isFromUser ? Color.purple.opacity(0.25) : Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = isPressing
                }
            }) {
                copyMessageToClipboard()
            }
    }
    
    // MARK: - File Bubble
    private func fileBubble(file: FileAttachment) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image container
            ZStack(alignment: .bottomTrailing) {
                // Image
                imageView(file: file)
                    .frame(height: 180)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(8)
            
            // Caption and file info section
            VStack(alignment: .leading, spacing: 8) {
                // Caption if present
                if !message.message.isEmpty {
                    Text(message.message)
                        .font(.body)
                        .foregroundColor(textColor)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // File size with icon
                HStack(spacing: 5) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 11))
                    Text(file.formattedFileSize)
                        .font(.caption)
                }
                .foregroundColor(secondaryTextColor)
            }
            .padding(.horizontal, 14)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .frame(width: 260)
        .padding(5)
        .background(bubbleGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    message.isFromUser ? Color.white.opacity(0.2) : Color.black.opacity(0.1),
                    lineWidth: 1
                )
        )
        .shadow(color: message.isFromUser ? Color.purple.opacity(0.2) : Color.black.opacity(0.06), radius: 5, x: 0, y: 2)
        .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = isPressing
            }
        }) {
            if !message.message.isEmpty {
                copyMessageToClipboard()
            }
        }
    }
    
    // MARK: - Image View
    @ViewBuilder
    private func imageView(file: FileAttachment) -> some View {
        let imagePath = file.thumbnail?.path ?? file.path
        
        Group {
            if imagePath.hasPrefix("http") {
                CachedAsyncImage(url: imagePath, contentMode: .fill)
            } else {
                localImageView(path: imagePath)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            onImageTap(file.path)
        }
    }
    
    @ViewBuilder
    private func localImageView(path: String) -> some View {
        if let image = ImageCacheService.shared.loadLocalImage(from: path) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            ZStack {
                Color.gray.opacity(0.2)
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("Image unavailable")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Copy to Clipboard
    private func copyMessageToClipboard() {
        UIPasteboard.general.string = message.message
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Show copied toast
        withAnimation(.spring()) {
            showCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                showCopied = false
            }
        }
    }
    
    // MARK: - Copied Toast
    private var copiedToast: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
            Text("Message Copied")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.8))
        )
    }
}



#Preview {
    VStack(spacing: 8) {
        MessageBubbleView(
            message: Message.createTextMessage(content: "Hello! How can I help you today?", sender: .agent),
            onImageTap: { _ in }
        )
        
        MessageBubbleView(
            message: Message.createTextMessage(content: "I need help with booking a flight to Mumbai.", sender: .user),
            onImageTap: { _ in }
        )
        
        MessageBubbleView(
            message: Message.createTextMessage(content: "Sure! I'd be happy to assist you with that. When are you planning to travel?", sender: .agent),
            onImageTap: { _ in }
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
