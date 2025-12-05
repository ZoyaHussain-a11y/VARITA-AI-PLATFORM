// File: WalkInConsultationScreen.dart (UPDATED)

import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Retained for potential use
import '../models/conversation.dart'; // Retained for potential use
// --- START VOICE INTEGRATION ---
import 'recorder_session_screen.dart'; // <--- NEW IMPORT for starting the session
// --- END VOICE INTEGRATION ---


// Reusing constants from the doctor flow (Pink color)
const Color kPrimaryColor = Color(0xFFC80469); // Doctor/Main App Color
const Color kBackgroundColor = Color(0xFFF7F7F7);

class WalkInConsultationScreen extends StatefulWidget {
  const WalkInConsultationScreen({super.key});

  @override
  State<WalkInConsultationScreen> createState() => _WalkInConsultationScreenState();
}

class _WalkInConsultationScreenState extends State<WalkInConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _patientName = '';
  String _patientId = '';
  String _reasonForVisit = '';

  // Function to handle the start of the consultation
  void _startConsultation() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // SIMULATION OF HISTORY LOGGING: Show a dialog to confirm logging
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Walk-in Session Logged'),
            content: Text(
              'A new walk-in session has been initiated and logged for patient $_patientName (ID: $_patientId).\n\nReason: $_reasonForVisit',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to the Recorder Session Screen (Voice Dictation)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecorderSessionScreen(), // Navigate to the recorder
                    ),
                  );
                },
                child: const Text('Start Recorder'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    bool isRequired = true,
    int maxLines = 1,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Walk-in Consultation', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'New Walk-in Patient Entry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter the patient details to initiate the session. This will be logged for history.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),

              // Patient Name Field
              _buildTextField(
                labelText: 'Patient Name',
                icon: Icons.person,
                onSaved: (value) {
                  _patientName = value ?? '';
                },
              ),

              // Patient ID Field
              _buildTextField(
                labelText: 'Patient ID (or National ID)',
                icon: Icons.badge,
                onSaved: (value) {
                  _patientId = value ?? '';
                },
                initialValue: 'New - ${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}',
                isRequired: false, // Not strictly required for a walk-in
              ),

              // Reason for Visit Field (Multi-line)
              _buildTextField(
                labelText: 'Reason for Visit / Chief Complaint',
                icon: Icons.assignment,
                onSaved: (value) {
                  _reasonForVisit = value ?? '';
                },
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              // Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _startConsultation, // Now shows dialog then navigates
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Log & Start Consultation', // Updated text
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}