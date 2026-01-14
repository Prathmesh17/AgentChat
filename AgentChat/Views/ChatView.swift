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
    @State private var selectedImagePath: String?
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
        .navigationTitle("Support Chat")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let imagePath = selectedImagePath {
                FullScreenImageView(imagePath: imagePath)
            }
        }
        .sheet(isPresented: $showCamera) {
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
                LazyVStack(spacing: 0) {
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
                    proxy.scrollTo("bottomAnchor", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                // Scroll to bottom when new message added
                proxy.scrollTo("bottomAnchor", anchor: .bottom)
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
