import 'package:flutter/material.dart';
// Note: HistoryAppointment model is needed here for real data,
// but we'll use placeholder data for now to keep it self-contained.

// --- CONSTANTS (Use the same color constants) ---
const Color kPrimaryBlue = Color(0xFF007BFF); // Bright primary blue
const Color kHeaderBlue = Color(0xFF007BFF);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kCardBackground = Colors.white;

class NotesDiagnosisScreen extends StatelessWidget {
  const NotesDiagnosisScreen({super.key});

  // Placeholder data for demonstration
  final String mockNotes =
      'Patient presented with a severe, localized rash on the chest and upper back, reporting intense itching that began two days ago. Patient stated recent exposure to a new laundry detergent and significant work-related stress. Vitals were stable. Physical examination confirmed maculopapular rash, non-blanching.';
  final List<String> mockDiagnosis = const [
    'Acute Contact Dermatitis (Primary)',
    'Stress-Induced Flare-up',
    'Mild Anxiety',
  ];
  final List<String> mockMedication = const [
    'Hydrocortisone Cream 1% (Apply thin layer twice daily to affected area)',
    'Loratadine 10mg (Take one tablet daily for 7 days)',
    'Zinc Oxide Cream (Apply as needed for relief)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        backgroundColor: kHeaderBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notes & Diagnosis',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: 'Consultation Notes (Detailed)',
              content: mockNotes,
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Clinical Diagnosis',
              children: mockDiagnosis.map((d) => _buildListItem(d, kPrimaryBlue)).toList(),
              icon: Icons.assignment_turned_in_rounded,
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Prescribed Medication',
              children: mockMedication.map((m) => _buildListItem(m, kDarkText)).toList(),
              icon: Icons.medical_services_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? content,
    List<Widget>? children,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryBlue),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kDarkText,
                ),
              ),
            ],
          ),
          const Divider(color: kLightGrey, height: 20),
          if (content != null)
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.justify,
            ),
          if (children != null)
            ...children,
        ],
      ),
    );
  }

  Widget _buildListItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: kDarkText),
            ),
          ),
        ],
      ),
    );
  }
}