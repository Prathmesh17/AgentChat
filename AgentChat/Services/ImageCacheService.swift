//
//  ImageCacheService.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI
import UIKit

// MARK: - Image Cache Manager
class ImageCacheService {
    
    // MARK: - Properties
    static let shared = ImageCacheService()
    
    private let fileManager = FileManager.default
    
    // Store the images directly by their path for immediate access
    private var recentlySavedImages: [String: UIImage] = [:]
    private let recentLock = NSLock()
    
    // Configuration
    private let compressionQuality: CGFloat = 0.7
    private let thumbnailSize = CGSize(width: 150, height: 150)
    
    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = paths[0].appendingPathComponent("ImageCache")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        return directory
    }
    
    // Memory cache for network images
    private let memoryCache = NSCache<NSString, UIImage>()
    
    // Track ongoing downloads to avoid duplicate requests
    private var ongoingTasks: [String: Task<UIImage?, Never>] = [:]
    private let taskLock = NSLock()
    
    // MARK: - Initialization
    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }
    
    // MARK: - Public Methods
    
    /// Load image from URL with caching
    func loadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check if there's an ongoing task for this URL
        taskLock.lock()
        if let existingTask = ongoingTasks[urlString] {
            taskLock.unlock()
            return await existingTask.value
        }
        
        // Create a new task
        let task = Task<UIImage?, Never> {
            await downloadImage(from: urlString)
        }
        ongoingTasks[urlString] = task
        taskLock.unlock()
        
        let result = await task.value
        
        taskLock.lock()
        ongoingTasks.removeValue(forKey: urlString)
        taskLock.unlock()
        
        return result
    }
    
    /// Download image from network
    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            guard let image = UIImage(data: data) else { return nil }
            
            let cacheKey = NSString(string: urlString)
            memoryCache.setObject(image, forKey: cacheKey)
            
            return image
        } catch {
            if (error as NSError).code != NSURLErrorCancelled {
                print(" Failed to load image: \(error.localizedDescription)")
            }
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
        
        let aspectWidth = targetSize.width / image.size.width
        let aspectHeight = targetSize.height / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let newSize = CGSize(
            width: image.size.width * aspectRatio,
            height: image.size.height * aspectRatio
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Save image locally with compression and thumbnail generation
    func saveImageLocally(_ image: UIImage, filename: String? = nil) -> (path: String, fileSize: Int, thumbnailPath: String?)? {
        let imageName = filename ?? UUID().uuidString
        let imageFileName = "\(imageName).jpg"
        let thumbnailFileName = "\(imageName)_thumb.jpg"
        let imageURL = cacheDirectory.appendingPathComponent(imageFileName)
        let thumbnailURL = cacheDirectory.appendingPathComponent(thumbnailFileName)
        
        // Compress and save main image
        guard let imageData = compressImage(image) else {
            print("Failed to compress image")
            return nil
        }
        
        do {
            try imageData.write(to: imageURL)
            let savedPath = imageURL.path
            
            // Store in recent cache for immediate access
            recentLock.lock()
            recentlySavedImages[savedPath] = image
            recentLock.unlock()
            
            // Generate and save thumbnail
            var savedThumbnailPath: String? = nil
            if let thumbnail = generateThumbnail(for: image),
               let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) {
                try thumbnailData.write(to: thumbnailURL)
                savedThumbnailPath = thumbnailURL.path
                
                // Cache thumbnail too
                recentLock.lock()
                recentlySavedImages[thumbnailURL.path] = thumbnail
                recentLock.unlock()
            }
            
            print("Image saved: \(savedPath)")
            if let thumbPath = savedThumbnailPath {
                print("Thumbnail saved: \(thumbPath)")
            }
            
            return (savedPath, imageData.count, savedThumbnailPath)
        } catch {
            print(" Failed to save image: \(error)")
            return nil
        }
    }
    
    /// Load image from local file path
    func loadLocalImage(from path: String) -> UIImage? {
        // 1. Check recently saved cache
        recentLock.lock()
        if let image = recentlySavedImages[path] {
            recentLock.unlock()
            return image
        }
        recentLock.unlock()
        
        // 2. Try loading directly from path
        if let image = UIImage(contentsOfFile: path) {
            recentLock.lock()
            recentlySavedImages[path] = image
            recentLock.unlock()
            return image
        }
        
        // 3. Try using file URL
        let fileURL = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            recentLock.lock()
            recentlySavedImages[path] = image
            recentLock.unlock()
            return image
        }
        
        // 4. Extract filename and try from cache directory
        if let filename = URL(fileURLWithPath: path).lastPathComponent.removingPercentEncoding ?? path.components(separatedBy: "/").last {
            let cacheURL = cacheDirectory.appendingPathComponent(filename)
            if let image = UIImage(contentsOfFile: cacheURL.path) {
                recentLock.lock()
                recentlySavedImages[path] = image
                recentLock.unlock()
                return image
            }
        }
        
        print("Could not load image from: \(path)")
        return nil
    }
    
    /// Clear all caches
    func clearCache() {
        memoryCache.removeAllObjects()
        recentLock.lock()
        recentlySavedImages.removeAll()
        recentLock.unlock()
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage: View {
    let url: String
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadTask: Task<Void, Never>?
    
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
        .onAppear {
            loadImageIfNeeded()
        }
        .onDisappear {
            loadTask?.cancel()
        }
    }
    
    private func loadImageIfNeeded() {
        guard image == nil else { return }
        
        loadTask = Task {
            if let loadedImage = await ImageCacheService.shared.loadImage(from: url) {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.image = loadedImage
                        self.isLoading = false
                    }
                }
            } else {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
