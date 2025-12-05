import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import 'AppointmentDetailsScreen.dart';
import '../services/appointment_service.dart';

const Color kPrimaryBlue = Color(0xFF279FF4);
const Color kDarkText = Color(0xFF101213);
const Color kLightGrey = Color(0xFFF5F5F7);
const Color kSecondaryText = Color(0xFF6C757D);
const Color kLightBorder = Color(0xFFE0E0E0);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kWarningAmber = Color(0xFFFF9800);

class DoctorAvailabilityScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorAvailabilityScreen({super.key, required this.doctor});

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  DateTime _currentMonth = DateTime.now();

  final List<String> _morningSlots = ['8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM'];
  final List<String> _afternoonSlots = ['12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM'];
  final List<String> _eveningSlots = ['2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];

  final Set<DateTime> _unavailableDates = {
    DateTime.now().add(const Duration(days: 1)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().add(const Duration(days: 8)),
    DateTime.now().add(const Duration(days: 12)),
  };

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectableDayPredicate: (DateTime day) {
        return day.weekday != DateTime.saturday &&
            day.weekday != DateTime.sunday &&
            !_unavailableDates.any((unavailable) =>
            unavailable.year == day.year &&
                unavailable.month == day.month &&
                unavailable.day == day.day);
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              onSurface: kDarkText,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryBlue,
              ),
            ),
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: child,
            ),
          ),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _isDateAvailable(DateTime date) {
    return !_unavailableDates.any((unavailable) =>
    unavailable.year == date.year &&
        unavailable.month == date.month &&
        unavailable.day == date.day) &&
        date.weekday != DateTime.saturday &&
        date.weekday != DateTime.sunday;
  }

  Widget _buildCalendarView() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    final List<String> weekdays = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'];
    for (String day in weekdays) {
      dayWidgets.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: day == 'Sat' || day == 'Sun' ? Colors.grey : kDarkText,
            ),
          ),
        ),
      );
    }

    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isAvailable = _isDateAvailable(date);
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;

      dayWidgets.add(
        GestureDetector(
          onTap: isAvailable ? () {
            setState(() {
              _selectedDate = date;
              _selectedTime = null;
            });
          } : null,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? kPrimaryBlue : Colors.transparent,
              border: Border.all(
                color: isSelected ? kPrimaryBlue :
                isToday ? kPrimaryBlue : Colors.transparent,
                width: isSelected ? 0 : 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white :
                    isAvailable ? kDarkText : Colors.grey.shade400,
                  ),
                ),
                if (isAvailable && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: kSuccessGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kLightGrey,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 24),
                  onPressed: _navigateToPreviousMonth,
                  color: kPrimaryBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '< ${_getMonthName(_currentMonth.month)} ${_currentMonth.year} >',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkText,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kLightGrey,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24),
                  onPressed: _navigateToNextMonth,
                  color: kPrimaryBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: dayWidgets,
              ),
              const SizedBox(height: 20),
              _buildCalendarLegend(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(kSuccessGreen, 'Available'),
          _buildLegendItem(Colors.grey.shade400, 'Unavailable'),
          _buildLegendItem(kPrimaryBlue, 'Selected'),
          _buildLegendItem(kPrimaryBlue, 'Today', isBorder: true),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, {bool isBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isBorder ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: kSecondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        title: const Text('Select Appointment Slot'),
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorHeader(),
                const SizedBox(height: 25),
                _buildCalendarView(),
                const SizedBox(height: 30),
                _buildTimeSlotSection('Morning', _morningSlots),
                const SizedBox(height: 25),
                _buildTimeSlotSection('Afternoon', _afternoonSlots),
                const SizedBox(height: 25),
                _buildTimeSlotSection('Evening', _eveningSlots),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildFloatingConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryBlue, Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              image: const DecorationImage(
                image: AssetImage('assets/images/doctor_profile.png.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.doctor.specialty,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSection(String title, List<String> slots) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: slots.map((time) {
              final isSelected = time == _selectedTime;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? kPrimaryBlue : kLightBorder,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: kPrimaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kDarkText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingConfirmButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedTime == null ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentDetailsScreen(
                  doctor: widget.doctor,
                  date: _selectedDate,
                  time: _selectedTime!,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            disabledBackgroundColor: kPrimaryBlue.withOpacity(0.3),
            disabledForegroundColor: Colors.white70,
          ),
          child: const Text(
            'Confirm Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}