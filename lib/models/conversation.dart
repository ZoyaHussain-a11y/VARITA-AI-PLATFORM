class Conversation {
  final String id;
  final String name;
  final String? lastMessage;
  final String? avatarUrl;
  final String? patientImageUrl;
  final String? doctorImageUrl;
  final bool isOnline;
  final int unreadCount;
  final DateTime? lastMessageTime;
  final String? specialty;
  final bool isDoctor; // To identify if the conversation is with a doctor

  const Conversation({
    required this.id,
    required this.name,
    this.lastMessage,
    this.avatarUrl,
    this.patientImageUrl,
    this.doctorImageUrl,
    this.isOnline = false,
    this.unreadCount = 0,
    this.lastMessageTime,
    this.specialty,
    this.isDoctor = false, // Default to false (i.e., a patient)
  });

  Conversation copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? avatarUrl,
    String? patientImageUrl,
    String? doctorImageUrl,
    bool? isOnline,
    int? unreadCount,
    DateTime? lastMessageTime,
    String? specialty,
    bool? isDoctor,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      specialty: specialty ?? this.specialty,
      isDoctor: isDoctor ?? this.isDoctor,
    );
  }
}
