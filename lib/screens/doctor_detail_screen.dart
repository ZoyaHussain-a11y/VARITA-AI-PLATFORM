import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import 'DoctorAvailabilityScreen.dart';

// --- CONSTANTS AND COLORS ---
const Color kPrimaryBlue = Color(0xFF279FF4);
const Color kDarkText = Color(0xFF101213);
const Color kLightGrey = Color(0xFFF5F5F7);
const Color kRatingStarColor = Color(0xFFFFC107);

// Fixed, precise measurements to match the visual spacing of the mockup
const double _kImageAreaHeight = 350.0;
const double _kCardOverlap = 50.0;

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  // Helper function to build rating stars
  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      Widget starIcon;
      if (i < fullStars) {
        starIcon = Icon(Icons.star, color: kRatingStarColor, size: 32);
      } else if (i == fullStars && hasHalfStar) {
        starIcon = Icon(Icons.star_half, color: kRatingStarColor, size: 32);
      } else {
        starIcon = Icon(
          Icons.star_border,
          color: kRatingStarColor.withOpacity(0.5),
          size: 32,
        );
      }
      stars.add(starIcon);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: stars
          .map(
            (star) => Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: star,
            ),
          )
          .toList(),
    );
  }

  // Helper to build the stat counters (Experience and Patients)
  Widget _buildStatCounter(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Image
            SizedBox(
              height: _kImageAreaHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blue background container
                  Container(
                    width: double.infinity,
                    height: _kImageAreaHeight,
                    color: kPrimaryBlue,
                  ),

                  // Doctor Image - Centered and properly sized
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: _kImageAreaHeight - 60,
                        width: double.infinity,
                        child: _buildDoctorImage(context),
                      ),
                    ),
                  ),

                  // Back Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White Content Card
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -_kCardOverlap, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Name
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: kDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Specialty
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Rating Stars
                    _buildRatingStars(doctor.rating),
                    const SizedBox(height: 30),

                    // About Header
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // About Description
                    Text(
                      doctor.description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: kDarkText.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Stats Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCounter(doctor.yearsExperience, 'Experience'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatCounter(
                          "${doctor.patients ~/ 1000}K+",
                          'Patients',
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),

                    // Check Availability Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DoctorAvailabilityScreen(doctor: doctor),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 8,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          shadowColor: kPrimaryBlue.withOpacity(0.6),
                        ),
                        child: const Text('Check Availability'),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage(BuildContext context) {
    return Image.network(
      doctor.imageUrl,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: kPrimaryBlue.withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: kPrimaryBlue, size: 80),
                const SizedBox(height: 10),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
