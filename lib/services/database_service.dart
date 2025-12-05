import 'package:drift/drift.dart';
import '../database/app_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late AppDatabase _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    _database = AppDatabase();
  }

  AppDatabase get db => _database;

  // ==================== DOCTOR OPERATIONS ====================

  Future<List<DoctorData>> getAllDoctors() {
    return _database.getAllDoctors();
  }

  Future<List<DoctorData>> getDoctorsBySpecialty(String specialty) {
    return _database.getDoctorsBySpecialty(specialty);
  }

  Future<DoctorData?> getDoctorById(int id) {
    return _database.getDoctorById(id);
  }

  Future<DoctorData?> getDoctorByDoctorId(String doctorId) {
    return _database.getDoctorByDoctorId(doctorId);
  }

  Future<List<String>> getServicesByDoctorId(int doctorId) {
    return _database.getServicesByDoctorId(doctorId);
  }

  // ==================== APPOINTMENT OPERATIONS ====================

  Future<void> createAppointment(AppointmentsCompanion appointment) {
    return _database.createOrUpdateAppointment(appointment);
  }

  Future<void> updateAppointment(AppointmentsCompanion appointment) {
    return _database.createOrUpdateAppointment(appointment);
  }

  Future<List<AppointmentData>> getAppointmentsByPatient(String patientId) {
    return _database.getAppointmentsByPatient(patientId);
  }

  Future<List<AppointmentData>> getAppointmentsByDoctor(String doctorId) {
    return _database.getAppointmentsByDoctor(doctorId);
  }

  Future<List<AppointmentData>> getUpcomingAppointments(String patientId) {
    return _database.getUpcomingAppointments(patientId);
  }

  Future<List<AppointmentData>> getCompletedAppointments(String patientId) {
    return _database.getCompletedAppointments(patientId);
  }

  Future<AppointmentData?> getAppointmentById(String appointmentId) {
    return _database.getAppointmentById(appointmentId);
  }

  // ==================== CONVERSATION OPERATIONS ====================

  Future<void> createConversation(ConversationsCompanion conversation) {
    return _database.createOrUpdateConversation(conversation);
  }

  Future<List<ConversationData>> getAllConversations() {
    return _database.getAllConversations();
  }

  Future<ConversationData?> getConversationById(String conversationId) {
    return _database.getConversationById(conversationId);
  }

  // ==================== MESSAGE OPERATIONS ====================

  Future<void> createMessage(MessagesCompanion message) {
    return _database.createMessage(message);
  }

  Future<List<MessageData>> getMessagesByConversation(String conversationId) {
    return _database.getMessagesByConversation(conversationId);
  }

  Future<void> deleteAllMessages(String conversationId) {
    return _database.deleteAllMessages(conversationId);
  }

  // ==================== PATIENT OPERATIONS ====================

  Future<void> createPatient(PatientsCompanion patient) {
    return _database.createOrUpdatePatient(patient);
  }

  Future<PatientData?> getPatientByEmail(String email) {
    return _database.getPatientByEmail(email);
  }

  Future<PatientData?> getPatientById(String patientId) {
    return _database.getPatientById(patientId);
  }

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(UsersCompanion user) {
    return _database.createOrUpdateUser(user);
  }

  Future<UserData?> getUserByEmail(String email) {
    return _database.getUserByEmail(email);
  }

  Future<List<UserData>> getAllUsers() {
    return _database.getAllUsers();
  }

  // ==================== SPECIALTY OPERATIONS ====================

  Future<List<SpecialtyData>> getAllSpecialties() {
    return _database.getAllSpecialties();
  }
}
