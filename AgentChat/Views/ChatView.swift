//
//  ChatView.swift
//  AgentChat
//
//  Main chat interface view with message list and input
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var selectedImagePath: String?
    @State private var showFullScreenImage = false
    @State private var showCamera = false
    @State private var scrollToBottom = false
    
    // For camera capture
    @State private var capturedImage: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Messages List
                messagesScrollView
                
                // Input Bar
                MessageInputBar(
                    messageText: $viewModel.messageText,
                    showAttachmentOptions: $viewModel.showAttachmentOptions,
                    canSend: viewModel.canSendMessage,
                    onSend: {
                        viewModel.sendTextMessage()
                        scrollToBottom = true
                    },
                    onAttachmentTap: {
                        viewModel.showAttachmentOptions = true
                    },
                    onPhotoSelected: { item in
                        viewModel.handlePhotoSelection(item)
                        scrollToBottom = true
                    },
                    onCameraTap: {
                        showCamera = true
                    }
                )
            }
            .background(chatBackground)
        }
        .navigationTitle("Support Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshMessages()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                }
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let imagePath = selectedImagePath {
                FullScreenImageView(imagePath: imagePath)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                if let image = image {
                    viewModel.handleSelectedImage(image)
                    scrollToBottom = true
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Messages Scroll View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Load More Button
                    if viewModel.hasMoreMessages {
                        loadMoreButton
                            .id("loadMore")
                    }
                    
                    // Messages
                    ForEach(viewModel.displayedMessages) { message in
                        MessageBubbleView(
                            message: message,
                            onImageTap: { path in
                                selectedImagePath = path
                                showFullScreenImage = true
                            },
                            onLongPress: { msg in
                                viewModel.copyMessageText(msg)
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        )
                        .id(message.id)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                    }
                    
                    // Typing Indicator
                    if viewModel.isTyping {
                        TypingIndicatorView()
                            .id("typingIndicator")
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    // Bottom spacer for scroll anchor
                    Color.clear
                        .frame(height: 8)
                        .id("bottomAnchor")
                }
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                // Scroll to bottom on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.displayedMessages.count) { _, _ in
                // Scroll to bottom when new message added
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    proxy.scrollTo("bottomAnchor", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isTyping) { _, isTyping in
                if isTyping {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        proxy.scrollTo("typingIndicator", anchor: .bottom)
                    }
                }
            }
            .onChange(of: scrollToBottom) { _, shouldScroll in
                if shouldScroll {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                    scrollToBottom = false
                }
            }
        }
    }
    
    // MARK: - Load More Button
    private var loadMoreButton: some View {
        Button(action: {
            viewModel.loadMoreMessages()
        }) {
            HStack(spacing: 8) {
                if viewModel.isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.up.circle")
                        .font(.system(size: 14))
                }
                
                Text(viewModel.isLoadingMore ? "Loading..." : "Load Earlier Messages")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.1))
            )
        }
        .disabled(viewModel.isLoadingMore)
        .padding(.vertical, 8)
    }
    
    // MARK: - Chat Background
    private var chatBackground: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
            parent.dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ChatView()
    }
}
