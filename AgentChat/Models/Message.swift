//
//  Message.swift
//  AgentChat
//
//  Message model for chat messages between user and agent
//

import Foundation

// MARK: - Message Types
enum MessageType: String, Codable {
    case text
    case file
}

// MARK: - Sender Types
enum MessageSender: String, Codable {
    case user
    case agent
}

// MARK: - Thumbnail Model
struct Thumbnail: Codable, Equatable {
    let path: String
}

// MARK: - File Attachment Model
struct FileAttachment: Codable, Equatable {
    let path: String
    let fileSize: Int
    let thumbnail: Thumbnail?
    
    /// Formatted file size string (e.g., "2.3 MB")
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

// MARK: - Message Model
struct Message: Codable, Identifiable, Equatable {
    let id: String
    let message: String
    let type: MessageType
    let file: FileAttachment?
    let sender: MessageSender
    let timestamp: Int64
    
    /// Date representation of the timestamp
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
    }
    
    /// Check if this is a text message
    var isTextMessage: Bool {
        type == .text
    }
    
    /// Check if this message is from the user
    var isFromUser: Bool {
        sender == .user
    }
    
    /// Simple time format for message bubbles (e.g., "2:30 PM")
    var simpleTimeFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Message Creation Helpers
extension Message {
    /// Create a new text message
    static func createTextMessage(content: String, sender: MessageSender) -> Message {
        Message(
            id: UUID().uuidString,
            message: content,
            type: .text,
            file: nil,
            sender: sender,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
    
    /// Create a new file message
    static func createFileMessage(
        caption: String = "",
        path: String,
        fileSize: Int,
        thumbnailPath: String? = nil,
        sender: MessageSender
    ) -> Message {
        let thumbnail = thumbnailPath.map { Thumbnail(path: $0) }
        let file = FileAttachment(path: path, fileSize: fileSize, thumbnail: thumbnail)
        
        return Message(
            id: UUID().uuidString,
            message: caption,
            type: .file,
            file: file,
            sender: sender,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
}
