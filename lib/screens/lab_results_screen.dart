import 'package:flutter/material.dart';

// --- CONSTANTS (Use the same color constants) ---
const Color kPrimaryBlue = Color(0xFF007BFF); // Bright primary blue
const Color kHeaderBlue = Color(0xFF007BFF);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kCardBackground = Colors.white;
const Color kHighAlertColor = Color(0xFFFF5722); // Orange/Red for alerts

// Model for a lab test item
class LabTestItem {
  final String testName;
  final String referenceDate;
  final String status;
  final bool hasAbnormalResults;

  const LabTestItem({ // Corrected: Added const to the constructor
    required this.testName,
    required this.referenceDate,
    required this.status,
    this.hasAbnormalResults = false,
  });
}

class LabResultsScreen extends StatelessWidget {
  const LabResultsScreen({super.key});

  final List<LabTestItem> tests = const [
    LabTestItem(
      testName: 'Complete Blood Count (CBC)',
      referenceDate: '2025-11-22',
      status: 'Completed',
      hasAbnormalResults: true, // Corrected typo here
    ),
    LabTestItem(
      testName: 'Liver Function Tests (LFT)',
      referenceDate: '2025-11-22',
      status: 'Completed',
      hasAbnormalResults: false,
    ),
    LabTestItem(
      testName: 'Allergy Panel (IgE)',
      referenceDate: '2025-11-20',
      status: 'Completed',
      hasAbnormalResults: false,
    ),
    LabTestItem(
      testName: 'Urinalysis',
      referenceDate: '2025-10-15',
      status: 'Completed',
      hasAbnormalResults: false,
    ),
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
          'Lab Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: tests.length,
        itemBuilder: (context, index) {
          return _buildTestCard(context, tests[index]);
        },
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, LabTestItem test) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          // Placeholder action: Navigate to test details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for ${test.testName}...')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              // Status Indicator Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: test.hasAbnormalResults ? kHighAlertColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  test.hasAbnormalResults ? Icons.warning_rounded : Icons.check_circle_rounded,
                  color: test.hasAbnormalResults ? kHighAlertColor : Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              // Test Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.testName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Report Date: ${test.referenceDate}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Action Button (View Details)
              ElevatedButton(
                onPressed: () {
                  // Replicate InkWell action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing ${test.testName} report...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size.zero, // Ensures button is not too wide
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}