import 'package:flutter/material.dart';
import 'patient_calendar_screen.dart';
import 'patient_appointments_screen.dart';
import 'patient_dashboard.dart';

const Color kPrimaryBlue = Color(0xFF279FF4);
const Color kDarkText = Color(0xFF101213);
const Color kLightGrey = Color(0xFFF5F5F7);
const Color kSecondaryText = Color(0xFF6C757D);
const Color kLightBorder = Color(0xFFE0E0E0);

class AppointmentConfirmedScreen extends StatelessWidget {
  final String doctorName;
  final String selectedDate;
  final String selectedTime;
  final String appointmentDuration;
  final String consultationFee;
  final String paymentPaid;

  const AppointmentConfirmedScreen({
    super.key,
    required this.doctorName,
    required this.selectedDate,
    required this.selectedTime,
    required this.appointmentDuration,
    required this.consultationFee,
    required this.paymentPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 50,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryBlue, Color(0xFF1E88E5)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Appointment Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your appointment with $doctorName\nis successfully booked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kLightGrey,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
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
                          const Text(
                            'Appointment Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kDarkText,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailRow('Doctor Name:', doctorName),
                          const SizedBox(height: 15),
                          _buildDetailRow('Date:', selectedDate),
                          const SizedBox(height: 15),
                          _buildDetailRow('Time:', selectedTime),
                          const SizedBox(height: 15),
                          _buildDetailRow('Duration:', appointmentDuration),
                          const SizedBox(height: 15),
                          _buildDetailRow('Consultation Fee:', consultationFee),
                          const SizedBox(height: 15),
                          _buildDetailRow('Payment Paid:', paymentPaid),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildActionButton(
                      text: 'Add To Calendar',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientCalendarScreen(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to calendar successfully!'),
                            backgroundColor: kPrimaryBlue,
                          ),
                        );
                      },
                      isPrimary: true,
                    ),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      text: 'View My Appointments',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PatientAppointmentsScreen(),
                          ),
                        );
                      },
                      isPrimary: false,
                    ),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      text: 'Go to Dashboard',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PatientDashboardScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      isPrimary: false,
                      // Make it look slightly different
                      useTransparentBackground: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kDarkText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: kSecondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool useTransparentBackground = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? kPrimaryBlue : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : kPrimaryBlue,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary || useTransparentBackground
              ? BorderSide.none
              : const BorderSide(
                  color: kPrimaryBlue,
                  width: 1.5,
                ), // Keep border for "View Appointments"
        ),
        elevation: isPrimary ? 3 : 0,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
