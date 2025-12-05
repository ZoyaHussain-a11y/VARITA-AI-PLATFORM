// lib/models/appointment_model.dart
class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String symptoms;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty; // Fixed field name
  final String doctorImage;
  final String? patientImage;
  final DateTime date;
  final String time;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final String? notes;
  final String hospital;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Fields for consultation summary
  final String? consultationNotes;
  final List<String>? diagnosis;
  final List<String>? medication;
  final String? nextSteps;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.symptoms,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty, // Fixed parameter name
    required this.doctorImage,
    this.patientImage,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    required this.hospital,
    required this.createdAt,
    this.updatedAt,
    this.consultationNotes,
    this.diagnosis,
    this.medication,
    this.nextSteps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'symptoms': symptoms,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'patientImage': patientImage,
      'date': date.millisecondsSinceEpoch,
      'time': time,
      'status': status,
      'notes': notes,
      'hospital': hospital,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'consultationNotes': consultationNotes,
      'diagnosis': diagnosis,
      'medication': medication,
      'nextSteps': nextSteps,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      patientName: map['patientName'],
      patientEmail: map['patientEmail'],
      symptoms: map['symptoms'],
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      doctorSpecialty: map['doctorSpecialty'], // Fixed
      doctorImage: map['doctorImage'],
      patientImage: map['patientImage'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      time: map['time'],
      status: map['status'],
      notes: map['notes'],
      hospital: map['hospital'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      consultationNotes: map['consultationNotes'],
      diagnosis: map['diagnosis'] != null
          ? List<String>.from(map['diagnosis'])
          : null,
      medication: map['medication'] != null
          ? List<String>.from(map['medication'])
          : null,
      nextSteps: map['nextSteps'],
    );
  }

  Appointment copyWith({
    String? status,
    DateTime? updatedAt,
    String? symptoms,
    String? patientEmail,
    String? consultationNotes,
    List<String>? diagnosis,
    List<String>? medication,
    String? patientImage,
    String? nextSteps,
  }) {
    return Appointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      symptoms: symptoms ?? this.symptoms,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty, // Fixed
      doctorImage: doctorImage,
      patientImage: patientImage ?? this.patientImage,
      date: date,
      time: time,
      status: status ?? this.status,
      notes: notes,
      hospital: hospital,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      consultationNotes: consultationNotes ?? this.consultationNotes,
      diagnosis: diagnosis ?? this.diagnosis,
      medication: medication ?? this.medication,
      nextSteps: nextSteps ?? this.nextSteps,
    );
  }
}

class HistoryAppointment {
  final DateTime date;
  final String doctorName;
  final String specialty;
  final String hospital;
  final String condition;
  final String imageUrl;
  final String notes;
  final List<String> diagnosis;
  final List<String> medication;
  final String nextSteps;
  final String time;
  final String status;
  final String patientName;
  final String patientEmail;
  final String symptoms;

  HistoryAppointment({
    required this.date,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.condition,
    required this.imageUrl,
    required this.notes,
    required this.diagnosis,
    required this.medication,
    required this.nextSteps,
    required this.time,
    required this.status,
    required this.patientName,
    required this.patientEmail,
    required this.symptoms,
  });

  String get formattedDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
