import 'package:flutter/material.dart';

// --- CONSTANTS (Use the same color constants) ---
const Color kPrimaryBlue = Color(0xFF007BFF); // Bright primary blue
const Color kHeaderBlue = Color(0xFF007BFF);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kCardBackground = Colors.white;

// Model for a single document item
class DocumentItem {
  final String title;
  final String date;
  final String type;
  final String size;

  const DocumentItem({ // Corrected: Added const to the constructor
    required this.title,
    required this.date,
    required this.type,
    required this.size,
  });
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  final List<DocumentItem> documents = const [
    DocumentItem(
      title: 'Initial Consultation Report',
      date: '2025-11-24',
      type: 'PDF',
      size: '1.2 MB',
    ),
    DocumentItem(
      title: 'Chest X-Ray Scan',
      date: '2025-11-22',
      type: 'Image',
      size: '5.8 MB',
    ),
    DocumentItem(
      title: 'Allergy Test Results',
      date: '2025-11-20',
      type: 'PDF',
      size: '0.9 MB',
    ),
    DocumentItem(
      title: 'Follow-up Prescription',
      date: '2025-12-05',
      type: 'PDF',
      size: '0.1 MB',
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
          'Documents',
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
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return _buildDocumentCard(context, documents[index]);
        },
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentItem document) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          // Placeholder action: Show download confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloading ${document.title}...')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              // Icon based on document type
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  document.type == 'PDF'
                      ? Icons.picture_as_pdf
                      : Icons.image,
                  color: kPrimaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              // Document Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded: ${document.date}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Download Icon and Size
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    color: kPrimaryBlue,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    document.size,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}