class CertificationModel {
  final String id;
  final String studentId;
  final String title;
  final String issuer;
  final DateTime date;
  final int points;
  final String category; // "Internal" or "External"
  final String type; // "Technical", "Cultural", etc.
  final String level; // "College", "State", "National", "International"
  final String? certificateUrl;
  final bool isVerified;

  CertificationModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.issuer,
    required this.date,
    required this.points,
    required this.category,
    required this.type,
    required this.level,
    this.certificateUrl,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'title': title,
      'issuer': issuer,
      'date': date.toIso8601String(),
      'points': points,
      'category': category,
      'type': type,
      'level': level,
      'certificate_url': certificateUrl,
      'is_verified': isVerified,
    };
  }

  factory CertificationModel.fromMap(Map<String, dynamic> map) {
    return CertificationModel(
      id: map['id']?.toString() ?? '',
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      issuer: (map['issuer'] ?? '').toString(),
      date: DateTime.parse(
          (map['date'] ?? DateTime.now().toIso8601String()).toString()),
      points: map['points'] as int? ?? 0,
      category: (map['category'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      level: (map['level'] ?? '').toString(),
      certificateUrl:
          (map['certificate_url'] ?? map['certificateUrl'])?.toString(),
      isVerified: (map['is_verified'] ?? map['isVerified'] as bool?) ?? false,
    );
  }
}
