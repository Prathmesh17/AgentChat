//
//  ImageCacheService.swift
//  AgentChat
//
//  Handles basic image loading and saving
//

import SwiftUI
import UIKit

// MARK: - Image Cache Manager
class ImageCacheService {
    
    // MARK: - Properties
    static let shared = ImageCacheService()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Initialization
    private init() {
        // Set up cache directory
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Load image from URL
    func loadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("❌ Failed to load image: \(error)")
            return nil
        }
    }
    
    /// Save image locally and return the file path
    func saveImageLocally(_ image: UIImage, filename: String? = nil) -> (path: String, fileSize: Int)? {
        let imageName = filename ?? UUID().uuidString
        let imagePath = cacheDirectory.appendingPathComponent("\(imageName).jpg")
        
        // Save image as JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        do {
            try imageData.write(to: imagePath)
            return (imagePath.path, imageData.count)
        } catch {
            print("❌ Failed to save image: \(error)")
            return nil
        }
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage: View {
    let url: String
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(url: String, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        if let loadedImage = await ImageCacheService.shared.loadImage(from: url) {
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        } else {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
