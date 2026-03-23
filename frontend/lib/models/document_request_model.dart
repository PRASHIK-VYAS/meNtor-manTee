class DocumentRequestModel {
  final String id;
  final String mentorId;
  final String studentId;
  final String title;
  final String description;
  final String type; // "Document" or "Certification"
  final String status; // "Pending", "Uploaded", "Approved", "Rejected"
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? uploadedAt;
  final String? filePath;

  DocumentRequestModel({
    required this.id,
    required this.mentorId,
    required this.studentId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.uploadedAt,
    this.filePath,
  });

  DocumentRequestModel copyWith({
    String? id,
    String? mentorId,
    String? studentId,
    String? title,
    String? description,
    String? type,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? uploadedAt,
    String? filePath,
  }) {
    return DocumentRequestModel(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'student_id': studentId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'rejection_reason': rejectionReason,
      'request_date': createdAt.toIso8601String(),
      'uploaded_at': uploadedAt?.toIso8601String(),
      'file_path': filePath,
    };
  }

  factory DocumentRequestModel.fromMap(Map<String, dynamic> map) {
    return DocumentRequestModel(
      id: map['id']?.toString() ?? '',
      mentorId: (map['mentor_id'] ?? map['mentorId'])?.toString() ?? '',
      studentId: (map['student_id'] ?? map['studentId'])?.toString() ?? '',
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      status: (map['status'] ?? 'Pending').toString(),
      rejectionReason: (map['rejection_reason'] ?? map['rejectionReason'])?.toString(),
      createdAt: DateTime.parse((map['request_date'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()).toString()),
      uploadedAt: (map['uploaded_at'] ?? map['uploadedAt']) != null 
          ? DateTime.parse((map['uploaded_at'] ?? map['uploadedAt']).toString()) 
          : null,
      filePath: (map['file_path'] ?? map['filePath'])?.toString(),
    );
  }
}
