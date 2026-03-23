class TaskModel {
  final String id;
  final String studentId;
  final String mentorId;
  final String title;
  final String description;
  final DateTime deadline;
  final String status; // "Pending", "Submitted", "Reviewed", "Completed"
  final String? submissionUrl;
  final String? mentorRemarks;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? resourceUrl;
  final bool proofRequired; // New

  TaskModel({
    required this.id,
    required this.studentId,
    required this.mentorId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    this.submissionUrl,
    this.mentorRemarks,
    this.submittedAt,
    this.reviewedAt,
    this.resourceUrl,
    this.proofRequired = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': int.tryParse(id),
      'student_id': int.tryParse(studentId),
      'mentor_id': int.tryParse(mentorId),
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'submission_url': submissionUrl,
      'mentor_remarks': mentorRemarks,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'resource_url': resourceUrl,
      'proof_required': proofRequired,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: (map['id'] ?? '').toString(),
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      mentorId: (map['mentor_id'] ?? map['mentorId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      deadline: DateTime.parse((map['deadline'] ?? DateTime.now().toIso8601String()).toString()),
      status: (map['status'] ?? 'Pending').toString(),
      submissionUrl: (map['submission_url'] ?? map['submissionUrl'])?.toString(),
      mentorRemarks: (map['mentor_remarks'] ?? map['mentorRemarks'])?.toString(),
      submittedAt: (map['submitted_at'] ?? map['submittedAt']) != null
          ? DateTime.parse((map['submitted_at'] ?? map['submittedAt']).toString())
          : null,
      reviewedAt: (map['reviewed_at'] ?? map['reviewedAt']) != null
          ? DateTime.parse((map['reviewed_at'] ?? map['reviewedAt']).toString())
          : null,
      resourceUrl: (map['resource_url'] ?? map['resourceUrl'])?.toString(),
      proofRequired: map['proof_required'] == true || map['proofRequired'] == true,
    );
  }

  TaskModel copyWith({
    String? id,
    String? studentId,
    String? mentorId,
    String? title,
    String? description,
    DateTime? deadline,
    String? status,
    String? submissionUrl,
    String? mentorRemarks,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? resourceUrl,
    bool? proofRequired,
  }) {
    return TaskModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      mentorId: mentorId ?? this.mentorId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      submissionUrl: submissionUrl ?? this.submissionUrl,
      mentorRemarks: mentorRemarks ?? this.mentorRemarks,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      proofRequired: proofRequired ?? this.proofRequired,
    );
  }
}
