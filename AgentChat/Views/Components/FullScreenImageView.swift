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
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Image
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { value in
                                scale = min(max(value, 1.0), 4.0)
                            }
                    )
                    .onTapGesture(count: 2) {
                        if scale > 1 {
                            scale = 1.0
                        } else {
                            scale = 2.0
                        }
                    }
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        if imagePath.hasPrefix("http") {
            // Load from network
            if let loadedImage = await ImageCacheService.shared.loadImage(from: imagePath) {
                await MainActor.run {
                    self.image = loadedImage
                    self.isLoading = false
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
                    self.image = localImage
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    FullScreenImageView(imagePath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400")
}
