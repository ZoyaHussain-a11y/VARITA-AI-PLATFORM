// screens/doctor_chat_screen.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/websocket_service.dart';
import '../models/conversation.dart';

// Reusing constants
const Color kPrimaryColor = Color(0xFF2196F3);
const Color kBackgroundColor = Color(0xFFF7F7F7);

class DoctorChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String patientImageUrl;

  const DoctorChatScreen({
    super.key,
    required this.conversation,
    required this.patientImageUrl,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final WebSocketService _webSocketService = WebSocketService();
  final List<Message> _messages = [];
  String? _currentUserId;
  String? _currentUserType;
  String? _otherUserId;
  String? _otherUserType;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _loadExistingMessages();
  }

  void _initializeWebSocket() {
    // Connect as doctor
    _currentUserId = 'dr_ali_ahmed';
    _currentUserType = 'doctor';
    // Use the conversation id (e.g., 'p1', 'p2') as the patient identifier
    // so messages are routed to the correct patient.
    _otherUserId = widget.conversation.id;
    _otherUserType = 'patient';

    _webSocketService.connect(_currentUserId!, _currentUserType!);
    _webSocketService.addMessageListener(_handleIncomingMessage);

    // Register the conversation so it can be updated when messages are sent
    // Wrap in try-catch for web compatibility
    try {
      _webSocketService.registerConversation(widget.conversation);
    } catch (e) {
      // Silently handle registration errors (web compatibility)
    }
  }

  void _loadExistingMessages() {
    final existingMessages = _webSocketService.getMessages(
      _otherUserId!,
      _otherUserType!,
    );
    setState(() {
      _messages.addAll(existingMessages);
    });
  }

  void _handleIncomingMessage(Message message) {
    // Deduplicate incoming messages
    if (_messages.any((m) => m.id == message.id)) return;

    final currentId = _currentUserId;
    final otherId = _otherUserId;
    if (currentId == null || otherId == null) return;

    final bool isRelevant =
        (message.senderId == otherId && message.recipientId == currentId) ||
        (message.senderId == currentId && message.recipientId == otherId);

    if (isRelevant) {
      setState(() {
        _messages.add(message);
      });
    }
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _controller.text.trim(),
      senderId: _currentUserId ?? 'dr_ali_ahmed',
      senderName: 'Dr. Ali Ahmed',
      senderType: _currentUserType ?? 'doctor',
      timestamp: DateTime.now(),
      recipientId: _otherUserId,
      recipientType: _otherUserType,
    );

    _webSocketService.sendMessage(newMessage);

    // Update conversation's lastMessage and lastMessageTime for both participants
    // This ensures the last message shows up in everyone's chat list
    if (_currentUserId != null && _otherUserId != null) {
      _webSocketService.updateConversationLastMessage(
        conversationId: widget.conversation.id,
        senderId: _currentUserId!,
        recipientId: _otherUserId!,
        lastMessage: newMessage.text,
        lastMessageTime: newMessage
            .timestamp!, // timestamp is set to DateTime.now() so it's safe
      );
    }

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _webSocketService.removeMessageListener(_handleIncomingMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildChatAppBar(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputComposer(),
        ],
      ),
    );
  }

  AppBar _buildChatAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          Stack(
            children: [
              ClipOval(
                // Handle nullable patientImageUrl by providing a fallback
                child: widget.conversation.patientImageUrl != null
                    ? Image.network(
                        widget.conversation.patientImageUrl!,
                        fit: BoxFit.cover,
                        width: 45,
                        height: 45,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person_rounded,
                              color: kPrimaryColor,
                              size: 40,
                            ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: kPrimaryColor,
                        size: 40,
                      ),
              ),
              if (widget.conversation.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.conversation.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.conversation.specialty ?? 'Patient',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Message message) {
    final bool isMe = message.senderType == 'doctor';

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipOval(
              // Handle nullable patientImageUrl
              child: widget.conversation.patientImageUrl != null
                  ? Image.network(
                      widget.conversation.patientImageUrl!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, color: kPrimaryColor),
                    )
                  : const Icon(Icons.person, color: kPrimaryColor),
            ),
          ),

        Flexible(
          child: Container(
            margin: EdgeInsets.only(
              top: 5.0,
              bottom: 5.0,
              left: isMe ? 60.0 : 0,
              right: isMe ? 0 : 60.0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: isMe ? kPrimaryColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: isMe
                    ? const Radius.circular(20.0)
                    : const Radius.circular(5.0),
                bottomRight: isMe
                    ? const Radius.circular(5.0)
                    : const Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // Handle nullable timestamp
                  '${message.timestamp?.hour ?? ''}:${message.timestamp?.minute.toString().padLeft(2, '0') ?? ''}',
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isMe)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[600]),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: kBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            child: FloatingActionButton(
              onPressed: _handleSend,
              backgroundColor: kPrimaryColor,
              elevation: 0,
              mini: true,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
