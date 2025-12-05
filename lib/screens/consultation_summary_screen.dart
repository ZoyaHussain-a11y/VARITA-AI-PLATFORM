import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
// Import the new placeholder screens for navigation
import 'lab_results_screen.dart';
import 'notes_diagnosis_screen.dart';
import 'documents_screen.dart';

// --- CONSTANTS AND COLORS (Shared) ---
const Color kPrimaryBlue = Color(0xFF007BFF); // Bright primary blue
const Color kHeaderBlue = Color(0xFF007BFF);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kCardBackground = Colors.white;

class ConsultationSummaryScreen extends StatefulWidget {
  final HistoryAppointment appointment;

  const ConsultationSummaryScreen({super.key, required this.appointment});

  @override
  State<ConsultationSummaryScreen> createState() => _ConsultationSummaryScreenState();
}

class _ConsultationSummaryScreenState extends State<ConsultationSummaryScreen> {
  // State to manage the currently selected tab (0: Overview, 1: Notes, 2: Documents)
  int _selectedTabIndex = 0;

  // Navigation function for the top tabs
  void _navigateToTab(int index) {
    if (index == 0) {
      // Stay on the current screen (Overview)
      setState(() {
        _selectedTabIndex = 0;
      });
    } else if (index == 1) {
      // Navigate to Notes & Diagnosis Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotesDiagnosisScreen()),
      );
    } else if (index == 2) {
      // Navigate to Documents Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DocumentsScreen()),
      );
    }
  }

  // Navigation function for the action buttons
  void _handleActionButton(String action) {
    if (action == 'View Lab Results') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LabResultsScreen()),
      );
    } else if (action == 'Download Prescription') {
      // Placeholder for download logic (e.g., show a success message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading prescription...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
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
            'Consultation Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Tab Bar ---
            _buildTabBar(),
            const SizedBox(height: 20),

            // --- Doctor & Appointment Details Card ---
            _buildDoctorDetailsCard(),
            const SizedBox(height: 20),

            // --- Consultation Notes & Diagnosis (Two-column layout) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoCard(
                  title: 'Consultation Notes',
                  // Use the provided notes structure from the image
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Doctor: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kDarkText),
                          ),
                          TextSpan(
                            text: widget.appointment.notes.split('. ').first, // Use first sentence as a mock for the short summary
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Patient: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kDarkText),
                          ),
                          TextSpan(
                            text: 'Explained the irritation and allergy.', // Mock data based on the image
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: 15),
                Expanded(child: _buildInfoCard(
                  title: 'Diagnosis',
                  children: widget.appointment.diagnosis.map((d) => _buildListItem(d)).toList(),
                )),
              ],
            ),
            const SizedBox(height: 15),

            // --- Next Steps & Medication (Two-column layout) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoCard(
                    title: 'Next Steps',
                    // Mock content for next steps based on the image style
                    children: [
                      Text(
                        'Schedule Follow-Up',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${widget.appointment.nextSteps.split('. ').last} (after 1 month)', // Use next step from model and add mock suffix
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ]
                )),
                const SizedBox(width: 15),
                Expanded(child: _buildInfoCard(
                  title: 'Medication',
                  children: widget.appointment.medication.map((m) => _buildListItem(m)).toList(),
                )),
              ],
            ),
            const SizedBox(height: 30),

            // --- Action Buttons (Both blue) ---
            _buildActionButton('View Lab Results', kPrimaryBlue),
            const SizedBox(height: 15),
            _buildActionButton('Download Prescription', kPrimaryBlue), // Made blue as requested
          ],
        ),
      ),
    );
  }

  // Helper widget for the Tab Bar area
  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _navigateToTab(0),
          child: _buildTabButton('Overview', _selectedTabIndex == 0),
        ),
        GestureDetector(
          onTap: () => _navigateToTab(1),
          child: _buildTabButton('Notes & Diagnosis', _selectedTabIndex == 1),
        ),
        GestureDetector(
          onTap: () => _navigateToTab(2),
          child: _buildTabButton('Documents', _selectedTabIndex == 2),
        ),
      ],
    );
  }

  // Helper widget for a single Tab Button
  Widget _buildTabButton(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryBlue : kCardBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ]
            : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : kDarkText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper widget for the main Doctor Details Card
  Widget _buildDoctorDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Image
          ClipOval(
            child: Image.network(
              widget.appointment.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(color: kLightGrey, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.grey, size: 40),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          // Doctor and Appointment Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Name and Date (Aligned right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.appointment.doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDarkText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.appointment.formattedDate,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kDarkText),
                    ),
                  ],
                ),
                Text(widget.appointment.specialty, style: const TextStyle(fontSize: 14, color: Colors.grey)),

                const SizedBox(height: 5),

                // Time and Location (Aligned left, one below the other)
                Text('Time: ${widget.appointment.time}', style: const TextStyle(fontSize: 13, color: kDarkText)),
                Text('Location: ${widget.appointment.hospital}', style: const TextStyle(fontSize: 13, color: kDarkText)),

                const SizedBox(height: 5),

                // Status (Aligned right)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Status: ${widget.appointment.status}', style: TextStyle(fontSize: 13, color: widget.appointment.status == 'Completed' ? Colors.green.shade600 : kPrimaryBlue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for general information cards (Diagnosis, Medication, Notes)
  Widget _buildInfoCard({required String title, String? content, List<Widget>? children}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140), // Ensure minimum height for alignment
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: kDarkText,
            ),
          ),
          const Divider(color: kLightGrey, height: 10),
          if (content != null)
            Text(content, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          if (children != null)
            ...children,
        ],
      ),
    );
  }

  // Helper widget for bullet points/list items
  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(fontSize: 16, color: kDarkText)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: kDarkText))), // Text color changed to kDarkText to match image better
        ],
      ),
    );
  }

  // Helper widget for action buttons
  Widget _buildActionButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () => _handleActionButton(text), // Use the new handler
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}