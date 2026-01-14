//
//  SeedData.swift
//  AgentChat
//
//  Provides initial seed data for the chat application
//

import Foundation

struct SeedData {
    
    /// Returns the initial 25 seed messages for the chat
    static func getMessages() -> [Message] {
        return [
            // Original 10 messages from the specification
            Message(
                id: "msg-001",
                message: "Hi! I need help booking a flight to Mumbai.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520000000
            ),
            Message(
                id: "msg-002",
                message: "Hello! I'd be happy to help you book a flight to Mumbai. When are you planning to travel?",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520030000
            ),
            Message(
                id: "msg-003",
                message: "Next Friday, December 29th.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520090000
            ),
            Message(
                id: "msg-004",
                message: "Great! And when would you like to return?",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520120000
            ),
            Message(
                id: "msg-005",
                message: "January 5th. Also, I prefer morning flights.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520180000
            ),
            Message(
                id: "msg-006",
                message: "Perfect! Let me search for morning flights from your location to Mumbai. Could you also share your departure city?",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520210000
            ),
            Message(
                id: "msg-007",
                message: "Bangalore. Here's a screenshot of my preferred airline.",
                type: .file,
                file: FileAttachment(
                    path: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400",
                    fileSize: 245680,
                    thumbnail: Thumbnail(path: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=100")
                ),
                sender: .user,
                timestamp: 1703520300000
            ),
            Message(
                id: "msg-008",
                message: "Thanks for sharing! I can see you prefer IndiGo. Let me find the best options for you.",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520330000
            ),
            Message(
                id: "msg-009",
                message: "Flight options comparison",
                type: .file,
                file: FileAttachment(
                    path: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=400",
                    fileSize: 189420,
                    thumbnail: Thumbnail(path: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=100")
                ),
                sender: .agent,
                timestamp: 1703520420000
            ),
            Message(
                id: "msg-010",
                message: "The second option looks perfect! How do I proceed?",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520480000
            ),
            
            // Additional 15 messages to reach 25 total
            Message(
                id: "msg-011",
                message: "I'll guide you through the booking process. First, I need your personal details. Could you share your full name as it appears on your passport?",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520540000
            ),
            Message(
                id: "msg-012",
                message: "Sure, it's Rahul Kumar Sharma.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520600000
            ),
            Message(
                id: "msg-013",
                message: "Thank you, Rahul! Now I'll need your date of birth and passport number for the booking.",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520660000
            ),
            Message(
                id: "msg-014",
                message: "DOB: 15/08/1992, Passport: K2458796",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520720000
            ),
            Message(
                id: "msg-015",
                message: "Perfect! I've noted your details. Would you like to add any meal preferences or extra baggage to your booking?",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703520780000
            ),
            Message(
                id: "msg-016",
                message: "Yes, please add vegetarian meals and I'll need one extra checked bag.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520840000
            ),
            Message(
                id: "msg-017",
                message: "Got it! Here's a summary of your extras. The additional baggage will cost ₹2,500.",
                type: .file,
                file: FileAttachment(
                    path: "https://images.unsplash.com/photo-1553531384-cc64ac80f931?w=400",
                    fileSize: 156780,
                    thumbnail: Thumbnail(path: "https://images.unsplash.com/photo-1553531384-cc64ac80f931?w=100")
                ),
                sender: .agent,
                timestamp: 1703520900000
            ),
            Message(
                id: "msg-018",
                message: "That's fine. Let's proceed with the payment.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703520960000
            ),
            Message(
                id: "msg-019",
                message: "Great! Your total comes to ₹15,850 including taxes and extras. How would you like to pay? We accept UPI, Credit/Debit cards, and Net Banking.",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703521020000
            ),
            Message(
                id: "msg-020",
                message: "I'll pay using UPI.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703521080000
            ),
            Message(
                id: "msg-021",
                message: "Perfect! I'm generating a secure UPI payment link for you. Please wait a moment...",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703521140000
            ),
            Message(
                id: "msg-022",
                message: "Here's your payment QR code. Please scan it with your UPI app to complete the payment.",
                type: .file,
                file: FileAttachment(
                    path: "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400",
                    fileSize: 98450,
                    thumbnail: Thumbnail(path: "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=100")
                ),
                sender: .agent,
                timestamp: 1703521200000
            ),
            Message(
                id: "msg-023",
                message: "Done! Payment completed successfully.",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703521260000
            ),
            Message(
                id: "msg-024",
                message: "🎉 Congratulations! Your booking is confirmed! I'm sending your e-ticket and boarding pass details to your registered email. Is there anything else I can help you with?",
                type: .text,
                file: nil,
                sender: .agent,
                timestamp: 1703521320000
            ),
            Message(
                id: "msg-025",
                message: "That's all for now. Thank you so much for your help!",
                type: .text,
                file: nil,
                sender: .user,
                timestamp: 1703521380000
            )
        ]
    }
}
