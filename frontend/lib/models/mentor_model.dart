class MentorModel {
  final String id;
  final String email;
  final String fullName;
  final String department;
  final String? phoneNumber;
  final String password;
  final String mentorCode;
  final String? activeBatch;
  final List<String> assignedStudentIds;
  final int totalStudentsAssigned;
  final int studentsWithPendingTasks;
  final int studentsWithLowCGPA;
  final int totalDocumentApprovals;

  MentorModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.department,
    required this.password,
    required this.mentorCode,
    this.phoneNumber,
    this.activeBatch,
    this.assignedStudentIds = const [],
    this.totalStudentsAssigned = 0,
    this.studentsWithPendingTasks = 0,
    this.studentsWithLowCGPA = 0,
    this.totalDocumentApprovals = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'department': department,
      'password': password,
      'mentor_code': mentorCode,
      'phone_number': phoneNumber,
      'active_batch': activeBatch,
      'assignedStudentIds': assignedStudentIds,
      'totalStudentsAssigned': totalStudentsAssigned,
      'studentsWithPendingTasks': studentsWithPendingTasks,
      'studentsWithLowCGPA': studentsWithLowCGPA,
      'total_document_approvals': totalDocumentApprovals,
    };
  }

  factory MentorModel.fromMap(Map<String, dynamic> map) {
    return MentorModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: (map['full_name'] ?? map['fullName'] ?? '').toString(),
      department: map['department']?.toString() ?? '',
      phoneNumber: (map['phone_number'] ?? map['phoneNumber'])?.toString(),
      password: (map['password'] ?? '').toString(),
      mentorCode:
          (map['mentor_code'] ?? map['mentorCode'] ?? 'MTR-UNKNOWN').toString(),
      activeBatch: (map['active_batch'] ?? map['activeBatch'])?.toString(),
      assignedStudentIds: List<String>.from(
          (map['assignedStudentIds'] as List? ?? []).map((e) => e.toString())),
      totalStudentsAssigned:
          int.tryParse(map['totalStudentsAssigned']?.toString() ?? '0') ?? 0,
      studentsWithPendingTasks:
          int.tryParse(map['studentsWithPendingTasks']?.toString() ?? '0') ?? 0,
      studentsWithLowCGPA:
          int.tryParse(map['studentsWithLowCGPA']?.toString() ?? '0') ?? 0,
      totalDocumentApprovals: int.tryParse(
              (map['total_document_approvals'] ?? map['totalDocumentApprovals'])
                      ?.toString() ??
                  '0') ??
          0,
    );
  }

  MentorModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? department,
    String? password, // ✅ added
    String? mentorCode,
    String? phoneNumber,
    String? activeBatch,
    List<String>? assignedStudentIds,
    int? totalStudentsAssigned,
    int? studentsWithPendingTasks,
    int? studentsWithLowCGPA,
    int? totalDocumentApprovals,
  }) {
    return MentorModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      password: password ?? this.password, // ✅ added
      mentorCode: mentorCode ?? this.mentorCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      activeBatch: activeBatch ?? this.activeBatch,
      assignedStudentIds: assignedStudentIds ?? this.assignedStudentIds,
      totalStudentsAssigned:
          totalStudentsAssigned ?? this.totalStudentsAssigned,
      studentsWithPendingTasks:
          studentsWithPendingTasks ?? this.studentsWithPendingTasks,
      studentsWithLowCGPA: studentsWithLowCGPA ?? this.studentsWithLowCGPA,
      totalDocumentApprovals:
          totalDocumentApprovals ?? this.totalDocumentApprovals,
    );
  }
}
