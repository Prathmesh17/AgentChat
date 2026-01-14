//
//  FullScreenImageView.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI

struct FullScreenImageView: View {
    let imagePath: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var offset: CGSize = .zero
    @State private var showControls = true
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showControls.toggle()
                    }
                }
            
            // Image
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                                    scale = min(max(value, 1.0), 4.0)
                                    if scale == 1.0 {
                                        offset = .zero
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if scale > 1.0 {
                                    offset = value.translation
                                } else if abs(value.translation.height) > 50 {
                                    // Drag down to dismiss
                                    offset = CGSize(width: 0, height: value.translation.height)
                                }
                            }
                            .onEnded { value in
                                if scale <= 1.0 && abs(value.translation.height) > 100 {
                                    // Dismiss if dragged down far enough
                                    dismiss()
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                                        if scale <= 1.0 {
                                            offset = .zero
                                        }
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                            if scale > 1 {
                                scale = 1.0
                                offset = .zero
                            } else {
                                scale = 2.5
                            }
                        }
                    }
                    .transition(.opacity)
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("Failed to load image")
                        .foregroundColor(.gray)
                }
            }
            
            // Close Button
            if showControls {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white.opacity(0.9), .black.opacity(0.3))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    
                    Spacer()
                    
                }
                .transition(.opacity)
            }
        }
        .statusBar(hidden: true)
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard !imagePath.isEmpty else {
            await MainActor.run {
                self.isLoading = false
            }
            return
        }
        
        if imagePath.hasPrefix("http") {
            if let loadedImage = await ImageCacheService.shared.loadImage(from: imagePath) {
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.image = loadedImage
                        self.isLoading = false
                    }
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } else {
            await MainActor.run {
                if let localImage = ImageCacheService.shared.loadLocalImage(from: imagePath) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.image = localImage
                    }
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    FullScreenImageView(imagePath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400")
}
