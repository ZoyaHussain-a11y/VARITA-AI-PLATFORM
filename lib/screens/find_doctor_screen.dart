import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import 'doctor_detail_screen.dart';

// --- CONSTANTS AND COLORS (Shared) ---
const Color kPrimaryBlue = Color(0xFF007BFF);
const Color kHeaderBlue = Color(0xFFF7F7F7);
const Color kDarkText = Color(0xFF333333);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kCardBackground = Colors.white;
const Color kRatingStarColor = Color(0xFFFFC107);

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  String _searchQuery = '';
  String? _selectedDepartment = 'Pediatrician';

  // CRITICAL: All mock data instances now use 'yrsExperience'.
  final List<Doctor> _allDoctors = [
    const Doctor(
      name: 'Dr. Ali Ahmed',
      specialty: 'Pediatrician',
      imageUrl: 'assets/images/doctor_profile.png.png',
      patients: 13000,
      rating: 3.5,
      yearsExperience: '10y+',
      description:
          'Dr. Ali Ahmed is an experienced Pediatrician providing compassionate care for children. He specializes in early diagnosis, prevention care, and personalized treatment.',
      education: 'MBBS (King Edward Medical University), FCPS (Pediatrics)',
      services: [
        'General Check-up',
        'Vaccination',
        'Newborn Care',
        'Adolescent Health',
      ],
    ),
    const Doctor(
      name: 'Dr. Fatima Ali',
      specialty: 'Pediatrician',
      imageUrl: 'assets/images/1.png',
      patients: 500,
      rating: 4.0,
      yearsExperience: '5y+',
      description:
          'Dr. Fatima Ali focuses on holistic child healthcare, providing compassionate care for children from infancy through adolescence.',
      education: 'MBBS (Dow Medical College), DCH (Pediatrics)',
      services: [
        'Growth Monitoring',
        'Nutritional Advice',
        'Immunization',
        'Common Childhood Illnesses',
      ],
    ),
    const Doctor(
      name: 'Dr. Aisha Khan (Derm)',
      specialty: 'Dermatologist',
      imageUrl: 'assets/images/3.png.png',
      patients: 1500,
      rating: 4.5,
      yearsExperience: '8y+',
      description:
          'Dr. Aisha Khan is an expert Dermatologist specializing in cosmetic procedures and advanced skin treatments.',
      education: 'MBBS (Lahore Medical College), MCPS (Dermatology)',
      services: [
        'Acne Treatment',
        'Laser Hair Removal',
        'Chemical Peels',
        'Botox and Fillers',
      ],
    ),
    const Doctor(
      name: 'Dr. Zoya Farooq',
      specialty: 'Neurologist',
      imageUrl:
          'https://img.freepik.com/free-photo/female-doctor-with-stethoscope-on-white-background_1303-27756.jpg?size=626&ext=jpg',
      patients: 750,
      rating: 4.7,
      yearsExperience: '6y+',
      description:
          'Dr. Zoya Farooq is a compassionate Neurologist specializing in headache disorders and epilepsy management.',
      education: 'MBBS, MD (Neurology)',
      services: ['Migraine Treatment', 'EEG', 'Nerve Conduction Studies'],
    ),
    const Doctor(
      name: 'Dr. Khadija Khan',
      specialty: 'Cardiologist',
      imageUrl:
          'https://img.freepik.com/free-photo/beautiful-female-doctor-posing-with-arms-crossed-hospital_1262-12844.jpg?size=626&ext=jpg',
      patients: 1200,
      rating: 4.8,
      yearsExperience: '15y+',
      description:
          'Dr. Khadija Khan is a leading Cardiologist known for her expertise in interventional cardiology and cardiac rhythm disorders.',
      education: 'MBBS (Aga Khan University), FCPS (Cardiology)',
      services: [
        'ECG',
        'Echocardiography',
        'Stress Testing',
        'Cardiac Consultations',
      ],
    ),
    const Doctor(
      name: 'Dr. Hassan Raza',
      specialty: 'Physician',
      imageUrl:
          'https://img.freepik.com/free-photo/portrait-confident-male-doctor-with-stethoscope-grey-background_177978-3806.jpg?size=626&ext=jpg',
      patients: 800,
      rating: 4.2,
      yearsExperience: '7y+',
      description:
          'Dr. Hassan Raza is a general Physician providing comprehensive primary care, focusing on preventive medicine and chronic disease management.',
      education: 'MBBS (Services Institute of Medical Sciences)',
      services: [
        'General Consultations',
        'Diabetes Management',
        'Hypertension Control',
        'Annual Physicals',
      ],
    ),
  ];

  List<Doctor> get _filteredDoctors {
    List<Doctor> doctors = _allDoctors;

    if (_selectedDepartment != null && _selectedDepartment != 'All') {
      doctors = doctors
          .where((doctor) => doctor.specialty == _selectedDepartment)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      doctors = doctors
          .where(
            (doctor) =>
                doctor.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                doctor.specialty.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
    return doctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        backgroundColor: kHeaderBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDarkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Find Your Doctor',
          style: TextStyle(
            color: kDarkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: kDarkText),
            onPressed: () {
              // Handle menu action
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search your doctor',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 15,
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: kDarkText),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Select by department',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kDarkText,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDepartmentTag('Pediatrician'),
                  _buildDepartmentTag('Cardiologist'),
                  _buildDepartmentTag('Physician'),
                  _buildDepartmentTag('Dermatologist'),
                  _buildDepartmentTag('Neurologist'),
                  _buildDepartmentTag('All'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                return _buildDoctorCard(context, _filteredDoctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTag(String department) {
    bool isSelected = _selectedDepartment == department;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDepartment = department;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? kPrimaryBlue : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryBlue.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          department,
          style: TextStyle(
            color: isSelected ? Colors.white : kDarkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: doctor.imageUrl.startsWith('assets')
                    ? Image.asset(
                        doctor.imageUrl,
                        width: 90,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : Image.network(
                        doctor.imageUrl,
                        width: 90,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImagePlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
              ),
              const SizedBox(width: 15),
              // Doctor Info and Details Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kDarkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    // --- START: STACKED RATING AND PATIENT INFO ---
                    _buildRatingStars(doctor.rating),
                    const SizedBox(height: 5),

                    const Text(
                      'Patients',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                    Text(
                      '${doctor.patients}+',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),

                    // --- END: STACKED RATING AND PATIENT INFO ---
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DoctorDetailScreen(doctor: doctor),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            elevation: 3,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: const Text('See Details'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 45),
    );
  }

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(
          const Icon(Icons.star_rounded, color: kRatingStarColor, size: 18),
        );
      } else if (i == fullStars && hasHalfStar) {
        stars.add(
          const Icon(
            Icons.star_half_rounded,
            color: kRatingStarColor,
            size: 18,
          ),
        );
      } else {
        stars.add(
          Icon(
            Icons.star_outline_rounded,
            color: kRatingStarColor.withOpacity(0.5),
            size: 18,
          ),
        );
      }
    }
    return Row(children: stars);
  }
}
