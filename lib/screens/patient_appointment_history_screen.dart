// patient_appointment_history_screen.dart
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import 'consultation_summary_screen.dart'; // Add this import

// Color constants matching the image
const Color kPrimaryBlue = Color(0xFF007BFF); // Main header/button color
const Color kHeaderBlue = Color(0xFF007BFF);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF0F0F0); // Background color
const Color kCardBackground = Colors.white;

class PatientAppointmentHistoryScreen extends StatefulWidget {
  const PatientAppointmentHistoryScreen({super.key});

  @override
  State<PatientAppointmentHistoryScreen> createState() =>
      _PatientAppointmentHistoryScreenState();
}

class _PatientAppointmentHistoryScreenState extends State<PatientAppointmentHistoryScreen> {
  String _searchQuery = '';
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _appointmentService.addListener(_loadAppointments);
  }

  @override
  void dispose() {
    _appointmentService.removeListener(_loadAppointments);
    super.dispose();
  }

  void _loadAppointments() {
    // FUNCTIONALITY: Load appointments from service
    setState(() {
      _appointments = _appointmentService.getPatientHistoryAppointments();
    });
  }

  // NOTE: HistoryAppointment is assumed to be defined/derived from the base Appointment model
  // based on the original code's structure. Keeping this derivation structure.
  List<HistoryAppointment> get _allHistory {
    return _appointments.map((appointment) {
      return HistoryAppointment(
        date: appointment.date,
        doctorName: appointment.doctorName,
        specialty: appointment.doctorSpecialty,
        hospital: appointment.hospital,
        // The original code uses internal logic to derive condition/diagnosis from status,
        // which maintains the functionality.
        condition: _getConditionFromStatus(appointment.status),
        imageUrl: appointment.doctorImage,
        notes: appointment.notes ?? 'Consultation Completed',
        diagnosis: _getDiagnosisFromStatus(appointment.status),
        medication: const [],
        nextSteps: _getNextStepsFromStatus(appointment.status),
        time: appointment.time,
        status: appointment.status,
        patientName: appointment.patientName,
        patientEmail: appointment.patientEmail,
        symptoms: appointment.symptoms,
      );
    }).toList();
  }

  // FUNCTIONALITY: Status mapping functions (UNCHANGED)
  String _getConditionFromStatus(String status) {
    switch (status) {
      case 'pending': return 'Appointment Requested';
      case 'accepted': return 'Appointment Confirmed';
      case 'rejected': return 'Appointment Cancelled';
      case 'completed': return 'Consultation Completed';
      default: return 'Appointment';
    }
  }

  List<String> _getDiagnosisFromStatus(String status) {
    switch (status) {
      case 'completed': return ['General Checkup', 'Routine Consultation'];
      case 'accepted': return ['Scheduled for consultation'];
      case 'rejected': return ['Appointment not available'];
      default: return ['Pending doctor confirmation'];
    }
  }

  String _getNextStepsFromStatus(String status) {
    switch (status) {
      case 'pending': return 'Waiting for doctor confirmation';
      case 'accepted': return 'Prepare for your appointment';
      case 'rejected': return 'Please schedule another appointment';
      case 'completed': return 'Follow up if needed';
      default: return 'No further steps';
    }
  }

  // FUNCTIONALITY: Search/Filter (UNCHANGED)
  List<HistoryAppointment> get _filteredHistory {
    if (_searchQuery.isEmpty) {
      // Sort by date descending (most recent first) to match the image order
      final sortedHistory = List<HistoryAppointment>.from(_allHistory);
      sortedHistory.sort((a, b) => b.date.compareTo(a.date));
      return sortedHistory;
    }
    final query = _searchQuery.toLowerCase();
    return _allHistory.where((appointment) {
      return appointment.doctorName.toLowerCase().contains(query) ||
          appointment.specialty.toLowerCase().contains(query) ||
          appointment.condition.toLowerCase().contains(query);
    }).toList();
  }

  // FUNCTIONALITY: Navigate to Consultation Summary Screen
  void _navigateToConsultationSummary(HistoryAppointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationSummaryScreen(appointment: appointment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      // 1. Custom App Bar to match the image's blue header and style
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: kHeaderBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Appointments History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          // 2. Custom Search Bar styled to match the image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Reduced vertical padding
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search your appointment...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  // Extremely rounded corners to match the visual style
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredHistory.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No appointment history',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your appointment history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(_filteredHistory[index]);
              },
            ),
          ),
          // Placeholder for Bottom Navigation Bar to complete the look
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  // 3. Updated History Item Card to match the image's structure
  Widget _buildHistoryItem(HistoryAppointment appointment) {

    // Helper function to format date (e.g., 'Nov 24, 2025')
    String formatDate(DateTime date) {
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
      return '$month ${date.day}, ${date.year}';
    }

    // Helper to get doctor specialty/issue text (for the third line)
    String getIssueText(HistoryAppointment appointment) {
      // Logic to mimic the image text: "Rash Consultation", "Heart Issue", "Skin Issue"
      if (appointment.specialty.contains('Pediatrician')) return 'Rash Consultation';
      if (appointment.specialty.contains('Cardiologist')) return 'Heart Issue';
      if (appointment.specialty.contains('Dermatologist')) return 'Skin Issue';
      return appointment.condition;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Date (top left)
            Text(
              formatDate(appointment.date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 10),

            // Row 2: Doctor Image, Details, and Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Doctor Image (smaller, rectangular-like rounded corners)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for image
                  child: Image.asset(
                    appointment.imageUrl,
                    width: 70, // Matched size in image
                    height: 70, // Matched size in image
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: kLightGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.grey, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),

                // Doctor Details (Middle Section)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        // Display hospital or other detail
                        '${appointment.hospital} | ${getIssueText(appointment)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Consultation Summary Button (Right Section) - NOW CLICKABLE
                GestureDetector(
                  onTap: () => _navigateToConsultationSummary(appointment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: kPrimaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Consultation Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Note: The image simplifies the display, removing the status badge and extra details.
            // Keeping only the essential information to match the visual.
          ],
        ),
      ),
    );
  }

  // 4. Placeholder Bottom Navigation Bar to complete the look
  Widget _buildBottomNavBar() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Dashboard', isSelected: false),
            _buildNavItem(Icons.calendar_month, 'Appointments', isSelected: false),
            _buildNavItem(Icons.send, 'Messages', isSelected: false),
            _buildNavItem(Icons.menu_book, 'Medical Records', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? kPrimaryBlue : Colors.grey.shade600,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? kPrimaryBlue : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}