class StudentModel {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber; // New
  final String studentId;
  final String department;
  final String admissionType; // "Regular" or "DSE"
  final DateTime dateOfBirth;
  final DateTime dateOfJoining;
  final String? mentorId;
  final String? mentorName;
  final String? mentorCode; // New
  final String? groupLeaderName;
  final double currentCGPA;
  final int totalInternships;
  final int certificationPoints;
  final int pendingTasks;
  final int upcomingMeetings; // New
  final int unreadBroadcasts; // New
  final double documentCompletion; // New (0.0 to 100.0)
  final Map<String, String> documentStatuses; // Document Name -> Status
  final Map<String, String>
      documentFilePaths; // New: Document Name -> Local File Path
  final double creditScore; // New: Performance score
  final int currentSemester; // New

  StudentModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.department,
    required this.admissionType,
    required this.dateOfBirth,
    required this.dateOfJoining,
    this.mentorId,
    this.mentorName,
    this.mentorCode,
    this.groupLeaderName,
    this.currentCGPA = 0.0,
    this.totalInternships = 0,
    this.certificationPoints = 0,
    this.pendingTasks = 0,
    this.upcomingMeetings = 0,
    this.unreadBroadcasts = 0,
    this.documentCompletion = 0.0,
    this.documentStatuses = const {},
    this.documentFilePaths = const {},
    this.creditScore = 0.0,
    this.phoneNumber,
    this.currentSemester = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'student_id': studentId,
      'department': department,
      'admission_type': admissionType,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'date_of_joining': dateOfJoining.toIso8601String(),
      'mentor_id': mentorId,
      // Frontend calculated or joined
      'mentorName': mentorName,
      'mentorCode': mentorCode,
      'groupLeaderName': groupLeaderName,
      'currentCGPA': currentCGPA,
      'totalInternships': totalInternships,
      'certificationPoints': certificationPoints,
      'pendingTasks': pendingTasks,
      'upcomingMeetings': upcomingMeetings,
      'unreadBroadcasts': unreadBroadcasts,
      'documentCompletion': documentCompletion,
      'documentStatuses': documentStatuses,
      'documentFilePaths': documentFilePaths,
      'creditScore': creditScore,
      'current_semester': currentSemester,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: (map['full_name'] ?? map['fullName'] ?? '').toString(),
      phoneNumber: (map['phone_number'] ?? map['phoneNumber'])?.toString(),
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      department: (map['department'] ?? '').toString(),
      admissionType:
          (map['admission_type'] ?? map['admissionType'] ?? 'Regular')
              .toString(),
      dateOfBirth: DateTime.parse((map['date_of_birth'] ??
              map['dateOfBirth'] ??
              DateTime.now().toIso8601String())
          .toString()),
      dateOfJoining: DateTime.parse((map['date_of_joining'] ??
              map['dateOfJoining'] ??
              DateTime.now().toIso8601String())
          .toString()),
      mentorId: (map['mentor_id'] ?? map['mentorId'])?.toString(),
      mentorName: (map['mentor_name'] ?? map['mentorName'])?.toString(),
      mentorCode: (map['mentor_code'] ?? map['mentorCode'])?.toString(),
      groupLeaderName:
          (map['group_leader_name'] ?? map['groupLeaderName'])?.toString(),
      currentCGPA: double.tryParse(
              (map['current_cgpa'] ?? map['currentCGPA'] ?? 0.0).toString()) ??
          0.0,
      totalInternships: int.tryParse(
              (map['total_internships'] ?? map['totalInternships'] ?? 0)
                  .toString()) ??
          0,
      certificationPoints: int.tryParse(
              (map['certification_points'] ?? map['certificationPoints'] ?? 0)
                  .toString()) ??
          0,
      pendingTasks: int.tryParse(
              (map['pending_tasks'] ?? map['pendingTasks'] ?? 0).toString()) ??
          0,
      upcomingMeetings: int.tryParse(
              (map['upcoming_meetings'] ?? map['upcomingMeetings'] ?? 0)
                  .toString()) ??
          0,
      unreadBroadcasts: int.tryParse(
              (map['unread_broadcasts'] ?? map['unreadBroadcasts'] ?? 0)
                  .toString()) ??
          0,
      documentCompletion: double.tryParse(
              (map['document_completion'] ?? map['documentCompletion'] ?? 0.0)
                  .toString()) ??
          0.0,
      documentStatuses: Map<String, String>.from(
          (map['document_statuses'] ?? map['documentStatuses'] ?? {})
              .map((k, v) => MapEntry(k.toString(), v.toString()))),
      documentFilePaths: Map<String, String>.from(
          (map['document_file_paths'] ?? map['documentFilePaths'] ?? {})
              .map((k, v) => MapEntry(k.toString(), v.toString()))),
      creditScore: double.tryParse(
              (map['credit_score'] ?? map['creditScore'] ?? 0.0).toString()) ??
          0.0,
      currentSemester: int.tryParse(
              (map['current_semester'] ?? map['currentSemester'] ?? 1)
                  .toString()) ??
          1,
    );
  }

  StudentModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? studentId,
    String? department,
    String? admissionType,
    DateTime? dateOfBirth,
    DateTime? dateOfJoining,
    String? mentorId,
    String? mentorName,
    String? mentorCode,
    String? groupLeaderName,
    double? currentCGPA,
    int? totalInternships,
    int? certificationPoints,
    int? pendingTasks,
    int? upcomingMeetings,
    int? unreadBroadcasts,
    double? documentCompletion,
    Map<String, String>? documentStatuses,
    Map<String, String>? documentFilePaths,
    double? creditScore,
    int? currentSemester,
  }) {
    return StudentModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      admissionType: admissionType ?? this.admissionType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      mentorCode: mentorCode ?? this.mentorCode,
      groupLeaderName: groupLeaderName ?? this.groupLeaderName,
      currentCGPA: currentCGPA ?? this.currentCGPA,
      totalInternships: totalInternships ?? this.totalInternships,
      certificationPoints: certificationPoints ?? this.certificationPoints,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      upcomingMeetings: upcomingMeetings ?? this.upcomingMeetings,
      unreadBroadcasts: unreadBroadcasts ?? this.unreadBroadcasts,
      documentCompletion: documentCompletion ?? this.documentCompletion,
      documentStatuses: documentStatuses ?? this.documentStatuses,
      documentFilePaths: documentFilePaths ?? this.documentFilePaths,
      creditScore: creditScore ?? this.creditScore,
      currentSemester: currentSemester ?? this.currentSemester,
    );
  }
}
