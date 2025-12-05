// This is an EXAMPLE file showing how to integrate Drift into chat_screen.dart
// Copy patterns from here to update your actual screens

import 'package:flutter/material.dart';
import 'lib/models/message.dart';
import 'lib/database/app_database.dart';
import 'lib/services/database_service.dart';

// EXAMPLE: ChatScreen with Drift Integration
class ChatScreenWithDrift extends StatefulWidget {
  final String conversationId;
  final String conversationName;
  final bool isDoctor;

  const ChatScreenWithDrift({
    super.key,
    required this.conversationId,
    required this.conversationName,
    this.isDoctor = true,
  });

  @override
  State<ChatScreenWithDrift> createState() => _ChatScreenWithDriftState();
}

class _ChatScreenWithDriftState extends State<ChatScreenWithDrift> {
  final TextEditingController _textController = TextEditingController();
  late final DatabaseService _dbService;
  List<MessageData> _messages = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _currentUserType;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _currentUserId = widget.isDoctor ? 'dr_ali_ahmed' : 'patient_john';
    _currentUserType = widget.isDoctor ? 'doctor' : 'patient';
    _loadMessages();
  }

  // Load all messages from database
  Future<void> _loadMessages() async {
    try {
      final messages =
          await _dbService.getMessagesByConversation(widget.conversationId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
    }
  }

  // Send a new message
  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final messageText = _textController.text.trim();
    _textController.clear();

    try {
      final newMessage = MessagesCompanion(
        messageId: Value(
          'msg_${DateTime.now().millisecondsSinceEpoch}',
        ),
        conversationId: Value(widget.conversationId),
        text: Value(messageText),
        senderId: Value(_currentUserId!),
        senderName: Value(widget.isDoctor ? 'Dr. Name' : 'Patient Name'),
        senderType: Value(_currentUserType!),
        timestamp: Value(DateTime.now()),
        isVoiceNote: const Value(false),
        isAttachment: const Value(false),
      );

      // Save to database
      await _dbService.createMessage(newMessage);

      // Reload messages
      await _loadMessages();

      // Optional: Update conversation's last message
      await _dbService.createConversation(
        ConversationsCompanion(
          conversationId: Value(widget.conversationId),
          lastMessage: Value(messageText),
          lastMessageTime: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  // Delete all messages in conversation
  Future<void> _clearConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Messages?'),
        content: const Text('This will delete all messages in this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await _dbService.deleteAllMessages(widget.conversationId);
        await _loadMessages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Messages cleared')),
          );
        }
      } catch (e) {
        print('Error clearing messages: $e');
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearConversation,
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(
                          child: Text('No messages yet. Start a conversation!'),
                        )
                      : ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isCurrentUser =
                                message.senderId == _currentUserId;

                            return Align(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue.shade200
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.text,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      message.timestamp != null
                                          ? _formatTime(message.timestamp!)
                                          : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Message input
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _sendMessage,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// EXAMPLE: How to use this in your app
/*
  // Call it like this:
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreenWithDrift(
        conversationId: 'conv_123',
        conversationName: 'Dr. Ali Ahmed',
        isDoctor: true,
      ),
    ),
  );
*/

// EXAMPLE: List all conversations from Drift
class ConversationListExample extends StatefulWidget {
  const ConversationListExample({super.key});

  @override
  State<ConversationListExample> createState() =>
      _ConversationListExampleState();
}

class _ConversationListExampleState extends State<ConversationListExample> {
  late final DatabaseService _dbService;
  List<ConversationData> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _dbService.getAllConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                return ListTile(
                  title: Text(conv.name),
                  subtitle: Text(conv.lastMessage ?? 'No messages'),
                  trailing: conv.unreadCount > 0
                      ? CircleAvatar(
                          child: Text(conv.unreadCount.toString()),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreenWithDrift(
                          conversationId: conv.conversationId,
                          conversationName: conv.name,
                          isDoctor: conv.isDoctor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
