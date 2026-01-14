//
//  FullScreenImageView.swift
//  AgentChat
//
//  Full screen image viewer with pinch to zoom
//

import SwiftUI

struct FullScreenImageView: View {
    let imagePath: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var image: UIImage?
    @State private var isLoading = true
    
    // Gesture state
    @GestureState private var magnifyBy: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if scale > 1 {
                                scale = 1.0
                                offset = .zero
                            } else {
                                scale = 2.0
                            }
                        }
                    }
                
                // Image
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale * magnifyBy)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .updating($magnifyBy) { value, state, _ in
                                    state = value
                                }
                                .onEnded { value in
                                    let newScale = scale * value
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        scale = min(max(newScale, 0.5), 4.0)
                                        if scale <= 1 {
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { value in
                                    lastOffset = offset
                                    
                                    // Dismiss on significant downward drag
                                    if scale <= 1 && value.translation.height > 100 {
                                        dismiss()
                                    }
                                }
                        )
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
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
        }
        .task {
            await loadImage()
        }
        .statusBarHidden()
    }
    
    private func loadImage() async {
        if imagePath.hasPrefix("http") {
            // Load from network
            if let loadedImage = await ImageCacheService.shared.loadImage(from: imagePath) {
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.2)) {
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
            // Load from local file
            await MainActor.run {
                if let localImage = UIImage(contentsOfFile: imagePath) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.image = localImage
                    }
                }
                self.isLoading = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FullScreenImageView(imagePath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400")
}
