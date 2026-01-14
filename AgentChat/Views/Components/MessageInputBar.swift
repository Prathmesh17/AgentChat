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
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Attachment Button
                attachmentButton
                
                // Text Input
                textInputField
                
                // Send Button
                sendButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showAttachmentOptions) {
            attachmentOptionsSheet
        }
    }
    
    // MARK: - Attachment Button
    private var attachmentButton: some View {
        Button(action: onAttachmentTap) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Text Input Field
    private var textInputField: some View {
        HStack(alignment: .bottom) {
            TextField("Type a message...", text: $messageText, axis: .vertical)
                .font(.body)
                .lineLimit(1...5)
                .focused($isTextFieldFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Send Button
    private var sendButton: some View {
        Button(action: {
            isTextFieldFocused = false
            onSend()
        }) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(
                    canSend ?
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .disabled(!canSend)
        .buttonStyle(ScaleButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: canSend)
    }
    
    // MARK: - Attachment Options Sheet
    private var attachmentOptionsSheet: some View {
        VStack(spacing: 0) {
            // Handle Bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            Text("Choose Attachment")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            VStack(spacing: 16) {
                // Photo Library
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    AttachmentOptionRow(
                        icon: "photo.on.rectangle",
                        title: "Photo Library",
                        color: .purple
                    )
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
                    AttachmentOptionRow(
                        icon: "camera.fill",
                        title: "Camera",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
    }
}

// MARK: - Attachment Option Row
struct AttachmentOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
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
