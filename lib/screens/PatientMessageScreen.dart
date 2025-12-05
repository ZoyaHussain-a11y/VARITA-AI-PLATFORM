// screens/patient_message_screen.dart
import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/websocket_service.dart';
import 'chat_screen.dart';

// Reusing constants
const Color kPrimaryColor = Color(0xFF2196F3);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kOnlineColor = Color(0xFF1ABC9C);

// Profile images
const String kDoctorImageUrl =
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const String kPatientImageUrl =
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop';

class PatientMessageScreen extends StatefulWidget {
  const PatientMessageScreen({super.key});

  @override
  State<PatientMessageScreen> createState() => _PatientMessageScreenState();
}

class _PatientMessageScreenState extends State<PatientMessageScreen> {
  String _searchQuery = '';
  final WebSocketService _webSocketService = WebSocketService();
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _loadConversations();
  }

  void _initializeWebSocket() {
    // Connect as patient
    _webSocketService.connect('patient_john', 'patient');

    // Listen for conversation updates
    _webSocketService.addConversationListener(_handleConversationUpdate);
  }

  void _loadConversations() {
    // Load conversations from WebSocket service with duplicate removal
    final patientConversations = _webSocketService.getPatientConversations();

    if (patientConversations.isEmpty) {
      // Create initial hardcoded conversations if none exist
      _conversations = _getInitialDoctorConversations();
      // Register them with WebSocket service
      for (final conversation in _conversations) {
        _webSocketService.registerConversation(conversation);
      }
    } else {
      _conversations = _removeDuplicateConversations(patientConversations);
    }

    setState(() {});
  }

  List<Conversation> _getInitialDoctorConversations() {
    return [
      Conversation(
        id: 'dr_ali_ahmed',
        name: 'Dr. Ali Ahmed',
        specialty: 'Pediatrician',
        patientImageUrl: kDoctorImageUrl,
        avatarUrl: kDoctorImageUrl,
        isOnline: true,
        lastMessage: 'Hello, how can I help you today?',
        unreadCount: 1,
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Conversation(
        id: 'dr_emma_thompson',
        name: 'Dr. Emma Thompson',
        specialty: 'Cardiologist',
        patientImageUrl:
            'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
        avatarUrl:
            'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
        isOnline: false,
        lastMessage: 'Okay, I will see you in the clinic on Monday.',
        unreadCount: 0,
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Conversation(
        id: 'dr_david_martinez',
        name: 'Dr. David Martinez',
        specialty: 'Dermatologist',
        patientImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
        isOnline: true,
        lastMessage: 'The new cream should be applied twice daily.',
        unreadCount: 0,
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  void _handleConversationUpdate(Conversation updatedConversation) {
    // Only process if it's a doctor conversation
    if (updatedConversation.name.contains('Dr.') &&
        updatedConversation.specialty != null) {
      setState(() {
        // Check if we already have a conversation with this doctor name
        final existingIndex = _conversations.indexWhere(
          (conv) => conv.name == updatedConversation.name,
        );

        if (existingIndex != -1) {
          // UPDATE existing conversation - don't add new one
          _conversations[existingIndex] = updatedConversation;
        } else {
          // Only add if it's a new doctor (not duplicate)
          _conversations.insert(0, updatedConversation);
        }

        // Remove any duplicates by doctor name
        _conversations = _removeDuplicateConversations(_conversations);

        // Sort by last message time (newest first)
        _conversations.sort((a, b) {
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
      });
    }
  }

  // Function to remove duplicate conversations by doctor name
  List<Conversation> _removeDuplicateConversations(
    List<Conversation> conversations,
  ) {
    final Map<String, Conversation> uniqueConversations = {};

    for (final conversation in conversations) {
      // Use doctor name as key to ensure uniqueness
      final key = conversation.name.toLowerCase();
      if (!uniqueConversations.containsKey(key)) {
        uniqueConversations[key] = conversation;
      } else {
        // If duplicate found, keep the one with the latest message
        final existing = uniqueConversations[key]!;
        final existingTime = existing.lastMessageTime ?? DateTime(1970);
        final newTime = conversation.lastMessageTime ?? DateTime(1970);

        if (newTime.isAfter(existingTime)) {
          uniqueConversations[key] = conversation;
        }
      }
    }

    return uniqueConversations.values.toList();
  }

  List<Conversation> get _filteredConversations {
    // First remove any duplicates
    final uniqueConversations = _removeDuplicateConversations(_conversations);

    if (_searchQuery.isEmpty) {
      return uniqueConversations;
    }

    return uniqueConversations.where((conv) {
      return conv.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (conv.specialty ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (conv.lastMessage ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  void _openChat(Conversation conversation) {
    _webSocketService.markConversationAsRead(conversation.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(conversation: conversation, isDoctor: false),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _webSocketService.removeConversationListener(_handleConversationUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavBar(),
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: _filteredConversations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: _filteredConversations.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      return _buildConversationTile(
                        _filteredConversations[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            color: Colors.grey[400],
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'No doctors yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your conversations with doctors will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'My Doctors',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryColor, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    kPatientImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: kPrimaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search doctors',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: kBackgroundColor,
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
        ],
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return InkWell(
      onTap: () => _openChat(conversation),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: conversation.patientImageUrl != null
                        ? Image.network(
                            conversation.patientImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: kPrimaryColor.withOpacity(0.1),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: kPrimaryColor,
                                  size: 35,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: kPrimaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.person_rounded,
                              color: kPrimaryColor,
                              size: 35,
                            ),
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
                  Text(
                    conversation.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    conversation.specialty ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    conversation.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: conversation.unreadCount > 0
                          ? Colors.black87
                          : Colors.grey[700],
                      fontSize: 14,
                      fontWeight: conversation.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(conversation.lastMessageTime ?? DateTime.now()),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                if (conversation.unreadCount > 0)
                  Container(
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: 2,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Messages'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Medical Records',
          ),
        ],
      ),
    );
  }
}
