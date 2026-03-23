class ActivityModel {
  final String id;
  final String studentId;
  final String eventName;
  final String level; // "College", "State", "National", "International"
  final String role;
  final DateTime date;
  final String? proofUrl;
  final bool isVerified;

  ActivityModel({
    required this.id,
    required this.studentId,
    required this.eventName,
    required this.level,
    required this.role,
    required this.date,
    this.proofUrl,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'student_id': studentId,
      'event_name': eventName,
      'level': level,
      'role': role,
      'date': date.toIso8601String(),
      'proof_url': proofUrl,
      'is_verified': isVerified,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id']?.toString() ?? '',
      studentId: (map['student_id'] ?? map['studentId'])?.toString() ?? '',
      eventName: (map['event_name'] ?? map['eventName'])?.toString() ?? '',
      level: (map['level'])?.toString() ?? '',
      role: (map['role'])?.toString() ?? '',
      date: DateTime.parse(
          (map['date'])?.toString() ?? DateTime.now().toIso8601String()),
      proofUrl: map['proof_url']?.toString(),
      isVerified: map['is_verified'] == 1 || map['is_verified'] == true,
    );
  }
}
