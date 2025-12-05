import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/websocket_service.dart';
import 'chat_screen.dart';
import 'total_patients_screen.dart'; // For navigation to patients list
import 'upcoming_appointments_screen.dart'; // For appointments navigation
import 'critical_cases_screen.dart'; // For critical cases navigation
import 'doctor_dashboard.dart'; // For dashboard navigation

// Reuse constants from the dashboard
const Color kCardColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kPrimaryColor = kCardColor;
const Color kOnlineColor = Color(0xFF1ABC9C);

// Profile images
const String kDoctorImageUrl =
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b177?q=80&w=100&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const String kPatientImageUrl =
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String _searchQuery = '';
  final WebSocketService _webSocketService = WebSocketService();

  List<Conversation> _conversations = [
    Conversation(
      id: 'patient_john',
      name: 'John Patient',
      lastMessage: 'Hello doctor, I have a question about my prescription',
      avatarUrl:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop',
      isOnline: true,
      unreadCount: 2,
      patientImageUrl:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=100&auto=format&fit=crop',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Conversation(
      id: 'patient_sarah',
      name: 'Sarah Williams',
      lastMessage: 'Thank you for the consultation!',
      avatarUrl:
          'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
      isOnline: false,
      unreadCount: 0,
      patientImageUrl:
          'https://images.unsplash.com/photo-1557862921-37829c790f19?q=80&w=100&auto=format&fit=crop',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Conversation(
      id: 'patient_michael',
      name: 'Michael Brown',
      lastMessage: 'When should I schedule my next appointment?',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
      isOnline: true,
      unreadCount: 1,
      patientImageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Conversation(
      id: 'patient_lisa',
      name: 'Lisa Anderson',
      lastMessage: 'Okay, I will check the results.',
      avatarUrl:
          'https://images.unsplash.com/photo-1579549320290-7d12ec3d56d4?q=80&w=100&auto=format&fit=crop',
      isOnline: false,
      unreadCount: 1,
      patientImageUrl:
          'https://images.unsplash.com/photo-1579549320290-7d12ec3d56d4?q=80&w=100&auto=format&fit=crop',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Conversation(
      id: 'patient_khadija',
      name: 'Khadija Ahmed',
      lastMessage:
          'Thank you, doctor! I will check the report and let you know.',
      avatarUrl:
          'https://images.unsplash.com/photo-1594958043694-81498b89d53f?q=80&w=100&auto=format&fit=crop',
      isOnline: true,
      unreadCount: 2,
      patientImageUrl:
          'https://images.unsplash.com/photo-1594958043694-81498b89d53f?q=80&w=100&auto=format&fit=crop',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Register all conversations with WebSocketService
    for (var conv in _conversations) {
      _webSocketService.registerConversation(conv);
    }
    // Listen for conversation updates
    _webSocketService.addConversationListener(_handleConversationUpdate);
  }

  @override
  void dispose() {
    _webSocketService.removeConversationListener(_handleConversationUpdate);
    super.dispose();
  }

  void _handleConversationUpdate(Conversation updatedConversation) {
    // Find and update the conversation in the list
    final index = _conversations.indexWhere(
      (conv) => conv.id == updatedConversation.id,
    );
    if (index != -1) {
      setState(() {
        _conversations[index] = updatedConversation;
        // Sort by lastMessageTime (newest first)
        _conversations.sort((a, b) {
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
      });
    }
  }

  List<Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conv) {
      return conv.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _openChat(Conversation conversation) {
    // Mark as read when opening chat
    _webSocketService.markConversationAsRead(conversation.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(conversation: conversation, isDoctor: true),
      ),
    ).then((_) {
      // Refresh when returning from chat
      setState(() {});
    });
  }

  // --- Navigation Handlers for Bottom Nav Bar ---
  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DoctorDashboardScreen()),
    );
  }

  void _navigateToAppointments() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UpcomingAppointmentsScreen(),
      ),
    );
  }

  void _navigateToPatients() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TotalPatientsScreen()),
    );
  }

  void _navigateToCriticalCases() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CriticalCasesScreen()),
    );
  }
  // --- End Navigation Handlers ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavBar(),
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 0),
              itemCount: _filteredConversations.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                return _buildConversationTile(_filteredConversations[index]);
              },
            ),
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
                'Messages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                onPressed: () {},
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
              hintText: 'Search conversations',
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
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child:
                        conversation.avatarUrl != null &&
                            conversation.avatarUrl!.isNotEmpty
                        ? Image.network(
                            conversation.avatarUrl!,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    conversation.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    conversation.lastMessage ?? '',
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
        currentIndex: 2, // Messages is active (index 2)
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateToDashboard();
              break;
            case 1:
              _navigateToAppointments();
              break;
            case 2:
              // Already on Messages screen, do nothing
              break;
            case 3:
              _navigateToCriticalCases();
              break;
          }
        },
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
            icon: Icon(Icons.medical_services_outlined),
            label: 'Critical Cases',
          ),
        ],
      ),
    );
  }
}
