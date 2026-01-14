//
//  ChatView.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var selectedImagePath: String = ""
    @State private var showFullScreenImage = false
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            messagesScrollView
            
            // Composer
            MessageComposer(
                messageText: $viewModel.messageText,
                showAttachmentOptions: $viewModel.showAttachmentOptions,
                canSend: viewModel.canSendMessage,
                onSend: {
                    viewModel.sendTextMessage()
                },
                onAttachmentTap: {
                    viewModel.showAttachmentOptions = true
                },
                onPhotoSelected: { item in
                    viewModel.handlePhotoSelection(item)
                },
                onCameraTap: {
                    showCamera = true
                }
            )
        }
        .background(Color(.systemBackground))
        .navigationTitle("Agent Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            // Force opaque navigation bar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = UIColor.separator
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imagePath: selectedImagePath)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                if let image = image {
                    viewModel.handleSelectedImage(image)
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
                LazyVStack(spacing: 2) {
                    // Date header for first message
                    if let firstMessage = viewModel.messages.first {
                        dateHeader(for: firstMessage.date)
                    }
                    
                    // Messages
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            onImageTap: { path in
                                selectedImagePath = path
                                showFullScreenImage = true
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
                        .frame(height: 25)
                        .id("bottomAnchor")
                }
                .padding(.top, 12)
            }
            .background(Color(.systemBackground))
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                // Dismiss keyboard when tapping on message list
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                // Scroll to bottom on appear - use multiple delays to handle image loading
                scrollToBottom(proxy: proxy, delay: 0.1)
                scrollToBottom(proxy: proxy, delay: 0.5)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy, delay: 0.1)
            }
            .onChange(of: viewModel.isTyping) { _, isTyping in
                // Scroll to bottom when typing indicator appears
                if isTyping {
                    scrollToBottom(proxy: proxy, delay: 0.1)
                }
            }
        }
    }
    
    // MARK: - Date Header
    private func dateHeader(for date: Date) -> some View {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today'"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday'"
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
        }
        
        return Text(formatter.string(from: date))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )
            .padding(.vertical, 8)
    }
    
    // MARK: - Scroll to Bottom Helper
    private func scrollToBottom(proxy: ScrollViewProxy, delay: Double = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 0.3)) {
                // Scroll to typing indicator if visible
                if viewModel.isTyping {
                    proxy.scrollTo("typingIndicator", anchor: .bottom)
                } else if let lastMessage = viewModel.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                } else {
                    proxy.scrollTo("bottomAnchor", anchor: .bottom)
                }
            }
        }
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

#Preview {
    NavigationStack {
        ChatView()
    }
}
