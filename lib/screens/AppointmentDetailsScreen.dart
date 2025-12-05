import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import 'AppointmentConfirmedScreen.dart';
import '../services/appointment_service.dart';

const Color kPrimaryBlue = Color(0xFF279FF4);
const Color kDarkText = Color(0xFF101213);
const Color kLightGrey = Color(0xFFF5F5F7);
const Color kSecondaryText = Color(0xFF6C757D);
const Color kLightBorder = Color(0xFFE0E0E0);

class AppointmentDetailsScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime date;
  final String time;

  const AppointmentDetailsScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientEmailController = TextEditingController();
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _patientNameController.text = _appointmentService.currentPatientName;
    _patientEmailController.text = _appointmentService.currentPatientEmail;
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _patientNameController.dispose();
    _patientEmailController.dispose();
    super.dispose();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kPrimaryBlue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorHeader(),
            const SizedBox(height: 30),
            _buildAppointmentDetailsSection(),
            const SizedBox(height: 25),
            _buildSymptomsSection(),
            const SizedBox(height: 25),
            _buildPatientDetailsSection(),
            const SizedBox(height: 25),
            _buildPaymentSection(),
            const SizedBox(height: 40),
            _buildConfirmButton(context),
          ],
        ),
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

  Widget _buildAppointmentDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            title: 'Doctor Name:',
            value: widget.doctor.name,
            isWhiteText: true,
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            title: 'Date:',
            value: '${_getDayName(widget.date.weekday)}, ${_getMonthName(widget.date.month)} ${widget.date.day}, ${widget.date.year}',
            isWhiteText: true,
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            title: 'Time:',
            value: '${widget.time.replaceAll(' ', '')} PKT',
            isWhiteText: true,
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            title: 'Duration:',
            value: '30 Minutes',
            isWhiteText: true,
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            title: 'Location:',
            value: 'City General Hospital',
            isWhiteText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String title, required String value, bool isWhiteText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isWhiteText ? Colors.white : kDarkText,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isWhiteText ? Colors.white : kDarkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kLightBorder),
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
            'Briefly describe your symptoms...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 120,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kLightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLightBorder),
            ),
            child: TextField(
              controller: _symptomsController,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Describe your symptoms, concerns, or reason for visit...',
                hintStyle: TextStyle(
                  color: kSecondaryText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
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

  Widget _buildPatientDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kLightBorder),
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
            'Patient Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Patient Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: kLightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLightBorder),
            ),
            child: TextField(
              controller: _patientNameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your full name',
                hintStyle: TextStyle(
                  color: kSecondaryText,
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: kDarkText,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Patient Email Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: kLightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLightBorder),
            ),
            child: TextField(
              controller: _patientEmailController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your email address',
                hintStyle: TextStyle(
                  color: kSecondaryText,
                  fontSize: 14,
                ),
              ),
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

  Widget _buildPaymentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kLightBorder),
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
            'Payment Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentRow('Consultation Fee', '\$50.00'),
          const SizedBox(height: 10),
          _buildPaymentRow('Taxes', '\$5.00'),
          const SizedBox(height: 15),
          const Divider(height: 1, color: kLightBorder),
          const SizedBox(height: 15),
          _buildPaymentRow('Total Amount', '\$55.00', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? kPrimaryBlue : kDarkText,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? kPrimaryBlue : kDarkText,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_patientNameController.text.isEmpty || _patientEmailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all patient details'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          // Generate doctor ID based on name for now since Doctor model doesn't have id
          String doctorId = _generateDoctorId(widget.doctor.name);

          await _appointmentService.createAppointment(
            doctorId: doctorId,
            doctorName: widget.doctor.name,
            doctorSpecialty: widget.doctor.specialty,
            doctorImage: widget.doctor.imageUrl,
            date: widget.date,
            time: widget.time,
            hospital: 'City General Hospital',
            patientName: _patientNameController.text,
            patientEmail: _patientEmailController.text,
            symptoms: _symptomsController.text,
            notes: 'Appointment scheduled via app',
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentConfirmedScreen(
                doctorName: widget.doctor.name,
                selectedDate: '${_getDayName(widget.date.weekday)}, ${_getMonthName(widget.date.month)} ${widget.date.day}, ${widget.date.year}',
                selectedTime: '${widget.time.replaceAll(' ', '')} PKT',
                appointmentDuration: '30 Minutes',
                consultationFee: '\$50.00',
                paymentPaid: '\$55.00',
              ),
            ),
          );

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to schedule appointment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: const Text(
        'Confirm Appointment',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method to generate doctor ID from name
  String _generateDoctorId(String doctorName) {
    // Simple ID generation - you might want to use a more robust method
    return 'doctor_${doctorName.toLowerCase().replaceAll(' ', '_').replaceAll('.', '')}';
  }
}