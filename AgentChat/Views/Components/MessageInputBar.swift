//
//  MessageInputBar.swift
//  AgentChat
//
//  Input bar for composing and sending messages
//

import SwiftUI
import PhotosUI

struct MessageInputBar: View {
    @Binding var messageText: String
    @Binding var showAttachmentOptions: Bool
    var canSend: Bool
    var onSend: () -> Void
    var onAttachmentTap: () -> Void
    var onPhotoSelected: (PhotosPickerItem?) -> Void
    var onCameraTap: () -> Void
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Attachment Button
                Button(action: onAttachmentTap) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                
                // Text Input
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                // Send Button
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSend ? .blue : .gray)
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showAttachmentOptions) {
            attachmentOptionsSheet
        }
    }
    
    // MARK: - Attachment Options Sheet
    private var attachmentOptionsSheet: some View {
        VStack(spacing: 20) {
            Text("Choose Attachment")
                .font(.headline)
                .padding(.top, 20)
            
            // Photo Library
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("Photo Library")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                onPhotoSelected(newValue)
                showAttachmentOptions = false
            }
            
            // Camera
            Button(action: {
                showAttachmentOptions = false
                onCameraTap()
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Camera")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(250)])
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputBar(
            messageText: .constant(""),
            showAttachmentOptions: .constant(false),
            canSend: false,
            onSend: {},
            onAttachmentTap: {},
            onPhotoSelected: { _ in },
            onCameraTap: {}
        )
    }
}
