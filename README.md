# AgentChat - SwiftUI Chat Interface

A beautiful and fully-featured chat interface application built with SwiftUI that displays messages between a user and an AI agent.

## 📱 Screenshots

The app features:
- **Home Page**: Stunning animated gradient background with glassmorphism effects
- **Chat Interface**: Modern message bubbles with different styling for user/agent
- **Image Support**: Full-screen image viewer with pinch-to-zoom

## 🏗 Architecture

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern with proper separation of concerns:

```
AgentChat/
├── Models/
│   └── Message.swift           # Data models (Message, FileAttachment, Thumbnail)
├── ViewModels/
│   └── ChatViewModel.swift     # Business logic and state management
├── Views/
│   ├── HomeView.swift          # Home page with navigation
│   ├── ChatView.swift          # Main chat interface
│   └── Components/
│       ├── MessageBubbleView.swift    # Message bubble UI
│       ├── MessageInputBar.swift      # Text input with attachments
│       ├── TypingIndicatorView.swift  # Animated typing dots
│       └── FullScreenImageView.swift  # Image viewer with zoom
├── Services/
│   ├── MessageStorage.swift     # Local persistence (UserDefaults)
│   ├── ImageCacheService.swift  # Image caching & compression
│   └── SeedData.swift           # Initial seed messages
└── AgentChatApp.swift           # App entry point
```

### Key Design Decisions

1. **MVVM Pattern**: Separates UI logic from business logic, making the code testable and maintainable.

2. **Observable State**: Uses `@StateObject` and `@Published` for reactive UI updates.

3. **Protocol-Oriented Storage**: `MessageStorageProtocol` allows for easy testing and dependency injection.

4. **Image Caching**: Two-level cache (memory + disk) for efficient image loading and reduced network calls.

5. **Pagination**: Messages are loaded in chunks (15 at a time) to optimize memory usage with large conversations.

## ✨ Features

### Core Features
- ✅ Message list display in chronological order
- ✅ Auto-scroll to latest message on load and when new message added
- ✅ Different UI alignment (user: right/blue, agent: left/gray)
- ✅ Timestamp for each message
- ✅ Text message rendering in bubbles
- ✅ File/image message display with thumbnails
- ✅ File size display (formatted, e.g., "2.3 MB")
- ✅ Full-screen image viewer with pinch-to-zoom
- ✅ Text input with send button (disabled when empty)
- ✅ Attachment button (photo gallery + camera)
- ✅ Input bar moves up with keyboard
- ✅ State management with `@StateObject`
- ✅ Local caching with UserDefaults
- ✅ 25 pre-populated seed messages on first launch

### Bonus Features Implemented
- ✅ **Smooth animations** for keyboard, message send, and bubble appearance
- ✅ **Smart timestamp formatting**:
  - "Just now" for < 1 minute
  - "X minutes ago" for recent
  - "Today at 2:30 PM"
  - "Yesterday at 5:45 PM"
  - Full date for older messages
- ✅ **Typing indicator animation** (simulated bouncing dots)
- ✅ **Pagination support**: Load 15 messages at a time with "Load Earlier" button
- ✅ **Image caching**: Memory + disk cache for network images
- ✅ **Image compression**: JPEG compression before saving
- ✅ **Long-press to copy**: Hold any message to copy text with haptic feedback
- ✅ **Thumbnail generation**: Programmatic thumbnail creation for saved images

## 🚀 Setup Instructions

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation

1. Clone the repository or unzip the project:
```bash
git clone <repository-url>
cd AgentChat
```

2. Open the project in Xcode:
```bash
open AgentChat.xcodeproj
```

3. Select your target device or simulator (iPhone recommended)

4. Build and run the project:
   - Press `Cmd + R` or click the Play button

### Permissions Required
- **Camera**: For taking photos (Info.plist entry needed for physical device)
- **Photo Library**: For selecting images from gallery

## 📂 File Structure Details

### Models
- **Message.swift**: Core data model with:
  - Message types (text/file)
  - Sender types (user/agent)
  - Smart timestamp formatting
  - Helper methods for message creation

### ViewModels
- **ChatViewModel.swift**: Manages:
  - Message loading and persistence
  - Pagination logic
  - Image handling and compression
  - Simulated agent responses
  - Error handling

### Views
- **HomeView.swift**: Beautiful landing page with:
  - Animated gradient background
  - Glassmorphism UI elements
  - Navigation to chat

- **ChatView.swift**: Main chat interface with:
  - ScrollView with LazyVStack
  - Message pagination
  - Camera integration
  - Full-screen image presentation

### Services
- **MessageStorage.swift**: Handles:
  - Save/load messages to UserDefaults
  - Seed data initialization

- **ImageCacheService.swift**: Provides:
  - Memory caching with NSCache
  - Disk caching in Caches directory
  - Image compression (configurable quality)
  - Thumbnail generation

## 🎨 UI/UX Highlights

1. **Custom Chat Bubble Shape**: Unique bubble shapes with tails pointing to sender
2. **Gradient Backgrounds**: Premium dark mode aesthetic
3. **Micro-animations**: Spring animations for buttons, messages, and transitions
4. **Haptic Feedback**: Tactile response on long-press actions
5. **Smooth Scrolling**: Optimized LazyVStack with efficient rendering

## 🧪 Testing Recommendations

### Manual Testing Scenarios
1. **First Launch**: Verify 25 seed messages load correctly
2. **Send Text**: Type and send a message, verify it appears
3. **Send Image**: Attach image from gallery, verify compression
4. **Scroll Up**: Load earlier messages via pagination
5. **Long Press**: Copy message text, verify clipboard
6. **Image Zoom**: Tap image, pinch to zoom in/out
7. **App Restart**: Close and reopen, verify messages persist

## 📝 Notes

- The agent responses are simulated with random messages after a 2-second delay
- Images from URLs are cached for offline viewing
- Local images are compressed to ~70% JPEG quality
- The app supports both light and dark mode

## 🔮 Future Enhancements

Potential improvements for future versions:
- Real API integration for agent responses
- Message search functionality
- Message deletion/editing
- Voice message support
- Push notifications
- Read receipts
- Message reactions

---

Built with ❤️ using SwiftUI
