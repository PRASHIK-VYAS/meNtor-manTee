class SubjectMark {
  final String subjectName;
  final double internal;
  final double external;

  SubjectMark({
    required this.subjectName,
    required this.internal,
    required this.external,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject_name': subjectName,
      'ia1': internal,
      'ia2': external,
    };
  }

  factory SubjectMark.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SubjectMark(
      subjectName: (map['subject_name'] ?? map['subjectName'] ?? '')?.toString() ?? '',
      internal: parseDouble(map['ia1'] ?? map['internal']),
      external: parseDouble(map['ia2'] ?? map['external']),
    );
  }
}

class SemesterModel {
  final dynamic id; // Can be int (from backend) or String (temp/uuid)
  final dynamic studentId; // Can be int or String
  final int semesterNumber;
  final double sgpa;
  final double cgpa;
  final String resultStatus;
  final DateTime? resultDate;
  final bool hasBacklogs;
  final String? remarks;
  final List<SubjectMark> subjects;

  SemesterModel({
    required this.id,
    required this.studentId,
    required this.semesterNumber,
    required this.sgpa,
    required this.cgpa,
    required this.resultStatus,
    this.resultDate,
    this.hasBacklogs = false,
    this.remarks,
    this.subjects = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'semester_number': semesterNumber,
      'sgpa': sgpa,
      'cgpa': cgpa,
      'result_status': resultStatus,
      'remarks': remarks,
      'has_backlogs': hasBacklogs,
    };
  }

  factory SemesterModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SemesterModel(
      id: map['id'],
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      semesterNumber: int.tryParse((map['semester_number'] ?? map['semesterNumber'] ?? 0).toString()) ?? 0,
      sgpa: parseDouble(map['sgpa']),
      cgpa: parseDouble(map['cgpa']),
      resultStatus: (map['result_status'] ?? map['resultStatus'] ?? 'Pending').toString(),
      resultDate: (map['result_date'] ?? map['resultDate']) != null
          ? DateTime.tryParse((map['result_date'] ?? map['resultDate']).toString())
          : null,
      hasBacklogs: (map['has_backlogs'] ?? map['hasBacklogs'] ?? false).toString() == 'true' ||
                  (map['has_backlogs'] ?? map['hasBacklogs'] ?? 0).toString() == '1',
      remarks: map['remarks']?.toString(),
      subjects: map['SubjectMarks'] != null
          ? List<SubjectMark>.from(
              (map['SubjectMarks'] as List).map(
                (x) => SubjectMark.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  SemesterModel copyWith({
    String? id,
    String? studentId,
    int? semesterNumber,
    double? sgpa,
    double? cgpa,
    String? resultStatus,
    DateTime? resultDate,
    bool? hasBacklogs,
    String? remarks,
    List<SubjectMark>? subjects,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      sgpa: sgpa ?? this.sgpa,
      cgpa: cgpa ?? this.cgpa,
      resultStatus: resultStatus ?? this.resultStatus,
      resultDate: resultDate ?? this.resultDate,
      hasBacklogs: hasBacklogs ?? this.hasBacklogs,
      remarks: remarks ?? this.remarks,
      subjects: subjects ?? this.subjects,
    );
  }
}
