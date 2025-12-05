// services/websocket_service.dart
import '../models/message.dart';
import '../models/conversation.dart';

typedef MessageListener = void Function(Message message);
typedef ConversationListener = void Function(Conversation conversation);

/// In-memory singleton WebSocket-like service for local development.
class WebSocketService {
  WebSocketService._internal();

  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  final List<Message> _messages = [];
  final List<MessageListener> _listeners = [];
  final Map<String, Conversation> _conversations = <String, Conversation>{};
  final List<ConversationListener> _conversationListeners = [];

  String? _currentUserId;
  String? _currentUserType;

  /// Simulate a connection for a particular user.
  void connect(String userId, String userType) {
    _currentUserId = userId;
    _currentUserType = userType;
    _initializeDefaultConversations();
  }

  void _initializeDefaultConversations() {
    // Initialize default conversations if none exist
    if (_conversations.isEmpty) {
      final doctorConversations = [
        Conversation(
          id: 'conv_dr_ali_ahmed_patient_john',
          name: 'John Patient',
          patientImageUrl:
              'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop',
          isOnline: true,
          lastMessage: 'Hello doctor, I have a question about my prescription',
          unreadCount: 2,
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Conversation(
          id: 'conv_dr_ali_ahmed_patient_sarah',
          name: 'Sarah Williams',
          patientImageUrl:
              'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
          isOnline: false,
          lastMessage: 'Thank you for the consultation!',
          unreadCount: 0,
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      // FIXED: Create separate conversation IDs for patient view
      final patientConversations = [
        Conversation(
          id: 'patient_dr_ali_ahmed', // Different ID for patient view
          name: 'Dr. Ali Ahmed',
          specialty: 'Cardiologist',
          lastMessage: 'Hello are you good', // Doctor's message
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
          unreadCount: 1, // Should show as unread
          isOnline: true,
          isDoctor: true,
          doctorImageUrl:
              'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop',
        ),
        Conversation(
          id: 'patient_dr_sarah_wilson',
          name: 'Dr. Sarah Wilson',
          specialty: 'Pediatrician',
          lastMessage: 'Your test results are ready',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
          isOnline: false,
          isDoctor: true,
          doctorImageUrl:
              'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=100&auto=format&fit=crop',
        ),
        Conversation(
          id: 'patient_dr_michael_brown',
          name: 'Dr. Michael Brown',
          specialty: 'Dermatologist',
          lastMessage: 'The cream is working well',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          isOnline: true,
          isDoctor: true,
          doctorImageUrl:
              'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop',
        ),
      ];

      // Register all conversations
      for (var conv in [...doctorConversations, ...patientConversations]) {
        _conversations[conv.id] = conv;
      }
    }
  }

  void addMessageListener(MessageListener listener) {
    _listeners.add(listener);
  }

  void removeMessageListener(MessageListener listener) {
    _listeners.remove(listener);
  }

  /// Generate conversation ID that works for both users
  String _getConversationId(String user1, String user2) {
    final users = [user1, user2]..sort();
    return 'conv_${users[0]}_${users[1]}';
  }

  /// Store message and notify listeners - FIXED for WhatsApp-like behavior
  void sendMessage(Message message) {
    // Add message to storage
    _messages.add(message);

    // Notify all message listeners (for active chat screens)
    for (final listener in List<MessageListener>.from(_listeners)) {
      try {
        listener(message);
      } catch (_) {
        // ignore listener errors
      }
    }

    // CRITICAL FIX: After notifying listeners, update the conversation state for both users.
    // This ensures the conversation list screen reflects the new message and unread count.
    final conversationId = _getConversationId(
      message.senderId,
      message.recipientId ?? '',
    );
    _updateConversationForNewMessage(message, conversationId);

    print(
      '📱 Message sent: "${message.text}" from ${message.senderName} to ${message.recipientId}',
    );
  }

  /// Update conversation when a new message is sent/received - FIXED logic
  void _updateConversationForNewMessage(
    Message message,
    String conversationId,
  ) {
    final isFromCurrentUser = message.senderId == _currentUserId;

    // Determine the correct conversation IDs for both the doctor's and patient's views.
    // This logic assumes a naming convention to find the two separate conversation objects.
    final doctorId = message.senderType == 'doctor'
        ? message.senderId
        : message.recipientId;
    final patientId = message.senderType == 'patient'
        ? message.senderId
        : message.recipientId;

    // This should always be true if the message is valid
    if (doctorId == null || patientId == null) return;

    // Construct the unique IDs for both views of the conversation
    final doctorConvId = 'conv_${doctorId}_${patientId}';
    final patientConvId = 'patient_${doctorId}';
    final doctorConversation =
        _conversations[doctorConvId] ?? _conversations[conversationId];
    final patientConversation = _conversations[patientConvId];

    // --- Update Sender's Conversation ---
    // The sender's unread count is always 0.
    if (isFromCurrentUser) {
      Conversation? senderConv = (_currentUserType == 'doctor')
          ? doctorConversation
          : patientConversation;
      String? senderConvId = (_currentUserType == 'doctor')
          ? doctorConvId
          : patientConvId;

      if (senderConv != null && senderConvId != null) {
        final updated = senderConv.copyWith(
          lastMessage: message.text,
          lastMessageTime: message.timestamp,
          unreadCount: 0, // Sender has seen the message they sent.
        );
        _conversations[senderConvId] = updated;
        _notifyConversationListeners(updated);
        print('💬 Sender view updated: ${updated.name} - "${message.text}"');
      }
    }

    // --- Update Recipient's Conversation ---
    // The recipient's unread count is incremented.
    Conversation? recipientConv = (_currentUserType == 'doctor')
        ? patientConversation
        : doctorConversation;
    String? recipientConvId = (_currentUserType == 'doctor')
        ? patientConvId
        : doctorConvId;

    if (recipientConv != null && recipientConvId != null) {
      final updated = recipientConv.copyWith(
        lastMessage: message.text,
        lastMessageTime: message.timestamp,
        unreadCount:
            (recipientConv.unreadCount) + 1, // Increment for recipient.
      );
      _conversations[recipientConvId] = updated;
      _notifyConversationListeners(updated);
      print(
        '💬 Recipient view updated: ${updated.name} - "${message.text}" (Unread: ${updated.unreadCount})',
      );
    }
  }

  /// Register or update a conversation
  void registerConversation(Conversation conversation) {
    // This is a copy from another version of the file, let's use the one from the other file.
    final conversationId = conversation.id.trim();
    if (conversationId.isNotEmpty) {
      _conversations[conversationId] = conversation;
    }
  }

  /// Get a conversation by ID
  Conversation? getConversation(String conversationId) {
    return _conversations[conversationId];
  }

  /// Get all conversations for current user - FIXED sorting
  List<Conversation> getAllConversations() {
    if (_currentUserId == null) return [];

    final userConversations = _conversations.values.where((conv) {
      // Conversation ID contains both user IDs, so check if current user is part of it
      return conv.id.contains(_currentUserId!);
    }).toList();

    // Sort by last message time (newest first) - LIKE WHATSAPP
    userConversations.sort(
      (a, b) => (b.lastMessageTime ?? DateTime(1970)).compareTo(
        a.lastMessageTime ?? DateTime(1970),
      ),
    );

    return userConversations;
  }

  /// Get conversations for doctor (only patients)
  List<Conversation> getDoctorConversations() {
    final conversations = _conversations.values.where((conv) {
      return conv.id.startsWith('conv_') && conv.id.contains('dr_ali_ahmed');
    }).toList();

    // Sort by last message time (newest first) - LIKE WHATSAPP
    conversations.sort(
      (a, b) => (b.lastMessageTime ?? DateTime(1970)).compareTo(
        a.lastMessageTime ?? DateTime(1970),
      ),
    );

    return conversations;
  }

  /// Get conversations for patient (only doctors) - FIXED
  List<Conversation> getPatientConversations() {
    final conversations = _conversations.values.where((conv) {
      return conv.id.startsWith('patient_dr_') ||
          (conv.isDoctor && !conv.id.startsWith('conv_'));
    }).toList();

    // Sort by last message time (newest first) - LIKE WHATSAPP
    conversations.sort(
      (a, b) => (b.lastMessageTime ?? DateTime(1970)).compareTo(
        a.lastMessageTime ?? DateTime(1970),
      ),
    );

    return conversations;
  }

  /// Add a listener for conversation updates
  void addConversationListener(ConversationListener listener) {
    _conversationListeners.add(listener);
  }

  /// Remove a conversation listener
  void removeConversationListener(ConversationListener listener) {
    _conversationListeners.remove(listener);
  }

  /// Notify all conversation listeners
  void _notifyConversationListeners(Conversation conversation) {
    for (final listener in List<ConversationListener>.from(
      _conversationListeners,
    )) {
      try {
        listener(conversation);
      } catch (_) {
        // ignore listener errors
      }
    }
  }

  /// Update a conversation's last message directly
  void updateConversationLastMessage({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String lastMessage,
    required DateTime lastMessageTime,
    String? senderName,
  }) {
    final conv = _conversations[conversationId];
    if (conv != null) {
      final isFromCurrentUser = senderId == _currentUserId;
      final updated = conv.copyWith(
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        // CRITICAL FIX: Only increment unread for received messages
        unreadCount: isFromCurrentUser ? 0 : (conv.unreadCount + 1),
      );
      _conversations[conversationId] = updated;
      _notifyConversationListeners(updated);
    }
  }

  /// Return messages relevant to the currently connected user and the
  /// provided other participant (by id/type). - FIXED ordering
  List<Message> getMessages(String otherUserId, String otherUserType) {
    if (_currentUserId == null || _currentUserType == null) {
      return List<Message>.from(_messages);
    }

    final conversationId = _getConversationId(_currentUserId!, otherUserId);

    final filtered = _messages.where((m) {
      final msgConversationId = _getConversationId(
        m.senderId,
        m.recipientId ?? '',
      );
      return msgConversationId == conversationId;
    }).toList();

    // FIXED: Sort by timestamp ASCENDING (oldest first) for chat screen
    // This makes new messages appear at the bottom
    filtered.sort((a, b) {
      if (a.timestamp == null || b.timestamp == null) return 0;
      return a.timestamp!.compareTo(b.timestamp!);
    });

    return filtered;
  }

  /// Get the most recent message for a specific conversation
  Message? getLastMessage(String otherUserId) {
    if (_currentUserId == null) return null;

    final conversationId = _getConversationId(_currentUserId!, otherUserId);
    final relevant = _messages.where((m) {
      final msgConversationId = _getConversationId(
        m.senderId,
        m.recipientId ?? '',
      );
      return msgConversationId == conversationId;
    }).toList();

    if (relevant.isEmpty) return null;

    // Sort by timestamp descending to get the most recent
    relevant.sort((a, b) {
      if (a.timestamp == null || b.timestamp == null) return 0;
      return b.timestamp!.compareTo(a.timestamp!);
    });

    return relevant.first;
  }

  /// Mark a conversation as read
  void markConversationAsRead(String conversationId) {
    final conv = _conversations[conversationId];
    if (conv != null && conv.unreadCount > 0) {
      final updated = conv.copyWith(unreadCount: 0);
      _conversations[conversationId] = updated;
      _notifyConversationListeners(updated);
      print('✅ Conversation marked as read: ${conv.name}');
    }
  }

  /// Clear all messages (for testing/reset)
  void clearMessages() {
    _messages.clear();
  }

  /// Get unread count for a conversation
  int getUnreadCount(String conversationId) {
    return _conversations[conversationId]?.unreadCount ?? 0;
  }

  /// Get total unread count across all conversations
  int getTotalUnreadCount() {
    return _conversations.values.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  /// Check if conversation is registered
  bool isConversationRegistered(String conversationId) {
    return _conversations.containsKey(conversationId);
  }
}

// Constants for default images
const String kDoctorImageUrl =
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const String kPatientImageUrl =
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop';
