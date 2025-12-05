# Drift Quick Reference - How to Update Screens

## Template for Converting Screens to Drift

### Pattern 1: Load Data in initState

```dart
import '../services/database_service.dart';
import '../database/app_database.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late DatabaseService _dbService;
  List<DoctorData> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doctors = await _dbService.getAllDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_doctors[index].name));
      },
    );
  }
}
```

---

## Common Database Operations

### Doctors
```dart
// Get all doctors
List<DoctorData> doctors = await _dbService.getAllDoctors();

// Get by specialty
List<DoctorData> pediatricians = await _dbService
    .getDoctorsBySpecialty('Pediatrician');

// Get by ID
DoctorData? doctor = await _dbService.getDoctorByDoctorId('dr_001');

// Get services for a doctor
List<String> services = await _dbService.getServicesByDoctorId(doctorId);
```

### Appointments
```dart
// Create appointment
await _dbService.createAppointment(AppointmentsCompanion(
  appointmentId: Value('apt_' + DateTime.now().millisecondsSinceEpoch.toString()),
  patientId: Value('patient_123'),
  doctorId: Value('dr_001'),
  patientName: Value('John Doe'),
  appointmentDate: Value(DateTime.now()),
  appointmentTime: Value('2:00 PM'),
  status: Value('pending'),
  symptoms: Value('Fever'),
  doctorName: Value('Dr. Ali Ahmed'),
  doctorSpecialty: Value('Pediatrician'),
  doctorImage: Value('assets/images/doctor.png'),
  hospital: Value('City Hospital'),
));

// Get upcoming appointments
List<AppointmentData> upcoming =
    await _dbService.getUpcomingAppointments('patient_123');

// Get completed appointments
List<AppointmentData> completed =
    await _dbService.getCompletedAppointments('patient_123');

// Update appointment
await _dbService.updateAppointment(AppointmentsCompanion(
  appointmentId: Value('apt_001'),
  status: Value('completed'),
  consultationNotes: Value('Patient doing well'),
));
```

### Messages & Conversations
```dart
// Create conversation
await _dbService.createConversation(ConversationsCompanion(
  conversationId: Value('conv_123'),
  name: Value('Dr. Ali Ahmed'),
  lastMessage: Value('Hello!'),
  isDoctor: Value(false),
));

// Get all conversations
List<ConversationData> conversations =
    await _dbService.getAllConversations();

// Create message
await _dbService.createMessage(MessagesCompanion(
  messageId: Value('msg_' + DateTime.now().millisecondsSinceEpoch.toString()),
  conversationId: Value('conv_123'),
  text: Value('Hello doctor!'),
  senderId: Value('patient_123'),
  senderType: Value('patient'),
  timestamp: Value(DateTime.now()),
));

// Get messages
List<MessageData> messages =
    await _dbService.getMessagesByConversation('conv_123');
```

### Patients
```dart
// Create/Update patient
await _dbService.createPatient(PatientsCompanion(
  patientId: Value('patient_123'),
  name: Value('John Doe'),
  email: Value('john@example.com'),
  phone: Value('0300-1234567'),
));

// Get patient
PatientData? patient =
    await _dbService.getPatientById('patient_123');
```

### Users
```dart
// Create user
await _dbService.createUser(UsersCompanion(
  userId: Value('user_123'),
  name: Value('John Doe'),
  email: Value('john@example.com'),
  userType: Value('patient'),
));

// Get user
UserData? user =
    await _dbService.getUserByEmail('john@example.com');
```

---

## Converting Old Code to Drift

### Before (Hardcoded)
```dart
final List<Doctor> _allDoctors = [
  const Doctor(
    name: 'Dr. Ali Ahmed',
    specialty: 'Pediatrician',
    // ...
  ),
];

List<Doctor> get filteredDoctors => _allDoctors;
```

### After (Drift)
```dart
List<DoctorData> _doctors = [];

@override
void initState() {
  super.initState();
  _loadDoctors();
}

Future<void> _loadDoctors() async {
  final doctors = await _dbService.getDoctorsBySpecialty('Pediatrician');
  setState(() => _doctors = doctors);
}
```

---

## Drift Data Classes (Auto-Generated)

After running `flutter pub run build_runner build`, these classes are generated:

- `UserData` (from Users table)
- `DoctorData` (from Doctors table)
- `SpecialtyData` (from Specialties table)
- `PatientData` (from Patients table)
- `AppointmentData` (from Appointments table)
- `ConversationData` (from Conversations table)
- `MessageData` (from Messages table)

---

## Tips & Best Practices

1. **Always use await**: All database operations are async
   ```dart
   final doctors = await _dbService.getAllDoctors(); // ✓ Correct
   final doctors = _dbService.getAllDoctors(); // ✗ Wrong (returns Future)
   ```

2. **Use try-catch for error handling**:
   ```dart
   try {
     final data = await _dbService.getAllDoctors();
   } catch (e) {
     print('Error: $e');
   }
   ```

3. **Create IDs consistently**:
   ```dart
   String generateId(String prefix) {
     return '$prefix_${DateTime.now().millisecondsSinceEpoch}';
   }
   ```

4. **Cache data when possible** to avoid repeated queries

5. **Use Value() wrapper** for companion classes:
   ```dart
   DoctorData(
     id: 1,
     name: 'Dr. Ali', // ✗ Wrong
   );

   DoctorsCompanion(
     name: Value('Dr. Ali'), // ✓ Correct
   );
   ```

---

## Common Data Type Conversions

### List to JSON (for storage)
```dart
import 'dart:convert';

List<String> services = ['Service 1', 'Service 2'];
String json = jsonEncode(services); // Store in DB
List<String> restored = jsonDecode(json); // Retrieve from DB
```

### DateTime to String
```dart
DateTime date = DateTime.now();
String formatted = date.toString(); // Store
DateTime restored = DateTime.parse(formatted); // Retrieve
```

---

For full documentation, see `DRIFT_SETUP_GUIDE.md` and the main database file at `lib/database/app_database.dart`.
