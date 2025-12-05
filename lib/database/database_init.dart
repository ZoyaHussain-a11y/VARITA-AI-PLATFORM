import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseInitializer {
  static Future<void> initializeData(AppDatabase db) async {
    // Check if data already exists
    final doctorCount = await db.getAllDoctors();
    if (doctorCount.isNotEmpty) {
      return; // Data already initialized
    }

    // Initialize specialties
    await _initializeSpecialties(db);

    // Initialize doctors
    await _initializeDoctors(db);
  }

  static Future<void> _initializeSpecialties(AppDatabase db) async {
    final specialties = [
      'Pediatrician',
      'Dermatologist',
      'Neurologist',
      'Cardiologist',
      'General Practitioner',
      'Orthopedic',
      'Gastroenterologist',
      'ENT Specialist',
    ];

    for (final specialty in specialties) {
      await db.createSpecialty(
        SpecialtiesCompanion(
          name: Value(specialty),
          icon: const Value(null),
        ),
      );
    }
  }

  static Future<void> _initializeDoctors(AppDatabase db) async {
    final doctorsData = [
      {
        'doctorId': 'dr_001',
        'name': 'Dr. Ali Ahmed',
        'specialty': 'Pediatrician',
        'imageUrl': 'assets/images/doctor_profile.png.png',
        'patients': 13000,
        'rating': 3.5,
        'yearsExperience': '10y+',
        'description':
            'Dr. Ali Ahmed is an experienced Pediatrician providing compassionate care for children. He specializes in early diagnosis, prevention care, and personalized treatment.',
        'education': 'MBBS (King Edward Medical University), FCPS (Pediatrics)',
        'services': [
          'General Check-up',
          'Vaccination',
          'Newborn Care',
          'Adolescent Health',
        ],
      },
      {
        'doctorId': 'dr_002',
        'name': 'Dr. Fatima Ali',
        'specialty': 'Pediatrician',
        'imageUrl': 'assets/images/doctor_profile.png.png',
        'patients': 500,
        'rating': 4.0,
        'yearsExperience': '5y+',
        'description':
            'Dr. Fatima Ali focuses on holistic child healthcare, providing compassionate care for children from infancy through adolescence.',
        'education': 'MBBS (Dow Medical College), DCH (Pediatrics)',
        'services': [
          'Growth Monitoring',
          'Nutritional Advice',
          'Immunization',
          'Common Childhood Illnesses',
        ],
      },
      {
        'doctorId': 'dr_003',
        'name': 'Dr. Aisha Khan',
        'specialty': 'Dermatologist',
        'imageUrl': 'assets/images/doctor_profile.png.png',
        'patients': 1500,
        'rating': 4.5,
        'yearsExperience': '8y+',
        'description':
            'Dr. Aisha Khan is an expert Dermatologist specializing in cosmetic procedures and advanced skin treatments.',
        'education': 'MBBS (Lahore Medical College), MCPS (Dermatology)',
        'services': [
          'Acne Treatment',
          'Laser Hair Removal',
          'Chemical Peels',
          'Botox and Fillers',
        ],
      },
      {
        'doctorId': 'dr_004',
        'name': 'Dr. Zoya Farooq',
        'specialty': 'Neurologist',
        'imageUrl':
            'https://img.freepik.com/free-photo/female-doctor-with-stethoscope-on-white-background_1303-27756.jpg?size=626&ext=jpg',
        'patients': 750,
        'rating': 4.7,
        'yearsExperience': '6y+',
        'description':
            'Dr. Zoya Farooq is a compassionate Neurologist specializing in headache disorders and epilepsy management.',
        'education': 'MBBS, MD (Neurology)',
        'services': ['Migraine Treatment', 'EEG', 'Nerve Conduction Studies'],
      },
      {
        'doctorId': 'dr_005',
        'name': 'Dr. Khadija Khan',
        'specialty': 'Cardiologist',
        'imageUrl':
            'https://img.freepik.com/free-photo/beautiful-female-doctor-posing-with-arms-crossed-hospital_1262-12844.jpg?size=626&ext=jpg',
        'patients': 1200,
        'rating': 4.8,
        'yearsExperience': '15y+',
        'description':
            'Dr. Khadija Khan is a leading Cardiologist known for her expertise in interventional cardiology and cardiac rhythm disorders.',
        'education': 'MBBS (Aga Khan University), FCPS (Cardiology)',
        'services': [
          'Cardiac Consultations',
          'ECG',
          'Echocardiography',
          'Stress Testing',
        ],
      },
    ];

    for (final doctor in doctorsData) {
      final services = doctor['services'] as List<String>;

      final doctorCompanion = DoctorsCompanion(
        doctorId: Value(doctor['doctorId'] as String),
        name: Value(doctor['name'] as String),
        specialty: Value(doctor['specialty'] as String),
        imageUrl: Value(doctor['imageUrl'] as String),
        patients: Value(doctor['patients'] as int),
        rating: Value((doctor['rating'] as num).toDouble()),
        description: Value(doctor['description'] as String),
        education: Value(doctor['education'] as String),
        yearsExperience: Value(doctor['yearsExperience'] as String),
      );

      await db.createOrUpdateDoctor(doctorCompanion);

      // Get the inserted doctor to add services
      final insertedDoctor = await db.getDoctorByDoctorId(doctor['doctorId'] as String);
      if (insertedDoctor != null) {
        for (final service in services) {
          await db.addServiceToDoctor(
            DoctorServicesCompanion(
              doctorId: Value(insertedDoctor.id),
              service: Value(service),
            ),
          );
        }
      }
    }
  }
}
