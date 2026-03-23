import 'dart:convert';

class BroadcastModel {
  final String id;
  final String mentorId;
  final String title;
  final String message;
  final DateTime date;
  final bool isUrgent;

  BroadcastModel({
    required this.id,
    required this.mentorId,
    required this.title,
    required this.message,
    required this.date,
    this.isUrgent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'is_urgent': isUrgent,
    };
  }

  factory BroadcastModel.fromMap(Map<String, dynamic> map) {
    return BroadcastModel(
      id: (map['id'] ?? '').toString(),
      mentorId: (map['mentor_id'] ?? map['mentorId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      date: map['date'] != null ? DateTime.parse(map['date'].toString()) : DateTime.now(),
      isUrgent: map['is_urgent'] ?? map['isUrgent'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory BroadcastModel.fromJson(String source) => BroadcastModel.fromMap(json.decode(source));

  BroadcastModel copyWith({
    String? id,
    String? mentorId,
    String? title,
    String? message,
    DateTime? date,
    bool? isUrgent,
  }) {
    return BroadcastModel(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }
}
