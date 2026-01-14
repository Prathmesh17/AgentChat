//
//  MessageStorage.swift
//  AgentChat
//
//  Handles local persistence of chat messages using UserDefaults
//

import Foundation

// MARK: - Message Storage Protocol
protocol MessageStorageProtocol {
    func saveMessages(_ messages: [Message])
    func loadMessages() -> [Message]
    func clearMessages()
    func hasExistingMessages() -> Bool
}

// MARK: - UserDefaults Message Storage
class MessageStorage: MessageStorageProtocol {
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let messagesKey = "cached_messages"
    private let hasSeededKey = "has_seeded_data"
    
    // MARK: - Shared Instance
    static let shared = MessageStorage()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Saves messages to local storage
    func saveMessages(_ messages: [Message]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messages)
            userDefaults.set(data, forKey: messagesKey)
        } catch {
            print("❌ Failed to save messages: \(error)")
        }
    }
    
    /// Loads messages from local storage
    func loadMessages() -> [Message] {
        guard let data = userDefaults.data(forKey: messagesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let messages = try decoder.decode([Message].self, from: data)
            return messages
        } catch {
            print("❌ Failed to load messages: \(error)")
            return []
        }
    }
    
    /// Clears all cached messages
    func clearMessages() {
        userDefaults.removeObject(forKey: messagesKey)
        userDefaults.removeObject(forKey: hasSeededKey)
    }
    
    /// Checks if there are existing cached messages
    func hasExistingMessages() -> Bool {
        return userDefaults.data(forKey: messagesKey) != nil
    }
    
    /// Checks if seed data has been loaded before
    func hasSeededData() -> Bool {
        return userDefaults.bool(forKey: hasSeededKey)
    }
    
    /// Marks that seed data has been loaded
    func markSeededDataLoaded() {
        userDefaults.set(true, forKey: hasSeededKey)
    }
}
