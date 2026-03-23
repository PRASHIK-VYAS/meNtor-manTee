class InternshipModel {
  final String id;
  final String studentId;
  final String companyName;
  final String role;
  final String duration;
  final String mode; // "Vacation" or "Academic"
  final String description;
  final String? certificateUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isVerified;

  InternshipModel({
    required this.id,
    required this.studentId,
    required this.companyName,
    required this.role,
    required this.duration,
    required this.mode,
    required this.description,
    this.certificateUrl,
    required this.startDate,
    required this.endDate,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'company_name': companyName,
      'role': role,
      'duration': duration,
      'mode': mode,
      'description': description,
      'certificate_url': certificateUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  factory InternshipModel.fromMap(Map<String, dynamic> map) {
    return InternshipModel(
      id: map['id']?.toString() ?? '',
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      companyName: (map['company_name'] ?? map['companyName'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      duration: (map['duration'] ?? '').toString(),
      mode: (map['mode'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      certificateUrl:
          (map['certificate_url'] ?? map['certificateUrl'])?.toString(),
      startDate: DateTime.parse((map['start_date'] ??
              map['startDate'] ??
              DateTime.now().toIso8601String())
          .toString()),
      endDate: DateTime.parse((map['end_date'] ??
              map['endDate'] ??
              DateTime.now().toIso8601String())
          .toString()),
      isVerified: (map['is_verified'] ?? map['isVerified'] as bool?) ?? false,
    );
  }
}
