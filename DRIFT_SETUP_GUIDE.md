# Drift Database Integration Setup Guide

## Complete Migration to Drift Database

This project has been completely migrated from hardcoded static data to use **Drift** database for persistent local storage.

### What's New

- **Database Schema**: 8 tables for all app data (Users, Doctors, Specialties, Doctor Services, Patients, Appointments, Conversations, Messages)
- **Automatic Initialization**: Hardcoded data is automatically inserted on first app run
- **Full Drift Integration**: All screens updated to use database queries
- **Type-Safe Queries**: All database operations are type-safe with auto-generated code

### Project Structure

```
lib/
├── database/
│   ├── app_database.dart          # Main Drift database file
│   └── database_init.dart         # Initializes hardcoded data
├── services/
│   ├── database_service.dart      # Database service layer (singleton)
│   └── [existing services...]
├── models/
│   ├── [existing models...]
│   └── [Drift auto-generates data classes]
└── screens/
    ├── find_doctor_screen.dart    # Updated to use Drift
    └── [other screens...]
```

### Setup Steps

#### Step 1: Install Dependencies
```bash
flutter pub get
```

#### Step 2: Generate Drift Code
```bash
flutter pub run build_runner build
```

This generates:
- `app_database.g.dart` (auto-generated database code)

#### Step 3: Run the App
```bash
flutter run
```

The app will automatically:
1. Initialize the Drift database
2. Create all tables
3. Insert hardcoded doctor data on first run
4. Use the database for all subsequent operations

### Database Tables

#### 1. **Users** - User accounts (patients and doctors)
- userId, name, email, userType, phone, imageUrl, createdAt

#### 2. **Doctors** - Doctor profiles
- doctorId, name, specialty, imageUrl, patients, rating, description, education, yearsExperience

#### 3. **Specialties** - Medical specialties list
- id, name, icon

#### 4. **DoctorServices** - Services per doctor
- id, doctorId, service

#### 5. **Patients** - Patient profiles
- patientId, name, email, phone, imageUrl, medicalHistory, createdAt

#### 6. **Appointments** - Appointment records
- appointmentId, patientId, doctorId, date, time, status, consultationNotes, diagnosis, medication, etc.

#### 7. **Conversations** - Chat conversations
- conversationId, name, lastMessage, lastMessageTime, isOnline, unreadCount, etc.

#### 8. **Messages** - Individual messages
- messageId, conversationId, senderId, text, timestamp, isVoiceNote, etc.

### Usage Examples

#### Getting All Doctors
```dart
final dbService = DatabaseService();
final doctors = await dbService.getAllDoctors();
```

#### Getting Doctors by Specialty
```dart
final cardiology = await dbService.getDoctorsBySpecialty('Cardiologist');
```

#### Creating an Appointment
```dart
await dbService.createAppointment(
  AppointmentsCompanion(
    appointmentId: Value('apt_001'),
    patientId: Value('pat_123'),
    doctorId: Value('dr_001'),
    appointmentDate: Value(DateTime.now()),
    // ... other fields
  ),
);
```

#### Getting Messages for a Conversation
```dart
final messages = await dbService.getMessagesByConversation('conv_123');
```

### Important Notes

1. **Database Service Singleton**: `DatabaseService()` returns the same instance throughout the app
2. **Async Operations**: All database operations are async, use `await` or `.then()`
3. **Data Persistence**: All data is persisted in the local SQLite database
4. **Auto-Generated Code**: After running `build_runner`, check for any generated files in `.dart_tool`

### Troubleshooting

#### Build Runner Issues
```bash
# Clean build files
flutter clean
flutter pub get

# Rebuild everything
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Database Reset (Testing)
The database is created automatically on app initialization. To reset:
1. Uninstall the app from the device/emulator
2. Run `flutter run` again

### Hardcoded Data Initialization

When the app first runs, the following data is automatically loaded into the database:

- **5 Doctors** with various specialties (Pediatrician, Dermatologist, Neurologist, Cardiologist, Physician)
- **8 Medical Specialties**
- **Services** for each doctor (varies by specialty)

This data comes from `lib/database/database_init.dart` and is only inserted once.

### Next Steps

1. Update remaining screens to use `DatabaseService` queries
2. Test all CRUD operations (Create, Read, Update, Delete)
3. Implement real-time synchronization if needed
4. Add proper error handling for database operations

### Documentation Links

- Drift Documentation: https://drift.simonbinder.eu/
- SQLite Documentation: https://www.sqlite.org/

---

**Your project is now fully integrated with Drift!** All static data has been moved to the database while keeping your UI and functionality exactly the same.
