// lib/screens/patient_calendar_screen.dart
import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

const Color kPrimaryColor = Color(0xFF279FF4); // Changed to blue
const Color kHeaderColor = Color(0xFF1E88E5);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kSelectedColor = Color(0xFF279FF4); // Blue for selected date
const Color kAppointmentDotColor = Color(0xFF279FF4);
const Color kDateBoxColor = Color(0xFFE3F2FD); // Light blue for all date boxes

class PatientCalendarScreen extends StatefulWidget {
  const PatientCalendarScreen({super.key});

  @override
  State<PatientCalendarScreen> createState() => _PatientCalendarScreenState();
}

class _PatientCalendarScreenState extends State<PatientCalendarScreen> {
  late DateTime _currentMonth;
  late int _selectedDay;
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDay = DateTime.now().day;
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
      // Get all patient appointments (not just accepted)
      _appointments = _appointmentService.getPatientAppointments();
    });
  }

  int _getWeekdayOfFirstDay(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }

  void _changeMonth(int months) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + months,
        1,
      );
      if (_selectedDay > DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day) {
        _selectedDay = 1;
      }
    });
  }

  List<Appointment> get _appointmentsForSelectedDay {
    return _appointments.where((appointment) {
      return appointment.date.year == _currentMonth.year &&
          appointment.date.month == _currentMonth.month &&
          appointment.date.day == _selectedDay;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildMonthlyCalendarGrid(),
                  ),
                  const SizedBox(height: 25),

                  // Appointments Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Appointments For ${_getMonthName(_currentMonth.month)} $_selectedDay, ${_currentMonth.year}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildAppointmentsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_appointmentsForSelectedDay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No appointments for selected date',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children: _appointmentsForSelectedDay
            .map((appt) => _buildAppointmentCard(appt))
            .toList(),
      );
    }
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'My Appointments Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendarGrid() {
    final DateTime now = DateTime.now();
    final int daysInCurrentMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final int daysInPrevMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;
    final int startDayOffset = _getWeekdayOfFirstDay(_currentMonth);
    final int totalCells = 42;

    final String monthName = _getMonthName(_currentMonth.month);
    final int year = _currentMonth.year;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                Text(
                  '$monthName $year',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),

          // Week Days Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ))
                  .toList(),
            ),
          ),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              int dayNum = 0;
              bool isCurrentMonth = false;
              bool isToday = false;

              if (index < startDayOffset) {
                dayNum = daysInPrevMonth - startDayOffset + index + 1;
                isCurrentMonth = false;
              } else if (index >= startDayOffset && index < startDayOffset + daysInCurrentMonth) {
                dayNum = index - startDayOffset + 1;
                isCurrentMonth = true;
                isToday = _currentMonth.year == now.year && _currentMonth.month == now.month && dayNum == now.day;
              } else {
                dayNum = index - (startDayOffset + daysInCurrentMonth) + 1;
                isCurrentMonth = false;
              }

              final isSelected = isCurrentMonth && dayNum == _selectedDay;
              final hasAppointment = _appointments.any((appt) =>
              appt.date.year == _currentMonth.year &&
                  appt.date.month == _currentMonth.month &&
                  appt.date.day == dayNum);

              // All current month dates have light blue background
              Color cellColor = isCurrentMonth ? kDateBoxColor : Colors.grey.shade100;
              Color textColor = isCurrentMonth ? Colors.black87 : Colors.grey.shade400;

              if (isSelected) {
                cellColor = kSelectedColor; // Dark blue background for selected date
                textColor = Colors.white; // White text for selected date
              } else if (isToday) {
                cellColor = kPrimaryColor.withOpacity(0.3); // Slightly darker blue for today
                textColor = kPrimaryColor; // Blue text for today
              }

              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? kSelectedColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    if (isCurrentMonth) {
                      setState(() {
                        _selectedDay = dayNum;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (hasAppointment && isCurrentMonth)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : kAppointmentDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'pending': return Colors.orange;
        case 'accepted': return Colors.green;
        case 'rejected': return Colors.red;
        case 'completed': return Colors.blue;
        default: return Colors.grey;
      }
    }

    String getStatusText(String status) {
      switch (status) {
        case 'pending': return 'Pending';
        case 'accepted': return 'Confirmed';
        case 'rejected': return 'Cancelled';
        case 'completed': return 'Completed';
        default: return 'Scheduled';
      }
    }

    // Get appointment type from specialty or symptoms
    String getAppointmentType(Appointment appointment) {
      if (appointment.doctorSpecialty.isNotEmpty) {
        return appointment.doctorSpecialty;
      }
      if (appointment.symptoms.isNotEmpty) {
        return appointment.symptoms;
      }

      // Generate type based on time
      final timeStart = appointment.time.split('-').first.trim();
      if (timeStart == '10:00 AM') return 'Cardiology Checkup';
      if (timeStart == '2:00 PM') return 'General Consultation';
      if (timeStart == '5:00 PM') return 'Annual Health Checkup';

      return 'Medical Consultation';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time - Large and prominent
          Row(
            children: [
              Icon(Icons.access_time, color: kPrimaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                appointment.time,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Doctor Name - Large and clear
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 8),
              Text(
                'Dr. ${appointment.doctorName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Appointment Type - Clear and readable
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  getAppointmentType(appointment),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hospital/Location
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appointment.hospital,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status - Prominent badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: getStatusColor(appointment.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getStatusColor(appointment.status),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: getStatusColor(appointment.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  getStatusText(appointment.status),
                  style: TextStyle(
                    color: getStatusColor(appointment.status),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }
}