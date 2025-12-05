// lib/services/appointment_service.dart
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class AppointmentService with ChangeNotifier {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal() {
    initializeMockData();
  }

  List<Appointment> _appointments = [];

  final String currentPatientId = 'patient_001';
  final String currentPatientName = 'John';
  final String currentPatientEmail = 'john@example.com';
  final String currentDoctorId = 'doctor_dr_ali_ahmed';
  final String currentDoctorName = 'Dr. Ali Ahmed';

  List<Appointment> getPatientAppointments() {
    return _appointments
        .where((appointment) => appointment.patientId == currentPatientId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Appointment> getPatientPendingAppointments() {
    return _appointments
        .where((appointment) =>
    appointment.patientId == currentPatientId &&
        appointment.status == 'pending')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> getPatientAcceptedAppointments() {
    return _appointments
        .where((appointment) =>
    appointment.patientId == currentPatientId &&
        appointment.status == 'accepted')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> getPatientHistoryAppointments() {
    return _appointments
        .where((appointment) =>
    appointment.patientId == currentPatientId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Appointment> getDoctorTodayAppointments() {
    final today = DateTime.now();
    return _appointments
        .where((appointment) =>
    appointment.doctorId == currentDoctorId &&
        appointment.date.year == today.year &&
        appointment.date.month == today.month &&
        appointment.date.day == today.day)
        .toList()
      ..sort((a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));
  }

  List<Appointment> getDoctorPendingAppointments() {
    return _appointments
        .where((appointment) =>
    appointment.doctorId == currentDoctorId &&
        appointment.status == 'pending')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> getDoctorOtherAppointments() {
    final today = DateTime.now();
    return _appointments
        .where((appointment) =>
    appointment.doctorId == currentDoctorId &&
        appointment.status == 'accepted' &&
        (appointment.date.year != today.year ||
            appointment.date.month != today.month ||
            appointment.date.day != today.day))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> getDoctorAppointments() {
    return _appointments
        .where((appointment) => appointment.doctorId == currentDoctorId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int _timeToMinutes(String time) {
    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts[1];
    final timeParts = timePart.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    if (period == 'PM' && hours != 12) hours += 12;
    if (period == 'AM' && hours == 12) hours = 0;

    return hours * 60 + minutes;
  }

  Future<void> createAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required String doctorImage,
    required DateTime date,
    required String time,
    required String hospital,
    required String patientName,
    required String patientEmail,
    required String symptoms,
    String? notes,
  }) async {
    final newAppointment = Appointment(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      patientId: currentPatientId,
      patientName: patientName,
      patientEmail: patientEmail,
      symptoms: symptoms,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorImage: doctorImage,
      date: date,
      time: time,
      status: 'pending',
      notes: notes,
      hospital: hospital,
      createdAt: DateTime.now(),
    );

    _appointments.add(newAppointment);
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    final index = _appointments.indexWhere((app) => app.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }

    await Future.delayed(Duration(milliseconds: 500));
  }

  List<Appointment> getCalendarAppointments(String userId, bool isDoctor) {
    if (isDoctor) {
      return _appointments
          .where((appointment) =>
      appointment.doctorId == userId &&
          (appointment.status == 'accepted' || appointment.status == 'pending'))
          .toList();
    } else {
      return _appointments
          .where((appointment) =>
      appointment.patientId == userId &&
          (appointment.status == 'accepted' || appointment.status == 'pending'))
          .toList();
    }
  }

  void initializeMockData() {
    if (_appointments.isEmpty) {
      _appointments.addAll([
        Appointment(
          id: 'app_1',
          patientId: currentPatientId,
          patientName: 'John',
          patientEmail: 'john@example.com',
          symptoms: 'Fever and headache',
          doctorId: 'doctor_dr_ali_ahmed',
          doctorName: 'Dr. Ali Ahmed',
          doctorSpecialty: 'Pediatrician',
          doctorImage: 'assets/images/doctor_profile.png.png',
          date: DateTime.now().add(Duration(days: 1)),
          time: '10:00 AM',
          status: 'pending',
          hospital: 'City Hospital',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        Appointment(
          id: 'app_2',
          patientId: 'patient_002',
          patientName: 'Sarah',
          patientEmail: 'sarah@example.com',
          symptoms: 'Chest pain and dizziness',
          doctorId: 'doctor_dr_ali_ahmed',
          doctorName: 'Dr. Ali Ahmed',
          doctorSpecialty: 'Pediatrician',
          doctorImage: 'assets/images/doctor_profile.png.png',
          date: DateTime.now(),
          time: '2:00 PM',
          status: 'pending',
          hospital: 'City Hospital',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
        ),
        Appointment(
          id: 'app_3',
          patientId: 'patient_003',
          patientName: 'Mike',
          patientEmail: 'mike@example.com',
          symptoms: 'Regular checkup',
          doctorId: 'doctor_dr_ali_ahmed',
          doctorName: 'Dr. Ali Ahmed',
          doctorSpecialty: 'Pediatrician',
          doctorImage: 'assets/images/doctor_profile.png.png',
          date: DateTime.now().subtract(Duration(days: 1)),
          time: '11:00 AM',
          status: 'accepted',
          hospital: 'City Hospital',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          updatedAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        Appointment(
          id: 'app_4',
          patientId: currentPatientId,
          patientName: 'John',
          patientEmail: 'john@example.com',
          symptoms: 'Back pain and fatigue',
          doctorId: 'doctor_dr_sarah_wilson',
          doctorName: 'Dr. Sarah Wilson',
          doctorSpecialty: 'Orthopedic',
          doctorImage: 'assets/images/doctor_profile.png.png',
          date: DateTime.now().subtract(Duration(days: 5)),
          time: '3:00 PM',
          status: 'completed',
          hospital: 'City Hospital',
          createdAt: DateTime.now().subtract(Duration(days: 7)),
          updatedAt: DateTime.now().subtract(Duration(days: 5)),
        ),
      ]);
    }
  }

  String generateDoctorId(String doctorName) {
    return 'doctor_${doctorName.toLowerCase().replaceAll(' ', '_').replaceAll('.', '')}';
  }
}