// upcoming_appointments_screen.dart (FIXED)
import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
// --- CHANGE VOICE INTEGRATION SCREEN ---
import 'recorder_session_screen.dart';
// --- END VOICE INTEGRATION ---

// Color constants from the original code
const Color kPrimaryColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kCalendarHeaderColor = Color(0xFFE8E8E8);

class UpcomingAppointmentsScreen extends StatefulWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  State<UpcomingAppointmentsScreen> createState() =>
      _UpcomingAppointmentsScreenState();
}

class _UpcomingAppointmentsScreenState
    extends State<UpcomingAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _todayAppointments = [];
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _otherAppointments = [];

  // Calendar state
  DateTime _selectedDate = DateTime.now(); // Today's date by default
  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> _months = [
    'January',
    'February',
    'I March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // For dropdowns - initialize with current date
  late String _selectedMonth;
  late String _selectedYear;

  @override
  void initState() {
    super.initState();

    // Initialize dropdown values based on today's date
    _selectedMonth = _months[_selectedDate.month - 1];
    _selectedYear = _selectedDate.year.toString();

    _loadAppointments();
    _appointmentService.addListener(_loadAppointments);
  }

  @override
  void dispose() {
    _appointmentService.removeListener(_loadAppointments);
    super.dispose();
  }

  void _loadAppointments() {
    setState(() {
      _todayAppointments = _appointmentService.getDoctorTodayAppointments();
      _pendingAppointments = _appointmentService.getDoctorPendingAppointments();
      _otherAppointments = _appointmentService.getDoctorOtherAppointments();
    });
  }

  void _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _appointmentService.updateAppointmentStatus(appointmentId, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $status'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get current week days for the calendar
  List<DateTime> _getCurrentWeekDays() {
    final List<DateTime> week = [];
    // Find the Monday of the week containing the selected date
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    for (int i = 0; i < 7; i++) {
      week.add(startOfWeek.add(Duration(days: i)));
    }
    return week;
  }

  // Generate calendar days
  List<Widget> _buildCalendarDays() {
    final List<Widget> days = [];
    final weekDates = _getCurrentWeekDays();

    for (int i = 0; i < 7; i++) {
      final date = weekDates[i];
      final bool isSelected =
          date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;
      final bool hasAppointment = _hasAppointmentOnDate(date);

      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: 42,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _weekDays[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                if (hasAppointment)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return days;
  }

  bool _hasAppointmentOnDate(DateTime date) {
    // FIX (from previous request): Use Set to deduplicate appointments
    final allAppointments = {
      ..._todayAppointments,
      ..._pendingAppointments,
      ..._otherAppointments,
    }.toList();
    return allAppointments.any((appointment) {
      final appointmentDate = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return appointmentDate == checkDate;
    });
  }

  // Navigation methods
  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _selectedMonth = _months[_selectedDate.month - 1];
      _selectedYear = _selectedDate.year.toString();
    });
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _selectedMonth = _months[_selectedDate.month - 1];
      _selectedYear = _selectedDate.year.toString();
    });
  }

  void _onMonthChanged(String? newMonth) {
    if (newMonth != null) {
      setState(() {
        _selectedMonth = newMonth;
        final monthIndex = _months.indexOf(newMonth) + 1;
        _selectedDate = DateTime(
          _selectedDate.year,
          monthIndex,
          _selectedDate.day,
        );
      });
    }
  }

  void _onYearChanged(String? newYear) {
    if (newYear != null) {
      setState(() {
        _selectedYear = newYear;
        final year = int.tryParse(newYear) ?? _selectedDate.year;
        _selectedDate = DateTime(year, _selectedDate.month, _selectedDate.day);
      });
    }
  }

  // Helper method to get appointment type
  String _getAppointmentType(Appointment appointment) {
    if (appointment.symptoms.isNotEmpty) {
      final words = appointment.symptoms.split(' ');
      return words
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '',
          )
          .join(' ');
    }

    final timeStart = appointment.time.split('-').first.trim();
    if (timeStart == '8:00 AM') return 'Annual Check-up';
    if (timeStart == '9:00 AM') return 'Chronic Care Follow-up';
    if (timeStart == '11:00 AM') return 'Telehealth';
    if (timeStart == '2:00 PM') return 'Vaccine Administration';

    return 'Medical Consultation';
  }

  // Helper method to get location
  String _getAppointmentLocation(Appointment appointment) {
    final timeStart = appointment.time.split('-').first.trim();

    if (appointment.patientName.contains('Ahad') || timeStart == '8:00 AM') {
      return 'Meeting Room Level 9';
    } else if (appointment.patientName.contains('Rukhsar') ||
        timeStart == '9:00 AM') {
      return 'Meeting Room Level 3';
    } else if (appointment.patientName.contains('Noor') ||
        timeStart == '11:00 AM') {
      return 'Meeting Room Level 9';
    } else if (appointment.patientName.contains('Amir') ||
        timeStart == '2:00 PM') {
      return 'Meeting Room Level 2';
    }

    return 'Meeting Room Level 1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context), // Pass context here
            // Calendar Section
            _buildCalendarSection(),

            // Appointments Section
            Expanded(child: _buildAppointmentsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Bar - REMOVED 9:41
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- START: Back Button Added ---
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {
                  // Standard navigation to go back to the previous screen (Doctor Dashboard)
                  Navigator.of(context).pop();
                },
              ),
              // --- END: Back Button Added ---
              Row(
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 16,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.wifi, size: 16, color: kPrimaryColor),
                  const SizedBox(width: 4),
                  Icon(Icons.battery_std, size: 16, color: kPrimaryColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Centered Title - CHANGED TO BLACK COLOR
          Center(
            child: Text(
              'Upcoming Appointments',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black, // CHANGED: Black color for heading
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selection Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Appointment Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // CHANGED: Black color for heading
                ),
              ),
              Row(
                children: [
                  // Month Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      onChanged: _onMonthChanged,
                      dropdownColor: kPrimaryColor,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 20,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Year Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      onChanged: _onYearChanged,
                      dropdownColor: kPrimaryColor,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 20,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      items: ['2024', '2025', '2026', '2027'].map((
                        String year,
                      ) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar Navigation
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: kPrimaryColor,
                ),
                onPressed: _goToPreviousWeek,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildCalendarDays(),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: kPrimaryColor,
                ),
                onPressed: _goToNextWeek,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    // Get appointments for selected date
    final selectedDateAppointments = _getAppointmentsForSelectedDate();

    // Get today's appointments
    final todayAppointments = _getTodaysAppointments();

    // Get upcoming appointments (future dates)
    final upcomingAppointments = _getUpcomingAppointments();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: kPrimaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: kPrimaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Today's"),
                Tab(text: 'Upcoming'),
                Tab(text: 'All'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                // Today's Appointments
                _buildAppointmentsList(todayAppointments),

                // Upcoming Appointments
                _buildAppointmentsList(upcomingAppointments),

                // All Appointments
                _buildAppointmentsList(selectedDateAppointments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Appointment> _getAppointmentsForSelectedDate() {
    // FIX: Use Set to deduplicate appointments
    final allAppointments = {
      ..._todayAppointments,
      ..._pendingAppointments,
      ..._otherAppointments,
    }.toList();
    return allAppointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      final selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return appointmentDate == selectedDate;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  List<Appointment> _getTodaysAppointments() {
    // FIX: Use Set to deduplicate appointments
    final allAppointments = {
      ..._todayAppointments,
      ..._pendingAppointments,
      ..._otherAppointments,
    }.toList();
    final today = DateTime.now();
    return allAppointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return appointmentDate == todayDate;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  List<Appointment> _getUpcomingAppointments() {
    // FIX: Use Set to deduplicate appointments
    final allAppointments = {
      ..._todayAppointments,
      ..._pendingAppointments,
      ..._otherAppointments,
    }.toList();
    final today = DateTime.now();
    return allAppointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return appointmentDate.isAfter(todayDate);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No appointments scheduled',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      // --- FIX: INCREASED BOTTOM PADDING TO PREVENT OVERFLOW (40.0) ---
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
      // --------------------------------------------------------
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isLast = index == appointments.length - 1;

        return _buildTimelineItem(appointment, isLast);
      },
    );
  }

  Widget _buildTimelineItem(Appointment appointment, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Column - Pink color
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appointment.time.split(' ').first,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor, // Pink color for time
                    ),
                  ),
                  Text(
                    appointment.time.split(' ').last,
                    style: TextStyle(
                      fontSize: 12,
                      color: kPrimaryColor, // Pink color for time
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timeline with Pink color
          Column(
            children: [
              // Dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: kPrimaryColor, // Pink color for dot
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: kPrimaryColor.withOpacity(
                      0.6,
                    ), // Pink color for line
                  ),
                ),
            ],
          ),

          // Appointment Details
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16, bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment Type - Pink color
                  Text(
                    _getAppointmentType(appointment),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor, // Pink color for heading
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Patient Name
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${appointment.patientName} Patient',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(appointment.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Time Range
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointment.time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getAppointmentLocation(appointment),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12), // Spacer before buttons
                  // Action Buttons for Pending Appointments
                  if (appointment.status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateAppointmentStatus(
                              appointment.id,
                              'accepted',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Accept'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateAppointmentStatus(
                              appointment.id,
                              'rejected',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    )
                  // --- START VOICE INTEGRATION: Confirmed/Accepted Session Button ---
                  else if (appointment.status == 'accepted' ||
                      appointment.status == 'confirmed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the RecorderSessionScreen instead of DoctorConsultationScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecorderSessionScreen(
                                // <--- CHANGED FROM DoctorConsultationScreen to RecorderSessionScreen
                                patientName: appointment.patientName,
                                appointmentId: appointment.id,
                                consultationType: _getAppointmentType(
                                  appointment,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.mic,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Start Session & Dictation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              kPrimaryColor, // Use your kPrimaryColor
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                      ),
                    )
                  // Handle other statuses like completed, rejected, cancelled
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Status: ${appointment.status.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // --- END VOICE INTEGRATION ---
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
