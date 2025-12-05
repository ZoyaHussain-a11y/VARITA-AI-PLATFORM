import 'package:flutter/material.dart';
import 'message_screen.dart';
import 'upcoming_appointments_screen.dart';
import 'doctor_dashboard.dart';
import 'critical_cases_screen.dart';

// 🎨 Theme Constants
const Color kCardColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kPrimaryColor = kCardColor;

// 🧑‍⚕️ Static Patient Data Model
class Patient {
  final String name;
  final String date;
  final String imageUrl;
  final String phoneNumber;
  final bool isFavorite;

  Patient({
    required this.name,
    required this.date,
    required this.imageUrl,
    required this.phoneNumber,
    this.isFavorite = false,
  });

  Patient copyWith({
    String? name,
    String? date,
    String? imageUrl,
    String? phoneNumber,
    bool? isFavorite,
  }) {
    return Patient(
      name: name ?? this.name,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// 📋 Initialize Patients List
List<Patient> getStaticPatients() {
  return [
    Patient(
      name: 'Fatima Ali',
      date: '24 Nov, 2025',
      imageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1234567890',
    ),
    Patient(
      name: 'Sarah Williams',
      date: '21 Nov, 2025',
      imageUrl:
          'https://images.unsplash.com/photo-1594824947933-d0501ba2fe65?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1234567891',
      isFavorite: true,
    ),
    Patient(
      name: 'Jane Smith',
      date: '21 Dec, 2024',
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1234567892',
    ),
    Patient(
      name: 'Mohammed Khan',
      date: '10 Jan, 2025',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1234567893',
      isFavorite: true,
    ),
    Patient(
      name: 'David Lee',
      date: '05 Mar, 2025',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
      phoneNumber: '+1234567894',
    ),
  ];
}

// 🏥 TotalPatientsScreen
class TotalPatientsScreen extends StatefulWidget {
  const TotalPatientsScreen({super.key});

  @override
  State<TotalPatientsScreen> createState() => _TotalPatientsScreenState();
}

class _TotalPatientsScreenState extends State<TotalPatientsScreen> {
  String activeTab = 'All Patients';
  final TextEditingController _searchController = TextEditingController();
  List<Patient> filteredPatients = [];
  List<Patient> allPatients = [];

  @override
  void initState() {
    super.initState();
    allPatients = getStaticPatients();
    filteredPatients = List.from(allPatients);
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      List<Patient> baseList = allPatients
          .where((patient) => patient.name.toLowerCase().contains(query))
          .toList();

      if (activeTab == 'Favorites') {
        filteredPatients = baseList.where((p) => p.isFavorite).toList();
      } else if (activeTab == 'Recent Chats') {
        filteredPatients = baseList
            .where((p) => p.date.contains('2025'))
            .toList();
      } else {
        filteredPatients = baseList;
      }
    });
  }

  void _toggleFavorite(Patient patient) {
    setState(() {
      final index = allPatients.indexWhere((p) => p.name == patient.name);
      if (index != -1) {
        allPatients[index] = patient.copyWith(isFavorite: !patient.isFavorite);
        _filterPatients();
      }
    });
  }

  void _makePhoneCall(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Call Patient"),
        content: Text("Calling: $phoneNumber"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Calling $phoneNumber...")),
              );
            },
            child: const Text("Call"),
          ),
        ],
      ),
    );
  }

  // Navigation
  void _navigateToAppointments() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UpcomingAppointmentsScreen()),
    );
  }

  void _navigateToCriticalCases() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CriticalCasesScreen()),
    );
  }

  void _navigateToMessages() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MessageScreen()),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _buildPatientHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 15),
                    child: Text(
                      "My Patients",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (filteredPatients.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredPatients.map(
                      (p) => PatientListItem(
                        patient: p,
                        onCall: () => _makePhoneCall(p.phoneNumber),
                        onChat: () => _showChatMessage(p),
                        onFavorite: () => _toggleFavorite(p),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  void _showChatMessage(Patient patient) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Chat with ${patient.name}")));
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: kPrimaryColor, size: 24),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Ali Ahmed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Pediatrician',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Patients',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildSearchBar(),
          const SizedBox(height: 15),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Search Patients",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabButton("All Patients"),
        _buildTabButton("Recent Chats"),
        _buildTabButton("Favorites"),
      ],
    );
  }

  Widget _buildTabButton(String title) {
    bool isActive = activeTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeTab = title;
          _filterPatients();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? kPrimaryColor : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true, // This line fixes the issue
      onTap: (index) {
        switch (index) {
          case 0:
            _navigateToDashboard();
            break;
          case 1:
            _navigateToAppointments();
            break;
          case 2:
            _navigateToMessages();
            break;
          case 3:
            _navigateToCriticalCases();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Appointments",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.send), label: "Messages"),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: "Critical Cases",
        ),
      ],
    );
  }
}

// 📝 Patient List Item
class PatientListItem extends StatelessWidget {
  final Patient patient;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onFavorite;

  const PatientListItem({
    super.key,
    required this.patient,
    required this.onCall,
    required this.onChat,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: kPrimaryColor.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  patient.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, color: kPrimaryColor),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          kPrimaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    patient.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Favorite
            IconButton(
              icon: Icon(
                patient.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: patient.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavorite,
            ),

            // Call
            IconButton(
              icon: const Icon(Icons.call, color: kPrimaryColor),
              onPressed: onCall,
            ),

            // Chat
            IconButton(
              icon: const Icon(Icons.message, color: Colors.blue),
              onPressed: onChat,
            ),
          ],
        ),
      ),
    );
  }
}
