//
//  ImageCacheService.swift
//  AgentChat
//
//  Handles image caching, compression, and thumbnail generation
//

import SwiftUI
import UIKit

// MARK: - Image Cache Manager
class ImageCacheService: ObservableObject {
    
    // MARK: - Properties
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Configuration
    private let maxCacheSize = 50 * 1024 * 1024 // 50MB
    private let compressionQuality: CGFloat = 0.7
    private let thumbnailSize = CGSize(width: 100, height: 100)
    
    // MARK: - Initialization
    private init() {
        // Set up cache directory
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        cache.totalCostLimit = maxCacheSize
        cache.countLimit = 100
    }
    
    // MARK: - Public Methods
    
    /// Load image from URL with caching
    func loadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        
        // Check memory cache first
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadFromDisk(key: urlString) {
            cache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }
        
        // Download from network
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Cache in memory
            cache.setObject(image, forKey: cacheKey)
            
            // Cache to disk
            saveToDisk(image: image, key: urlString)
            
            return image
        } catch {
            print("❌ Failed to load image: \(error)")
            return nil
        }
    }
    
    /// Compress image to reduce file size
    func compressImage(_ image: UIImage, quality: CGFloat? = nil) -> Data? {
        let compressionLevel = quality ?? compressionQuality
        return image.jpegData(compressionQuality: compressionLevel)
    }
    
    /// Generate thumbnail for an image
    func generateThumbnail(for image: UIImage, size: CGSize? = nil) -> UIImage? {
        let targetSize = size ?? thumbnailSize
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    /// Save image locally and return the file path
    func saveImageLocally(_ image: UIImage, filename: String? = nil) -> (path: String, fileSize: Int, thumbnailPath: String?)? {
        let imageName = filename ?? UUID().uuidString
        let imagePath = cacheDirectory.appendingPathComponent("\(imageName).jpg")
        let thumbnailPath = cacheDirectory.appendingPathComponent("\(imageName)_thumb.jpg")
        
        // Compress and save main image
        guard let compressedData = compressImage(image) else { return nil }
        
        do {
            try compressedData.write(to: imagePath)
            
            // Generate and save thumbnail
            var savedThumbnailPath: String? = nil
            if let thumbnail = generateThumbnail(for: image),
               let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) {
                try thumbnailData.write(to: thumbnailPath)
                savedThumbnailPath = thumbnailPath.path
            }
            
            return (imagePath.path, compressedData.count, savedThumbnailPath)
        } catch {
            print("❌ Failed to save image: \(error)")
            return nil
        }
    }
    
    /// Clear memory cache
    func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    /// Clear all caches (memory and disk)
    func clearAllCaches() {
        cache.removeAllObjects()
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("❌ Failed to clear disk cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadFromDisk(key: String) -> UIImage? {
        let filename = key.hash.description
        let filePath = cacheDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: filePath.path) else { return nil }
        return UIImage(contentsOfFile: filePath.path)
    }
    
    private func saveToDisk(image: UIImage, key: String) {
        let filename = key.hash.description
        let filePath = cacheDirectory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: compressionQuality) else { return }
        
        do {
            try data.write(to: filePath)
        } catch {
            print("❌ Failed to save to disk: \(error)")
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
    }
}
