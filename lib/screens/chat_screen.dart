// screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/websocket_service.dart';
import '../models/conversation.dart';
import '../services/voice_message_service.dart';

// Reuse constants from the dashboard
const Color kPrimaryColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kOnlineColor = Color(0xFF1ABC9C);

// Colors from the chat image
const Color kPatientBubbleColor = Color(0xFFE3F2FD);
const Color kDoctorBubbleColor = Color(0xFF0D84FF);

// Profile images
const String kDoctorImageUrl =
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const String kPatientImageUrl =
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final bool isDoctor;

  const ChatScreen({
    super.key,
    required this.conversation,
    this.isDoctor = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final WebSocketService _webSocketService = WebSocketService();
  final VoiceMessageService _voiceService = VoiceMessageService();
  final List<Message> _messages = [];
  bool _isRecording = false;
  String? _currentUserId;
  String? _currentUserType;
  String? _otherUserId;
  String? _otherUserType;
  bool get _isTyping => _textController.text.trim().isNotEmpty;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _loadExistingMessages();
    _initializeVoiceService();
    _webSocketService.markConversationAsRead(
      widget.conversation.id,
    ); // Mark as read on open
  }

  void _initializeVoiceService() async {
    bool initialized = await _voiceService.initialize();
    if (!initialized) {
      print('Voice service initialization failed');
    }
  }

  void _initializeWebSocket() {
    _currentUserId = widget.isDoctor ? 'dr_ali_ahmed' : 'patient_john';
    _currentUserType = widget.isDoctor ? 'doctor' : 'patient';
    _otherUserId = widget.conversation.id;
    _otherUserType = widget.isDoctor ? 'patient' : 'doctor';

    _webSocketService.connect(_currentUserId!, _currentUserType!);
    _webSocketService.addMessageListener(_handleIncomingMessage);

    try {
      _webSocketService.registerConversation(widget.conversation);
    } catch (e) {
      // Silently handle registration errors
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
    _scrollToBottom();
  }

  void _handleIncomingMessage(Message message) {
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
      _scrollToBottom();

      // When an incoming message from the other user is handled,
      // ensure the conversation is marked as read. This is more reliable
      // than doing it only on initState.
      if (message.senderId == otherId) {
        _webSocketService.markConversationAsRead(widget.conversation.id);
      }
    }
  }

  void _sendMessage({
    String? message,
    bool isVoice = false,
    bool isAttachment = false,
  }) {
    if (message == null && !isVoice && !isAttachment) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          message ??
          (isVoice ? 'Voice Note (0:05)' : 'File Attachment (Report.pdf)'),
      senderId:
          _currentUserId ?? (widget.isDoctor ? 'dr_ali_ahmed' : 'patient_john'),
      senderName: widget.isDoctor ? 'Dr. Ali Ahmed' : widget.conversation.name,
      senderType: _currentUserType ?? (widget.isDoctor ? 'doctor' : 'patient'),
      timestamp: DateTime.now(),
      isVoiceNote: isVoice,
      isAttachment: isAttachment,
      recipientId: _otherUserId,
      recipientType: _otherUserType,
    );

    _webSocketService.sendMessage(newMessage);

    if (_currentUserId != null && _otherUserId != null) {
      _webSocketService.updateConversationLastMessage(
        conversationId: widget.conversation.id,
        senderId: _currentUserId!,
        recipientId: _otherUserId!,
        lastMessage: newMessage.text,
        lastMessageTime: newMessage.timestamp!,
      );
    }

    if (!isVoice && !isAttachment) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  void _handleSendText() {
    if (_isTyping) {
      _sendMessage(message: _textController.text.trim());
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      String recognizedText = await _voiceService.stopListening();
      setState(() {
        _isRecording = false;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      String finalText = _voiceService.recognizedText.trim();
      String textToSend = finalText.isNotEmpty
          ? finalText
          : recognizedText.trim();
      if (textToSend.isNotEmpty) {
        _sendMessage(message: textToSend);
      }
    } else {
      await _voiceService.startListening();
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _handleAttachmentClick(String type) {
    if (type == 'File/Document') {
      _sendMessage(isAttachment: true, message: 'Attached Lab Report (PDF)');
    } else if (type == 'Camera/Image') {
      _sendMessage(isAttachment: true, message: 'Attached Image (X-Ray Scan)');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _voiceService.dispose();
    _webSocketService.removeMessageListener(_handleIncomingMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            margin: const EdgeInsets.only(right: 10),
            child: ClipOval(
              child: widget.isDoctor
                  ? Image.network(
                      kPatientImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        color: kPrimaryColor,
                        size: 30,
                      ),
                    )
                  : Image.network(
                      kDoctorImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        color: kPrimaryColor,
                        size: 30,
                      ),
                    ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.conversation.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.conversation.isOnline
                          ? kOnlineColor
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.conversation.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.conversation.isOnline
                          ? kOnlineColor
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[300], height: 1.0),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isDoctorMessage = message.senderType == 'doctor';
    final isCurrentUser =
        (widget.isDoctor && isDoctorMessage) ||
        (!widget.isDoctor && !isDoctorMessage);

    final String imageUrl = isDoctorMessage
        ? kDoctorImageUrl
        : kPatientImageUrl;
    final Color bubbleColor = isDoctorMessage
        ? kDoctorBubbleColor
        : kPatientBubbleColor;
    final Color textColor = isDoctorMessage ? Colors.white : Colors.black87;

    Widget messageContent;

    if (message.isVoiceNote) {
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill,
            color: isDoctorMessage ? Colors.white : kPrimaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            message.text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (message.isAttachment) {
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.file_present,
            color: isDoctorMessage ? Colors.white : kPrimaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    } else {
      messageContent = Text(
        message.text,
        style: TextStyle(color: textColor, fontSize: 15),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 20),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person_rounded,
                    color: kPrimaryColor,
                    size: 30,
                  ),
                ),
              ),
            ),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(20)
                      : const Radius.circular(5),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(5)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  messageContent,
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp?.hour ?? ''}:${message.timestamp?.minute.toString().padLeft(2, '0') ?? ''}',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 20),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person_rounded,
                    color: kPrimaryColor,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: _isRecording
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, color: kPrimaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Recording... Tap to stop",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TextField(
                      controller: _textController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                    ),
            ),
          ),

          if (!_isRecording) ...[
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: () => _handleAttachmentClick('File/Document'),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
              onPressed: () => _handleAttachmentClick('Camera/Image'),
            ),
          ],

          Container(
            margin: const EdgeInsets.only(left: 5),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isRecording
                    ? Icons.stop
                    : (_isTyping ? Icons.send : Icons.mic),
                color: Colors.white,
              ),
              onPressed: () {
                if (_isRecording) {
                  _toggleRecording();
                } else if (_isTyping) {
                  _handleSendText();
                } else {
                  _toggleRecording();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
