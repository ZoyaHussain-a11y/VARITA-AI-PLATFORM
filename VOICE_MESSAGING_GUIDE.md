# Doctor-Patient Conversation System - Implementation Guide

## Overview
This document outlines how the doctor-patient conversation system works, including text messages, voice messages, and attachments.

---

## Conversation Flow

### 1. **Initialization**
```
Patient/Doctor opens Messages tab
    ↓
Selects conversation from list
    ↓
Chat screen opens
    ↓
WebSocketService initializes connection
    ↓
Loads existing message history
    ↓
Displays messages in chronological order
```

### 2. **Message Types**

#### **Text Message**
- User types text → Clicks send button
- Creates `Message` object with `isVoiceNote: false`
- Sent via `WebSocketService.sendMessage()`
- Displayed in bubble with timestamp

#### **Voice Message** ✅ NEW
- User clicks microphone icon
- `VoiceMessageService.startListening()` begins recording
- Microphone captures speech (max 30 seconds)
- User clicks stop button
- `VoiceMessageService.stopListening()` triggers speech-to-text
- Audio → Text conversion happens automatically
- Converted text is sent as message with `isVoiceNote: true`
- Message displays with playback icon: "▶ Voice Note (0:45)"

#### **File Attachment**
- User clicks attachment icon
- File picker opens
- Selected file is sent with `isAttachment: true`
- Displays with file icon and name

---

## Voice Message Implementation

### **Architecture**

```
User clicks Mic Icon
    ↓
VoiceMessageService.startListening()
    └─ Requests microphone permission
    └─ Initializes speech_to_text
    └─ Records audio stream
    ↓
User records message (max 30 seconds)
    ↓
User clicks Stop
    ↓
VoiceMessageService.stopListening()
    └─ Stops recording
    └─ Runs speech-to-text conversion
    └─ Returns recognized text
    ↓
Create Message with:
  - text: "Recognized text from audio"
  - isVoiceNote: true
  - voiceNoteDuration: "0:45"
  - voiceNoteConfidence: 0.95
    ↓
WebSocketService.sendMessage()
    ↓
Message sent to other party
    ↓
Receiver sees: "▶ Voice Note (0:45)" with play icon
```

### **Key Components**

#### **1. VoiceMessageService** (`lib/services/voice_message_service.dart`)
- Handles microphone permissions
- Records voice input
- Converts speech to text using `speech_to_text` package
- Returns recognized text with confidence level

#### **2. Message Model** (Updated)
- `isVoiceNote`: Flag to identify voice messages
- `voiceNoteDuration`: Display duration (e.g., "0:45")
- `voiceNoteConfidence`: Accuracy of speech recognition

#### **3. Chat UI Updates**
- Microphone button in input bar
- Shows "Recording..." state with waveform animation
- Displays voice message bubbles with playback icon
- Shows confidence indicator on received voice messages

---

## User Flow: Sending a Voice Message

### **Step 1: User Interface**
```
Chat screen displays
    ↓
Input bar with: [😊] [Text field] [📎] [📷] [🎤] [Send]
                                                    ↑
                                            Voice message button
```

### **Step 2: Recording**
```
User clicks 🎤 button
    ↓
Recording starts
    ↓
UI shows: "🎤 Recording... 0:05"
    ↓
User speaks: "Hi Doctor, I'm feeling better today"
    ↓
User clicks Stop or waits 30 seconds (auto-stop)
```

### **Step 3: Processing**
```
Voice recording stops
    ↓
Speech-to-text converts audio:
    "Hi Doctor, I'm feeling better today"
    (Confidence: 0.92)
    ↓
Creates message object:
{
  id: "msg_123",
  text: "Hi Doctor, I'm feeling better today",
  senderId: "patient_john",
  senderName: "John Patient",
  senderType: "patient",
  timestamp: 2025-11-29 10:30:45,
  isVoiceNote: true,
  voiceNoteDuration: "0:05",
  voiceNoteConfidence: 0.92
}
```

### **Step 4: Sending & Display**
```
Message sent via WebSocketService
    ↓
Appears in chat as:
┌─────────────────────────────┐
│ ▶ Voice Note (0:05)         │ ← Doctor receives
│ Hi Doctor, I'm feeling...   │
│ 10:30 ✓✓                   │ (confidence: 92%)
└─────────────────────────────┘
```

---

## Features & Benefits

### **For Patients**
✅ Easy voice input (hands-free option)  
✅ Natural conversation flow  
✅ No typing on mobile  
✅ Faster communication  

### **For Doctors**
✅ Audio-to-text messages  
✅ Can reply with voice  
✅ Can still read text if needed  
✅ Professional documentation  

---

## Technical Implementation Details

### **Permissions Required**
```dart
// Android: AndroidManifest.xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />

// iOS: Info.plist
NSMicrophoneUsageDescription: "Microphone access required for voice messages"
NSSpeechRecognitionUsageDescription: "Speech recognition for voice messages"
```

### **Dependencies**
```yaml
speech_to_text: ^6.1.1          # Speech recognition
permission_handler: ^11.4.4     # Microphone permissions
```

### **Service Methods**

```dart
// Initialize and request permissions
await voiceService.initialize();

// Start recording
await voiceService.startListening();

// Stop recording and get text
String recognizedText = await voiceService.stopListening();

// Cancel recording
await voiceService.cancel();

// Check if recording
bool isRecording = voiceService.isListening;
```

---

## Error Handling

```
Microphone Permission Denied
    ↓
Show alert: "Please enable microphone in settings"

Speech Recognition Unavailable
    ↓
Show message: "Speech recognition not available on this device"

Network Error Sending Message
    ↓
Show: "Failed to send message. Retry?"

No Audio Detected
    ↓
Show: "No speech detected. Please try again"
```

---

## Future Enhancements

🔮 Playback functionality (listen to recorded message)  
🔮 Voice message duration display with progress bar  
🔮 Confidence indicator showing speech recognition accuracy  
🔮 Multiple language support  
🔮 Voice message transcription display  
🔮 Encryption for voice data  

---

## Testing Voice Messages

1. **Test 1**: Send voice message with clear speech
   - Expected: Message sends with high confidence (>0.9)

2. **Test 2**: Send voice message with background noise
   - Expected: Message sends with lower confidence (0.7-0.8)

3. **Test 3**: Send voice message while offline
   - Expected: Message queued, sent when online

4. **Test 4**: Cancel recording mid-way
   - Expected: Recording stops, no message sent

5. **Test 5**: Multiple voice messages in sequence
   - Expected: Each message processes independently
