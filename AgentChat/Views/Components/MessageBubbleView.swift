//
//  MessageBubbleView.swift
//  AgentChat
//
//  Displays individual message bubbles with different styles for user/agent
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let onImageTap: (String) -> Void
    
    // MARK: - Color Scheme
    private var bubbleColor: Color {
        message.isFromUser ? Color.blue : Color(.systemGray5)
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
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                bubbleContent
                
                // Timestamp
                Text(message.simpleTimeFormat)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
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
            .background(bubbleColor)
            .cornerRadius(16)
    }
    
    // MARK: - File Bubble
    private func fileBubble(file: FileAttachment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            imageView(file: file)
            
            // Caption if present
            if !message.message.isEmpty {
                Text(message.message)
                    .font(.body)
                    .foregroundColor(textColor)
                    .padding(.horizontal, 10)
            }
            
            // File size
            Text(file.formattedFileSize)
                .font(.caption)
                .foregroundColor(secondaryTextColor)
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
        }
        .background(bubbleColor)
        .cornerRadius(16)
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
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(6)
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
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    VStack {
        MessageBubbleView(
            message: Message.createTextMessage(content: "Hello! How can I help you?", sender: .agent),
            onImageTap: { _ in }
        )
        
        MessageBubbleView(
            message: Message.createTextMessage(content: "I need help with my booking.", sender: .user),
            onImageTap: { _ in }
        )
    }
}
