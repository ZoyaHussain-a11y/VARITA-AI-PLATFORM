import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName("UserData")
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().unique()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get userType => text()(); // 'patient' or 'doctor'
  TextColumn get phone => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName("DoctorData")
class Doctors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get doctorId => text().unique()();
  TextColumn get name => text()();
  TextColumn get specialty => text()();
  TextColumn get imageUrl => text()();
  IntColumn get patients => integer()();
  RealColumn get rating => real()();
  TextColumn get description => text()();
  TextColumn get education => text()();
  TextColumn get yearsExperience => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName("SpecialtyData")
class Specialties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get icon => text().nullable()();
}

@DataClassName("DoctorServiceData")
class DoctorServices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get doctorId => integer().references(Doctors, #id)();
  TextColumn get service => text()();
}

@DataClassName("PatientData")
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patientId => text().unique()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get phone => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get medicalHistory => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName("AppointmentData")
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get appointmentId => text().unique()();
  TextColumn get patientId => text()();
  TextColumn get patientName => text()();
  TextColumn get patientEmail => text()();
  TextColumn get symptoms => text()();
  TextColumn get doctorId => text()();
  TextColumn get doctorName => text()();
  TextColumn get doctorSpecialty => text()();
  TextColumn get doctorImage => text()();
  TextColumn get patientImage => text().nullable()();
  DateTimeColumn get appointmentDate => dateTime()();
  TextColumn get appointmentTime => text()();
  TextColumn get status => text()(); // 'pending', 'accepted', 'rejected', 'completed'
  TextColumn get notes => text().nullable()();
  TextColumn get hospital => text()();
  TextColumn get consultationNotes => text().nullable()();
  TextColumn get diagnosis => text().nullable()(); // JSON array
  TextColumn get medication => text().nullable()(); // JSON array
  TextColumn get nextSteps => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName("ConversationData")
class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text().unique()();
  TextColumn get name => text()();
  TextColumn get lastMessage => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get patientImageUrl => text().nullable()();
  TextColumn get doctorImageUrl => text().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastMessageTime => dateTime().nullable()();
  TextColumn get specialty => text().nullable()();
  BoolColumn get isDoctor => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName("MessageData")
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().unique()();
  TextColumn get conversationId => text()();
  TextColumn get text => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text().nullable()();
  TextColumn get senderType => text()(); // 'doctor' or 'patient'
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isVoiceNote => boolean().withDefault(const Constant(false))();
  BoolColumn get isAttachment => boolean().withDefault(const Constant(false))();
  TextColumn get recipientId => text().nullable()();
  TextColumn get recipientType => text().nullable()();
}

@DriftDatabase(tables: [
  Users,
  Doctors,
  Specialties,
  DoctorServices,
  Patients,
  Appointments,
  Conversations,
  Messages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'verita_app_db');
  }

  // ==================== USERS QUERIES ====================

  Future<void> createOrUpdateUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  Future<UserData?> getUserByEmail(String email) async {
    return (select(users)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }

  Future<List<UserData>> getAllUsers() async {
    return select(users).get();
  }

  // ==================== DOCTORS QUERIES ====================

  Future<void> createOrUpdateDoctor(DoctorsCompanion doctor) async {
    await into(doctors).insertOnConflictUpdate(doctor);
  }

  Future<List<DoctorData>> getAllDoctors() async {
    return select(doctors).get();
  }

  Future<List<DoctorData>> getDoctorsBySpecialty(String specialty) async {
    return (select(doctors)..where((t) => t.specialty.equals(specialty))).get();
  }

  Future<DoctorData?> getDoctorById(int id) async {
    return (select(doctors)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<DoctorData?> getDoctorByDoctorId(String doctorId) async {
    return (select(doctors)..where((t) => t.doctorId.equals(doctorId)))
        .getSingleOrNull();
  }

  // ==================== SPECIALTIES QUERIES ====================

  Future<void> createSpecialty(SpecialtiesCompanion specialty) async {
    await into(specialties).insert(specialty);
  }

  Future<List<SpecialtyData>> getAllSpecialties() async {
    return select(specialties).get();
  }

  // ==================== DOCTOR SERVICES QUERIES ====================

  Future<void> addServiceToDoctor(DoctorServicesCompanion service) async {
    await into(doctorServices).insert(service);
  }

  Future<List<String>> getServicesByDoctorId(int doctorId) async {
    final services = await (select(doctorServices)
          ..where((t) => t.doctorId.equals(doctorId)))
        .get();
    return services.map((s) => s.service).toList();
  }

  // ==================== PATIENTS QUERIES ====================

  Future<void> createOrUpdatePatient(PatientsCompanion patient) async {
    await into(patients).insertOnConflictUpdate(patient);
  }

  Future<PatientData?> getPatientByEmail(String email) async {
    return (select(patients)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }

  Future<PatientData?> getPatientById(String patientId) async {
    return (select(patients)..where((t) => t.patientId.equals(patientId)))
        .getSingleOrNull();
  }

  // ==================== APPOINTMENTS QUERIES ====================

  Future<void> createOrUpdateAppointment(AppointmentsCompanion appointment) async {
    await into(appointments).insertOnConflictUpdate(appointment);
  }

  Future<List<AppointmentData>> getAppointmentsByPatient(String patientId) async {
    return (select(appointments)..where((t) => t.patientId.equals(patientId)))
        .get();
  }

  Future<List<AppointmentData>> getAppointmentsByDoctor(String doctorId) async {
    return (select(appointments)..where((t) => t.doctorId.equals(doctorId)))
        .get();
  }

  Future<List<AppointmentData>> getUpcomingAppointments(String patientId) async {
    return (select(appointments)
          ..where((t) => t.patientId.equals(patientId))
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.appointmentDate)]))
        .get();
  }

  Future<List<AppointmentData>> getCompletedAppointments(String patientId) async {
    return (select(appointments)
          ..where((t) => t.patientId.equals(patientId))
          ..where((t) => t.status.equals('completed'))
          ..orderBy([(t) => OrderingTerm.desc(t.appointmentDate)]))
        .get();
  }

  Future<AppointmentData?> getAppointmentById(String appointmentId) async {
    return (select(appointments)
          ..where((t) => t.appointmentId.equals(appointmentId)))
        .getSingleOrNull();
  }

  // ==================== CONVERSATIONS QUERIES ====================

  Future<void> createOrUpdateConversation(ConversationsCompanion conversation) async {
    await into(conversations).insertOnConflictUpdate(conversation);
  }

  Future<List<ConversationData>> getAllConversations() async {
    return (select(conversations)
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageTime)]))
        .get();
  }

  Future<ConversationData?> getConversationById(String conversationId) async {
    return (select(conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .getSingleOrNull();
  }

  // ==================== MESSAGES QUERIES ====================

  Future<void> createMessage(MessagesCompanion message) async {
    await into(messages).insert(message);
  }

  Future<List<MessageData>> getMessagesByConversation(String conversationId) async {
    return (select(messages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<void> deleteAllMessages(String conversationId) async {
    await (delete(messages)..where((t) => t.conversationId.equals(conversationId)))
        .go();
  }

  Future<int> getUnreadMessageCount(String conversationId) async {
    return (select(messages)..where((t) => t.conversationId.equals(conversationId)))
        .get()
        .then((msgs) => msgs.length);
  }
}
