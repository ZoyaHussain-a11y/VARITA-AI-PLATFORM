// models/message.dart
class Message {
  final String id;
  final String text;
  final String senderId;
  final String? senderName;
  final String senderType;
  final DateTime? timestamp;
  final bool isVoiceNote;
  final bool isAttachment;
  final String? recipientId;
  final String? recipientType;
  final String? conversationId; // This was missing

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    this.senderName,
    required this.senderType,
    this.timestamp,
    this.isVoiceNote = false,
    this.isAttachment = false,
    this.recipientId,
    this.recipientType,
    this.conversationId,
  });

  // Add copyWith method if not exists
  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    String? senderName,
    String? senderType,
    DateTime? timestamp,
    bool? isVoiceNote,
    bool? isAttachment,
    String? recipientId,
    String? recipientType,
    String? conversationId,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      timestamp: timestamp ?? this.timestamp,
      isVoiceNote: isVoiceNote ?? this.isVoiceNote,
      isAttachment: isAttachment ?? this.isAttachment,
      recipientId: recipientId ?? this.recipientId,
      recipientType: recipientType ?? this.recipientType,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
