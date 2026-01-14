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
    let onLongPress: (Message) -> Void
    
    @State private var isPressed = false
    @State private var showCopied = false
    
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
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                
                // Timestamp
                Text(message.formattedTimestamp())
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
        .overlay(
            Group {
                if showCopied {
                    copiedToast
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
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
            .clipShape(ChatBubbleShape(isFromUser: message.isFromUser))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = isPressing
                }
            }) {
                onLongPress(message)
                showCopiedFeedback()
            }
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
        .clipShape(ChatBubbleShape(isFromUser: message.isFromUser))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = isPressing
            }
        }) {
            onLongPress(message)
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
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(6)
        .onTapGesture {
            onImageTap(file.path)
        }
    }
    
    @ViewBuilder
    private func localImageView(path: String) -> some View {
        if let image = UIImage(contentsOfFile: path) {
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
    
    // MARK: - Copied Toast
    private var copiedToast: some View {
        Text("Copied!")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.8))
            .clipShape(Capsule())
    }
    
    private func showCopiedFeedback() {
        withAnimation(.spring()) {
            showCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                showCopied = false
            }
        }
    }
}

// MARK: - Chat Bubble Shape
struct ChatBubbleShape: Shape {
    let isFromUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailWidth: CGFloat = 8
        let tailHeight: CGFloat = 8
        
        var path = Path()
        
        if isFromUser {
            // User bubble - tail on right
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius - tailWidth, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - tailWidth, y: rect.minY + radius),
                control: CGPoint(x: rect.maxX - tailWidth, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX - tailWidth, y: rect.maxY - radius - tailHeight))
            
            // Tail
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.maxY),
                control: CGPoint(x: rect.maxX - tailWidth, y: rect.maxY - tailHeight / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - tailWidth - radius, y: rect.maxY),
                control: CGPoint(x: rect.maxX - tailWidth, y: rect.maxY)
            )
            
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - radius),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + radius, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
        } else {
            // Agent bubble - tail on left
            path.move(to: CGPoint(x: rect.minX + radius + tailWidth, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX + tailWidth + radius, y: rect.maxY))
            
            // Tail
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY),
                control: CGPoint(x: rect.minX + tailWidth, y: rect.maxY)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + tailWidth, y: rect.maxY - radius - tailHeight),
                control: CGPoint(x: rect.minX + tailWidth, y: rect.maxY - tailHeight / 2)
            )
            
            path.addLine(to: CGPoint(x: rect.minX + tailWidth, y: rect.minY + radius))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + radius + tailWidth, y: rect.minY),
                control: CGPoint(x: rect.minX + tailWidth, y: rect.minY)
            )
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview {
    VStack {
        MessageBubbleView(
            message: Message.createTextMessage(content: "Hello! How can I help you?", sender: .agent),
            onImageTap: { _ in },
            onLongPress: { _ in }
        )
        
        MessageBubbleView(
            message: Message.createTextMessage(content: "I need help with my booking.", sender: .user),
            onImageTap: { _ in },
            onLongPress: { _ in }
        )
    }
}
