// lib/screens/patient_appointments_screen.dart
import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
import 'patient_calendar_screen.dart';
// --- START VOICE INTEGRATION ---
import 'recorder_session_screen.dart'; // <--- NEW IMPORT for session joining
// --- END VOICE INTEGRATION ---


const Color kPrimaryBlue = Color(0xFF279FF4);
const Color kHeaderBlue = Color(0xFF1E88E5);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF7F7F7);
const Color kBackgroundWhite = Color(0xFFF8F9FA);
const Color kCalendarDayHeader = Color(0xFF757575);
const Color kSelectedDateBlue = Color(0xFF279FF4);

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState
    extends State<PatientAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  int _selectedFilterIndex = 0;
  DateTime _currentDisplayDate = DateTime(2025, 12, 1); // December 2025
  DateTime? _selectedDate;
  List<DateTime> _visibleDates = [];

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _weekDays = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _appointmentService.addListener(_loadAppointments);
    _generateVisibleDates();
    _selectedDate = DateTime(2025, 12, 3); // Default to first appointment date
  }

  @override
  void dispose() {
    _appointmentService.removeListener(_loadAppointments);
    super.dispose();
  }

  void _loadAppointments() {
    setState(() {
      _appointments = _appointmentService.getPatientAppointments();
    });
  }

  void _generateVisibleDates() {
    _visibleDates = [];
    // Start from December 1, 2025 and show 7 days
    for (int i = 0; i < 7; i++) {
      _visibleDates.add(DateTime(2025, 12, 1 + i));
    }
  }

  void _navigateDates(int direction) {
    setState(() {
      for (int i = 0; i < _visibleDates.length; i++) {
        _visibleDates[i] = _visibleDates[i].add(Duration(days: direction));
      }
    });
  }

  List<Appointment> get _filteredAppointments {
    switch (_selectedFilterIndex) {
      case 1: // Upcoming (pending + accepted)
        return _appointments.where((appointment) =>
        appointment.status == 'pending' || appointment.status == 'accepted').toList();
      case 2: // Completed
        return _appointments.where((appointment) => appointment.status == 'completed').toList();
      case 3: // Cancelled (rejected)
        return _appointments.where((appointment) => appointment.status == 'rejected').toList();
      default: // All
        return _appointments;
    }
  }

  Color _getStatusColor(String status, int index) {
    // Use the same color as the appointment text color
    return _getAppointmentTextColor(index);
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Confirmed';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getAppointmentColor(int index) {
    final colors = [
      const Color(0xFFFFF2F2), // Light Red
      const Color(0xFFF0F8FF), // Light Blue
      const Color(0xFFF0FFF0), // Light Green
      const Color(0xFFFFF8E1), // Light Yellow
      const Color(0xFFF5F0FF), // Light Purple
    ];
    return colors[index % colors.length];
  }

  Color _getAppointmentTextColor(int index) {
    final colors = [
      const Color(0xFFD32F2F), // Dark Red
      const Color(0xFF1976D2), // Dark Blue
      const Color(0xFF388E3C), // Dark Green
      const Color(0xFFF57C00), // Dark Orange
      const Color(0xFF7B1FA2), // Dark Purple
    ];
    return colors[index % colors.length];
  }

  Widget _buildCalendarHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Month/Year on right side
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Appointment Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              // Month and Year on right side
              Row(
                children: [
                  // Month Dropdown
                  GestureDetector(
                    onTap: _showMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _months[_currentDisplayDate.month - 1],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryBlue,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down, color: kPrimaryBlue, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Year Dropdown
                  GestureDetector(
                    onTap: _showYearPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_currentDisplayDate.year}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryBlue,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down, color: kPrimaryBlue, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar Navigation and Days - FIXED: Complete width from left to right
          Row(
            children: [
              // Previous Button
              IconButton(
                onPressed: () => _navigateDates(-1),
                icon: const Icon(Icons.chevron_left, color: kDarkText, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: kLightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ),
              const SizedBox(width: 4),

              // Calendar Days - FIXED: Complete width using Expanded
              Expanded(
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_visibleDates.length, (index) {
                      final date = _visibleDates[index];
                      final isSelected = _selectedDate != null &&
                          _selectedDate!.day == date.day &&
                          _selectedDate!.month == date.month &&
                          _selectedDate!.year == date.year;
                      final hasAppointment = _appointments.any((appt) =>
                      appt.date.year == date.year &&
                          appt.date.month == date.month &&
                          appt.date.day == date.day);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? kSelectedDateBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _weekDays[date.weekday - 1],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : kCalendarDayHeader,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : kDarkText,
                                  ),
                                ),
                                if (hasAppointment)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : kPrimaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Next Button
              IconButton(
                onPressed: () => _navigateDates(1),
                icon: const Icon(Icons.chevron_right, color: kDarkText, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: kLightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Select Month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _months.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentDisplayDate = DateTime(_currentDisplayDate.year, index + 1);
                        _generateVisibleDates();
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _currentDisplayDate.month == index + 1
                            ? kPrimaryBlue.withOpacity(0.1)
                            : kLightGrey,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _currentDisplayDate.month == index + 1
                              ? kPrimaryBlue
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _months[index],
                          style: TextStyle(
                            fontWeight: _currentDisplayDate.month == index + 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _currentDisplayDate.month == index + 1
                                ? kPrimaryBlue
                                : kDarkText,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Select Year',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final year = 2020 + index;
                  return ListTile(
                    title: Text(
                      '$year',
                      style: TextStyle(
                        fontWeight: _currentDisplayDate.year == year
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentDisplayDate.year == year
                            ? kPrimaryBlue
                            : kDarkText,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _currentDisplayDate = DateTime(year, _currentDisplayDate.month);
                        _generateVisibleDates();
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getAppointmentColor(index),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Section
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.time,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getAppointmentTextColor(index),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_months[appointment.date.month - 1].substring(0, 3)} ${appointment.date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getAppointmentTextColor(index).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Appointment Details - Proper alignment without double lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment Title - Single line
                  Text(
                    _getAppointmentTitle(appointment),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getAppointmentTextColor(index),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Appointment Details - Single line
                  Text(
                    _getAppointmentDetails(appointment),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getAppointmentTextColor(index).withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Status Badge - Positioned in right corner with matching text color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAppointmentTextColor(index).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(appointment.status),
                style: TextStyle(
                  color: _getAppointmentTextColor(index),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppointmentTitle(Appointment appointment) {
    if (appointment.doctorSpecialty.toLowerCase().contains('therapy')) {
      return 'Physical Therapy Session';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('surgery')) {
      return 'Pre-Surgery Consultation';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('medication')) {
      return 'Medication Review Call';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('wellness')) {
      return 'Annual Wellness Exam';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('lab')) {
      return 'Lab Test (Blood Work)';
    }
    return 'Appointment with ${appointment.doctorName}';
  }

  String _getAppointmentDetails(Appointment appointment) {
    if (appointment.doctorSpecialty.toLowerCase().contains('therapy')) {
      return 'Dr. Sarah Jones, 45 min, Clinic 2B';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('surgery')) {
      return 'Dr. Ahmed Khan (Cardiology), 45 min';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('medication')) {
      return 'Nurse Practitioner Emily, 15 min, Phone';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('wellness')) {
      return 'Dr. Jane Doe (General Practice), 60 min';
    } else if (appointment.doctorSpecialty.toLowerCase().contains('lab')) {
      return 'Scheduled at City Lab, 30 min';
    }
    return '${appointment.doctorName}, ${appointment.doctorSpecialty}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDarkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: kDarkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: kPrimaryBlue, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientCalendarScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Header with Date Selection
          _buildCalendarHeader(),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 0),
                  const SizedBox(width: 8),
                  _buildFilterChip('Upcoming', 1),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 2),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 3),
                ],
              ),
            ),
          ),

          // Monthly Appointments Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Monthly Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),

          // Appointments List
          Expanded(
            child: _filteredAppointments.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No appointments found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _filteredAppointments.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showAppointmentDetails(_filteredAppointments[index]),
                  child: _buildAppointmentItem(_filteredAppointments[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilterIndex == index,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilterIndex = selected ? index : 0;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: kPrimaryBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: _selectedFilterIndex == index ? Colors.white : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _selectedFilterIndex == index ? kPrimaryBlue : Colors.grey.shade300,
        ),
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _getAppointmentTitle(appointment),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Time', appointment.time),
            _buildDetailRow('Date', '${_months[appointment.date.month - 1]} ${appointment.date.day}, ${appointment.date.year}'),
            _buildDetailRow('Doctor', appointment.doctorName),
            _buildDetailRow('Details', _getAppointmentDetails(appointment)),
            const SizedBox(height: 8),
            _buildDetailRow('Status', _getStatusText(appointment.status)),
            const SizedBox(height: 20),

            // --- START NEW BUTTON: JOIN SESSION (Voice Integration) ---
            if (appointment.status == 'accepted')
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close details modal
                      // Navigate to the shared recorder session screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecorderSessionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mic_none, size: 18),
                    label: const Text('Join Session (Voice Dictation)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700, // Distinctive attractive color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            // --- END NEW BUTTON ---

            if (appointment.status == 'accepted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PatientCalendarScreen()),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Add to Calendar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kDarkText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: kDarkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}