import 'package:flutter/material.dart';
import 'doctor_dashboard.dart'; // For dashboard navigation
import 'upcoming_appointments_screen.dart'; // For appointments navigation
import 'message_screen.dart'; // For messages navigation
import 'total_patients_screen.dart'; // For patients navigation

// Reuse constants from the dashboard for consistency
const Color kCardColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kPrimaryColor = kCardColor;
const Color kChatIconColor = Color(0xFF42A5F5); // Light blue for contrast
const Color kAlertColor = Color(0xFFD32F2F); // Deeper red for alerts

// Static Data Models
class CriticalPatient {
  final String name;
  final String condition;
  final String imageUrl;

  CriticalPatient({
    required this.name,
    required this.condition,
    required this.imageUrl,
  });
}

final List<CriticalPatient> priorityPatients = [
  CriticalPatient(
    name: 'Fatima Ali',
    condition: 'Chest Pain',
    imageUrl:
        'https://placehold.co/100x100/A1887F/white?text=FA', // Placeholder for female patient
  ),
  CriticalPatient(
    name: 'Jane Smith',
    condition: 'Severe Chest Pain',
    imageUrl:
        'https://placehold.co/100x100/546E7A/white?text=JS', // Placeholder for female patient
  ),
  CriticalPatient(
    name: 'David Lee',
    condition: 'Acute Respiratory Distress',
    imageUrl:
        'https://placehold.co/100x100/66BB6A/white?text=DL', // Placeholder for male patient
  ),
];

// Mock data for the High-Alert Trends chart
final List<double> trendData = [
  0.5,
  0.7,
  0.6,
  0.9,
  1.0,
  0.8,
  1.1,
  0.9,
  1.2,
  1.0,
  1.3,
];
final List<String> trendLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
];

class CriticalCasesScreen extends StatelessWidget {
  const CriticalCasesScreen({super.key});

  // --- Navigation Handlers for Bottom Nav Bar ---
  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DoctorDashboardScreen()),
    );
  }

  void _navigateToAppointments(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UpcomingAppointmentsScreen(),
      ),
    );
  }

  void _navigateToMessages(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MessageScreen()),
    );
  }

  void _navigateToPatients(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TotalPatientsScreen()),
    );
  }
  // --- End Navigation Handlers ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // SafeArea to avoid notch/status bar issues, particularly for the header background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with back button
            _buildCustomHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Immediate Action Required Card
                    _buildAlertCard(context),
                    const SizedBox(height: 25),

                    // Priority Patients Section
                    _buildPriorityPatientsSection(),
                    const SizedBox(height: 25),

                    // High-Alert Trends Section
                    _buildHighAlertTrendsSection(),
                    const SizedBox(height: 30),

                    // View Emergency Protocols Button
                    _buildEmergencyProtocolsButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Custom Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // --- Header Implementation ---
  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Critical Cases',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance the back button space
        ],
      ),
    );
  }

  // --- Immediate Action Required Alert Card ---
  Widget _buildAlertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kAlertColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kAlertColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, color: Colors.white, size: 35),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Immediate Action Required',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Review Patient Protocol',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          // Use an InkWell for a clickable action area
          InkWell(
            onTap: () => print('Review Protocol clicked'),
            child: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // --- Priority Patients Section ---
  Widget _buildPriorityPatientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Patients',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        ...priorityPatients
            .map((patient) => _buildPatientRow(patient))
            .toList(),
      ],
    );
  }

  // Individual Patient Row
  Widget _buildPatientRow(CriticalPatient patient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () => print('Patient ${patient.name} profile opened'),
        child: Row(
          children: [
            // Patient Profile Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  patient.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: kPrimaryColor, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Patient Name and Condition
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    patient.condition,
                    style: TextStyle(
                      color: kAlertColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Call Icon (Clickable)
            IconButton(
              icon: const Icon(Icons.call, color: kPrimaryColor, size: 24),
              onPressed: () => print('Calling ${patient.name}'),
            ),
            const SizedBox(width: 5),
            // Chat Icon (Clickable)
            IconButton(
              icon: const Icon(Icons.message, color: kChatIconColor, size: 24),
              onPressed: () => print('Chatting with ${patient.name}'),
            ),
          ],
        ),
      ),
    );
  }

  // --- High-Alert Trends Section ---
  Widget _buildHighAlertTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'High-Alert Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),

        // Mock Chart Container
        Container(
          height: 150,
          padding: const EdgeInsets.only(top: 10, right: 10, bottom: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: LineChartPainter(trendData: trendData),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: trendLabels
                      .map(
                        (label) => Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Emergency Protocols Button ---
  Widget _buildEmergencyProtocolsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => print('View Emergency Protocols clicked'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: const Text(
          'View Emergency Protocols',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- Bottom Navigation Bar Implementation ---
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor, // Pink for active item
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: 3, // Critical Cases is active (index 3) - PINK HIGHLIGHT
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateToDashboard(context);
              break;
            case 1:
              _navigateToAppointments(context);
              break;
            case 2:
              _navigateToMessages(context);
              break;
            case 3:
              // Already on Critical Cases screen, do nothing or refresh
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Critical Cases',
          ),
        ],
      ),
    );
  }
}

// --- CustomPainter for Mock Line Chart ---
class LineChartPainter extends CustomPainter {
  final List<double> trendData;

  LineChartPainter({required this.trendData});

  @override
  void paint(Canvas canvas, Size size) {
    if (trendData.isEmpty) return;

    final double paddingBottom = 20.0; // Space for the labels

    // Define the drawable area size
    final double drawableHeight = size.height - paddingBottom;
    final double widthSegment = size.width / (trendData.length - 1);

    // --- Setup Paint Objects ---

    // Line Paint
    final linePaint = Paint()
      ..color =
          kAlertColor // Red line color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gradient Paint for the fill area
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kAlertColor.withOpacity(0.4), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, drawableHeight))
      ..style = PaintingStyle.fill;

    // Dot Paint
    final dotPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.fill;

    final dotOutlinePaint = Paint()
      ..color = kAlertColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // --- Normalize Data ---
    // Find min and max values for scaling
    final double minVal = trendData.reduce((a, b) => a < b ? a : b);
    final double maxVal = trendData.reduce((a, b) => a > b ? a : b);
    final double range = maxVal - minVal;

    // Helper function to get y-coordinate
    double getY(double value) {
      if (range == 0) return drawableHeight / 2;
      // Normalize value to 0-1 range, then map to screen height (inverted)
      final normalizedValue = (value - minVal) / range;
      return drawableHeight * (1 - normalizedValue);
    }

    // --- Draw Path ---
    final path = Path();
    final fillPath = Path();

    // Start points
    final startY = getY(trendData.first);
    path.moveTo(0, startY);
    fillPath.moveTo(0, drawableHeight);
    fillPath.lineTo(0, startY);

    // Iterate through points
    for (int i = 1; i < trendData.length; i++) {
      final x = i * widthSegment;
      final y = getY(trendData[i]);

      // Line Path
      path.lineTo(x, y);

      // Fill Path
      fillPath.lineTo(x, y);
    }

    // Complete the fill path by closing the shape at the bottom
    fillPath.lineTo(size.width, drawableHeight);
    fillPath.close();

    // Draw the fill (Area under the curve)
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    canvas.drawPath(path, linePaint);

    // Draw the dots
    for (int i = 0; i < trendData.length; i++) {
      final x = i * widthSegment;
      final y = getY(trendData[i]);
      canvas.drawCircle(Offset(x, y), 5.0, dotOutlinePaint);
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the data changes
    return (oldDelegate as LineChartPainter).trendData != trendData;
  }
}
