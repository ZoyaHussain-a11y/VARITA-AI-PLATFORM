import 'package:flutter/material.dart';
import 'patient_appointments_screen.dart';
import 'patient_appointment_history_screen.dart';
import 'find_doctor_screen.dart';
import 'PatientMessageScreen.dart';
import 'login_screen.dart';
import 'patient_settings_screen.dart';
import 'PatientMedicalRecordsScreen.dart';

// --- CONSTANTS AND COLORS ---
const Color kPrimaryBlue = Color(0xFF279FF4);
const Color kHeaderBlue = Color(0xFF1E88E5);
const Color kLightGrey = Color(0xFFF7F7F7);
const Color kBorderColor = Color(0xFFDDDDDD);
const Color kDarkText = Color(0xFF333333);

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, String destination) {
    if (destination == 'Upcoming Appointments') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PatientAppointmentsScreen(),
        ),
      );
    } else if (destination == 'Appointments History') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PatientAppointmentHistoryScreen(),
        ),
      );
    } else if (destination == 'Find Your Doctor' ||
        destination == 'Schedule Appointment') {
      // FIXED: Both "Find Your Doctor" card and "Schedule Appointment" button go to FindDoctorScreen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const FindDoctorScreen()));
    } else if (destination == 'Messages') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PatientMessageScreen()),
      );
    } else if (destination == 'Medical History') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PatientMedicalRecordsScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action: $destination'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: kPrimaryBlue.withOpacity(0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30.0,
                ),
                children: [
                  _buildActionListItem(
                    context,
                    title: 'Upcoming Appointments',
                    subtitle: 'Your next appointments',
                    icon: Icons.calendar_today_outlined,
                    destination: 'Upcoming Appointments',
                  ),
                  const SizedBox(height: 20),
                  _buildActionListItem(
                    context,
                    title: 'Appointments History',
                    subtitle: 'All scheduled appointments',
                    icon: Icons.menu_book_outlined,
                    destination: 'Appointments History',
                  ),
                  const SizedBox(height: 20),
                  _buildActionListItem(
                    context,
                    title: 'Find Your Doctor',
                    subtitle: 'Find your specialist doctor',
                    icon: Icons.medical_services_outlined,
                    destination: 'Find Your Doctor',
                  ),
                  const SizedBox(height: 20),
                  _buildActionListItem(
                    context,
                    title: 'Medical History',
                    subtitle: 'Your medical history details',
                    icon: Icons.menu_book_outlined,
                    destination: 'Medical History',
                  ),
                  const SizedBox(height: 20),
                  _buildActionListItem(
                    context,
                    title: 'Messages',
                    subtitle: 'All your messages',
                    icon: Icons.chat_bubble_outlined,
                    destination: 'Messages',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String destination,
  }) {
    return InkWell(
      onTap: () => _handleNavigation(context, destination),
      borderRadius: BorderRadius.circular(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: kPrimaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: kPrimaryBlue, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: kBorderColor, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        20,
        horizontalPadding,
        20,
      ),
      decoration: const BoxDecoration(
        color: kHeaderBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 25),
                Text(
                  'Hi John',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your health, our top priority',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Profile Picture with Popup Menu - USING DOCTOR IMAGE AS FALLBACK
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'settings') {
                    _navigateToSettings(context);
                  } else if (value == 'logout') {
                    _handleLogout(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.black87),
                        SizedBox(width: 10),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(child: _buildProfileImage()),
                ),
              ),
              const SizedBox(height: 35),
              InkWell(
                onTap: () => _handleNavigation(context, 'Schedule Appointment'),
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8, right: 8),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: kHeaderBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Schedule Appointment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SIMPLIFIED PROFILE IMAGE BUILDER - Using doctor image directly
  Widget _buildProfileImage() {
    return Image.asset(
      'assets/images/patient_profile.jpg', // Using the doctor image that we know exists
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Final fallback: Use a colored container with icon
        return Container(
          color: kHeaderBlue.withOpacity(0.8),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        );
      },
    );
  }
}
