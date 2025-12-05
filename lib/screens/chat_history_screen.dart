// screens/chat_history_screen.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/websocket_service.dart';
import '../models/conversation.dart';
import 'chat_screen.dart';

// Reuse constants from the dashboard
const Color kPrimaryColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kOnlineColor = Color(0xFF1ABC9C);
const String kDoctorImageUrl =
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const String kPatientImageUrl =
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  String _searchQuery = '';
  bool _isLoading = false;
  final WebSocketService _webSocketService = WebSocketService();
  List<Conversation> _conversations = [];
  String? _activeConversationId;

  @override
  void initState() {
    super.initState();
    _initializeConversations();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Connect as doctor
    _webSocketService.connect('dr_ali_ahmed', 'doctor');

    // Listen for conversation updates
    _webSocketService.addConversationListener(_handleConversationUpdate);

    // Listen for incoming messages
    // _webSocketService.addMessageListener(_handleIncomingMessage); // This is now redundant
  }

  void _initializeConversations() {
    final existingConversations = _webSocketService.getAllConversations();
    if (existingConversations.isEmpty) {
      // If the service has no conversations, populate it with initial mock data.
      final initialConversations = [
        Conversation(
          id: 'patient_john',
          name: 'John Patient',
          patientImageUrl: kPatientImageUrl,
          isOnline: true,
          lastMessage: 'Hello doctor, I have a question about my prescription',
          unreadCount: 2, // Example unread count
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Conversation(
          id: 'patient_sarah',
          name: 'Sarah Williams',
          patientImageUrl:
              'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
          isOnline: false,
          lastMessage: 'Thank you for the consultation!',
          unreadCount: 0,
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Conversation(
          id: 'patient_michael',
          name: 'Michael Brown',
          patientImageUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
          isOnline: true,
          lastMessage: 'When should I schedule my next appointment?',
          unreadCount: 1, // Example unread count
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
      for (var conv in initialConversations) {
        _webSocketService.registerConversation(conv);
      }
      _conversations = initialConversations;
    } else {
      // Sort to ensure the most recent are at the top.
      _conversations.sort(
        (a, b) => (b.lastMessageTime ?? DateTime(1970)).compareTo(
          a.lastMessageTime ?? DateTime(1970),
        ),
      );
    }
  }

  void _handleConversationUpdate(Conversation updatedConversation) {
    setState(() {
      final index = _conversations.indexWhere(
        (conv) => conv.id == updatedConversation.id,
      );

      if (index != -1) {
        // If conversation exists, remove it to re-insert at the top.
        _conversations.removeAt(index);
      }
      // Insert the updated (or new) conversation at the beginning of the list.
      _conversations.insert(0, updatedConversation);

      // The list is now naturally sorted by recent activity.
    });
  }

  List<Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conv) {
      return conv.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (conv.lastMessage ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  void _openChat(Conversation conversation) {
    _activeConversationId = conversation.id;
    _markConversationAsRead(conversation.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(conversation: conversation, isDoctor: true),
      ),
    ).then((_) {
      _activeConversationId = null;
      setState(() {});
    });
  }

  void _markConversationAsRead(String conversationId) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }
    });

    _webSocketService.markConversationAsRead(conversationId);
  }

  void _markAllAsRead() {
    setState(() {
      _conversations = _conversations
          .map((c) => c.copyWith(unreadCount: 0))
          .toList();
      for (var conversation in _conversations) {
        _webSocketService.markConversationAsRead(conversation.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All conversations marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _webSocketService.removeConversationListener(_handleConversationUpdate);
    // _webSocketService.removeMessageListener(_handleIncomingMessage); // No longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : _filteredConversations.isEmpty
                ? _buildEmptyState()
                : _buildConversationList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewConversationDialog,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.grey[400], size: 80),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new conversation with a patient',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showNewConversationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Start Conversation',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewConversationDialog() {
    final mockPatients = [
      {
        'id': 'patient_khadija',
        'name': 'Khadija Ahmed',
        'image':
            'https://images.unsplash.com/photo-1594958043694-81498b89d53f?q=80&w=100&auto=format&fit=crop',
      },
      {
        'id': 'patient_jane',
        'name': 'Jane Smith',
        'image':
            'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Conversation'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: mockPatients.length,
            itemBuilder: (context, index) {
              final patient = mockPatients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(patient['image']!),
                ),
                title: Text(patient['name']!),
                onTap: () {
                  Navigator.pop(context);
                  _createNewConversation(
                    patient['id']!,
                    patient['name']!,
                    patient['image']!,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _createNewConversation(
    String patientId,
    String patientName,
    String patientImage,
  ) {
    final newConversation = Conversation(
      id: patientId,
      name: patientName,
      patientImageUrl: patientImage,
      isOnline: true,
      lastMessage: 'Conversation started',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );

    setState(() {
      _conversations.insert(0, newConversation);
    });

    _webSocketService.registerConversation(newConversation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started conversation with $patientName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Messages',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black, size: 28),
          onSelected: (value) {
            if (value == 'mark_all_read') {
              _markAllAsRead();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  Icon(Icons.mark_chat_read, color: kPrimaryColor),
                  SizedBox(width: 8),
                  Text('Mark all as read'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey[300], height: 1.0),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _isLoading = false);
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _filteredConversations.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFEEEEEE),
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) =>
            _buildConversationTile(_filteredConversations[index]),
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return InkWell(
      onTap: () => _openChat(conversation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: Colors.white,
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: conversation.patientImageUrl != null
                        ? Image.network(
                            conversation.patientImageUrl!,
                            fit: BoxFit.cover,
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
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: kOnlineColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(
                          conversation.lastMessageTime ?? DateTime.now(),
                        ),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (conversation.unreadCount > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  alignment: Alignment.center,
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conversation.unreadCount > 9
                        ? '9+'
                        : conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1)
      return 'Now';
    else if (difference.inHours < 1)
      return '${difference.inMinutes}m ago';
    else if (difference.inDays < 1)
      return '${difference.inHours}h ago';
    else if (difference.inDays < 7)
      return '${difference.inDays}d ago';
    else
      return '${time.day}/${time.month}/${time.year}';
  }
}
