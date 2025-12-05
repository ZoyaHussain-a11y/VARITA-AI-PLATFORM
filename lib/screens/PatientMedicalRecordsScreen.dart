import 'package:flutter/material.dart';

// --- CONSTANTS AND COLORS (Shared) ---
const Color kPrimaryBlue = Color(0xFF279FF4); // Main app blue
const Color kHeaderBlue = Color(0xFF1E88E5); // Slightly darker blue
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF7F7F7);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kWarningOrange = Color(0xFFFF9800);

// --- Data Models for static content ---
class MedicalRecord {
  final String category;
  final String title;
  final String date;
  final String doctor;
  final String status;
  final IconData icon;

  MedicalRecord({
    required this.category,
    required this.title,
    required this.date,
    required this.doctor,
    required this.status,
    required this.icon,
  });
}

class PatientMedicalRecordsScreen extends StatefulWidget {
  const PatientMedicalRecordsScreen({super.key});

  @override
  State<PatientMedicalRecordsScreen> createState() => _PatientMedicalRecordsScreenState();
}

class _PatientMedicalRecordsScreenState extends State<PatientMedicalRecordsScreen> {
  // Mock data for demonstration
  final List<MedicalRecord> allRecords = [
    MedicalRecord(
      category: 'Summary',
      title: 'Annual Checkup Report',
      date: 'Oct 20, 2025',
      doctor: 'Dr. Jane Doe',
      status: 'Reviewed',
      icon: Icons.assignment_turned_in_outlined,
    ),
    MedicalRecord(
      category: 'Tests',
      title: 'Blood Analysis Results',
      date: 'Nov 1, 2025',
      doctor: 'Lab Services',
      status: 'Normal',
      icon: Icons.local_hospital_outlined,
    ),
    MedicalRecord(
      category: 'Prescriptions',
      title: 'Ibuprofen 400mg Renewal',
      date: 'Nov 15, 2025',
      doctor: 'Dr. Ali Ahmed',
      status: 'Active',
      icon: Icons.receipt_long_outlined,
    ),
    MedicalRecord(
      category: 'Tests',
      title: 'X-Ray (Left Knee)',
      date: 'Sep 5, 2025',
      doctor: 'Dr. Smith (Ortho)',
      status: 'Pending Review',
      icon: Icons.monitor_heart_outlined,
    ),
    MedicalRecord(
      category: 'Summary',
      title: 'Initial Consultation Notes',
      date: 'Sep 1, 2025',
      doctor: 'Dr. Jane Doe',
      status: 'Archived',
      icon: Icons.folder_open_outlined,
    ),
    MedicalRecord(
      category: 'Prescriptions',
      title: 'Vitamin D Supplement',
      date: 'Oct 25, 2025',
      doctor: 'Dr. Jane Doe',
      status: 'Completed',
      icon: Icons.receipt_long_outlined,
    ),
  ];

  String selectedCategory = 'All'; // Default filter

  // Filter the list based on the selected category
  List<MedicalRecord> get filteredRecords {
    if (selectedCategory == 'All') {
      return allRecords;
    }
    return allRecords.where((record) => record.category == selectedCategory).toList();
  }

  // List of available filter categories
  final List<String> categories = ['All', 'Summary', 'Tests', 'Prescriptions'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Filter/Segmented Control ---
          _buildCategoryFilter(),

          // --- Records List Title ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              '$selectedCategory Records (${filteredRecords.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),

          // --- Medical Records List ---
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(
              child: Text(
                'No $selectedCategory records found.',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                return _buildRecordCard(filteredRecords[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom App Bar Widget
  AppBar _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kHeaderBlue,
      elevation: 0,
      toolbarHeight: 90, // Increased height for better visual impact
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical Records',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your complete medical history',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 28),
          onPressed: () {
            // Placeholder for search functionality
          },
        ),
        const SizedBox(width: 10),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
    );
  }

  // Filter Bar Widget (Segmented Control style)
  Widget _buildCategoryFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: kPrimaryBlue.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kDarkText.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget for a single Medical Record Card
  Widget _buildRecordCard(MedicalRecord record) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'Reviewed':
        case 'Active':
        case 'Normal':
          return kSuccessGreen;
        case 'Pending Review':
          return kWarningOrange;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Placeholder for viewing details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing details for: ${record.title}'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Icon Container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(record.icon, color: kPrimaryBlue, size: 30),
              ),
              const SizedBox(width: 15),

              // Center: Record Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'With ${record.doctor}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Status and Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(record.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        color: getStatusColor(record.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}