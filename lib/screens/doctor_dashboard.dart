// File: doctor_dashboard.dart (FINAL CORRECTED FOR VOICE INTEGRATION)

import 'package:flutter/material.dart';
import 'total_patients_screen.dart';
import 'critical_cases_screen.dart';
import 'calendar_screen.dart';
import 'message_screen.dart';
import 'upcoming_appointments_screen.dart';
import 'call_center_screen.dart';
import 'login_screen.dart'; // Import your login screen
import 'doctor_settings_screen.dart'; // Import your settings screen
// --- START VOICE INTEGRATION ---
// Corrected import to use the final, reusable class name
import 'recorder_session_screen.dart'; // <--- CHANGED IMPORT
// --- END VOICE INTEGRATION ---


// --- CONSTANTS AND COLORS (For a professional and consistent look) ---
const Color kCardColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  // Handle Settings Navigation
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  // Handle Logout - Direct navigation without any messages
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
                // Close dialog and navigate directly to login
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

  // --- START VOICE INTEGRATION ---
  // New handler for Walk-in Patient Session (Point 2)
  void _handleStartWalkinSession(BuildContext context) {
    // In a real app, you would handle patient lookup, fee payment, and session start logic here.
    Navigator.push(
      context,
      MaterialPageRoute(
        // Use the consistent RecorderSessionScreen class, which takes no arguments
        builder: (context) => const RecorderSessionScreen(), // <--- CHANGED CLASS AND REMOVED ARGUMENTS
      ),
    );
  }
  // --- END VOICE INTEGRATION ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- Custom Header Section ---
            _buildCustomHeader(context),

            // --- Dashboard Grid ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDashboardGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  // Header Widget with doctor image on right side
  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 30, // Increased from 10 to 20
        bottom: 50, // Increased from 30 to 40
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: kHeaderColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Text content only
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 15),
                const Text(
                  'Welcome back, Dr. Ali Ahmed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Increased from 20 to 22
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "What's happening today for you",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16, // Increased from 15 to 16
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right side: Doctor Image with functional popup menu
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: PopupMenuButton<String>(
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
                width: 85, // Increased from 80 to 85
                height: 85, // Increased from 80 to 85
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
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/doctor_profile.png.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: kCardColor.withOpacity(0.8),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // GridView Widget with smaller boxes and desired content order
  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85, // Changed from 0.95 to 0.85 (smaller cards)
      children: [
        _buildStatCard(
          context: context,
          title: 'Total Patients',
          count: '249',
          subtitle: '+12 this week',
          icon: Icons.groups_2_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TotalPatientsScreen(),
              ),
            );
          },
        ),
        _buildStatCard(
          context: context,
          title: "Today's Appointments",
          count: '9',
          subtitle: '5 Pending',
          icon: Icons.event_available_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UpcomingAppointmentsScreen(),
              ),
            );
          },
        ),

        // --- START VOICE INTEGRATION: NEW WALK-IN CARD ---
        _buildStatCard(
          context: context,
          title: 'Start Walk-in Session',
          count: 'Start Now',
          subtitle: 'Runtime Consultation',
          icon: Icons.record_voice_over, // Relevant icon for session/voice
          onTap: () => _handleStartWalkinSession(context), // New handler
        ),
        // --- END VOICE INTEGRATION: NEW WALK-IN CARD ---

        _buildStatCard(
          context: context,
          title: 'Critical Cases',
          count: '3',
          subtitle: 'Requires attention',
          icon: Icons.warning_amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CriticalCasesScreen(),
              ),
            );
          },
        ),
        _buildStatCard(
          context: context,
          title: 'Messages',
          count: '10',
          subtitle: 'New messages',
          icon: Icons.message_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessageScreen()),
            );
          },
        ),
        _buildStatCard(
          context: context,
          title: 'Calendar',
          count: 'View',
          subtitle: 'Schedules',
          icon: Icons.calendar_month,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          },
        ),
        _buildStatCard(
          context: context,
          title: 'Call Center',
          count: '12',
          subtitle: 'Calls Pending',
          icon: Icons.headset_mic,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CallCenterScreen()),
            );
          },
        ),
      ],
    );
  }

  // Stat Card Widget with content reordered as requested
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10), // Changed from 12 to 10
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Bigger Icon
            Container(
              padding: const EdgeInsets.all(12), // Changed from 14 to 12
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ), // Changed from 34 to 30
            ),
            const SizedBox(height: 8), // Reduced from 10 to 8
            // 2. Title (Heading)
            Text(
              title,
              style: const TextStyle(
                fontSize: 13, // Reduced from 14 to 13
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),

            const SizedBox(height: 4),

            // 3. Count/Number
            Text(
              count,
              style: const TextStyle(
                fontSize: 22, // Reduced from 24 to 22
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // 4. Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11, // Reduced from 12 to 11
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}