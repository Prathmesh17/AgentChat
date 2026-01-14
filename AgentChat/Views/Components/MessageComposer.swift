//
//  MessageComposer.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI
import PhotosUI

struct MessageComposer: View {
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
                Button(action: onAttachmentTap) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.35, blue: 0.95),
                                    Color(red: 0.45, green: 0.25, blue: 0.85).opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Text Input
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .focused($isTextFieldFocused)
                
                // Send Button
                Button(action: {
                    onSend()
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            canSend ?
                            LinearGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.35, blue: 0.95),
                                    Color(red: 0.45, green: 0.25, blue: 0.85).opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(colors: [.gray, .gray], startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(canSend ? 1.0 : 0.9)
                        .animation(.spring(response: 0.2), value: canSend)
                }
                .disabled(!canSend)
                .buttonStyle(ScaleButtonStyle())
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
        VStack(spacing: 16) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            Text("Choose Attachment")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(spacing: 12) {
                // Photo Library
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Photo Library")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("Choose from your photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .onChange(of: selectedPhotoItem) { _, newValue in
                    onPhotoSelected(newValue)
                    showAttachmentOptions = false
                }
                
                // Camera
                Button(action: {
                    showAttachmentOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onCameraTap()
                    }
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Camera")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("Take a new photo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
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

#Preview {
    VStack {
        Spacer()
        MessageComposer(
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
