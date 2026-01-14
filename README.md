# AgentChat - SwiftUI Chat Interface

A clean and functional chat interface application built with SwiftUI that displays messages between a user and an AI agent.

## 🏗 Architecture

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern with proper separation of concerns:

```
AgentChat/
├── Models/
│   └── Message.swift           # Data models (Message, FileAttachment, Thumbnail)
├── ViewModels/
│   └── ChatViewModel.swift     # Business logic and state management
├── Views/
│   ├── HomeView.swift          # Simple home page with navigation
│   ├── ChatView.swift          # Main chat interface
│   └── Components/
│       ├── MessageBubbleView.swift    # Message bubble UI
│       ├── MessageComposer.swift      # Text input with attachments
|       ├── TypingIndicatorView.swift  # Typing Indicator before agent response
│       └── FullScreenImageView.swift  # Image viewer with zoom
├── Services/
│   ├── MessageStorage.swift     # Local persistence (UserDefaults)
│   ├── ImageCacheService.swift  # Basic image loading & saving
│   └── SeedData.swift           # Initial seed messages
└── AgentChatApp.swift           # App entry point
```

### Key Design Decisions

1. **MVVM Pattern**: Separates UI logic from business logic, making the code testable and maintainable.

2. **Observable State**: Uses `@StateObject` and `@Published` for reactive UI updates.

3. **Protocol-Oriented Storage**: `MessageStorageProtocol` allows for easy testing and dependency injection.

## ✅ Features Implemented

### Core Features
- ✅ Message list display in chronological order
- ✅ Auto-scroll to latest message on load and when new message added
- ✅ Different UI alignment (user: right/blue, agent: left/gray)
- ✅ Timestamp for each message (simple format, e.g., "2:30 PM")
- ✅ Text message rendering in bubbles
- ✅ File/image message display with thumbnails
- ✅ File size display (formatted, e.g., "2.3 MB")
- ✅ Full-screen image viewer with pinch-to-zoom
- ✅ Text input with send button (disabled when empty)
- ✅ Attachment button (photo gallery + camera)
- ✅ Keyboard handling (scroll dismisses keyboard)
- ✅ State management with `@StateObject`
- ✅ Local caching with UserDefaults
- ✅ 25 pre-populated seed messages on first launch
- ✅ MVVM Architecture
- ✅ Simple home page with navigation to chat

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
- **Camera**: For taking photos
- **Photo Library**: For selecting images from gallery

## 📱 App Flow

1. **Home Page** - Simple landing page with "Start Conversation" button
2. **Chat View** - Chat interface with:
   - 25 pre-loaded messages
   - Send text messages
   - Attach images from gallery or camera
   - Tap images for full-screen view with zoom

## 🧪 Testing Recommendations

### Manual Testing Scenarios
1. **First Launch**: Verify 25 seed messages load correctly
2. **Send Text**: Type and send a message, verify it appears
3. **Send Image**: Attach image from gallery, verify it's saved
4. **Image Zoom**: Tap image, pinch to zoom in/out
5. **App Restart**: Close and reopen, verify messages persist

## 📝 Notes

- The agent responses are simulated with random messages
- Messages are persisted locally using UserDefaults
- The app supports both light and dark mode

## 📸 ScreenShots

<img width="300" height="750" alt="Screenshot 2026-01-15 at 12 54 30 AM" src="https://github.com/user-attachments/assets/c90356b7-b0ac-4090-9350-f8845f6e6112" />
<img width="300" height="750" alt="Screenshot 2026-01-15 at 12 55 14 AM" src="https://github.com/user-attachments/assets/1fa36fd8-1267-43a4-8af1-9cb1b827ab24" />
<img width="300" height="750" alt="Screenshot 2026-01-15 at 12 55 20 AM" src="https://github.com/user-attachments/assets/be0eeb4f-0c3f-4b09-8046-f23c6eec4d40" />

---

Built with SwiftUI
