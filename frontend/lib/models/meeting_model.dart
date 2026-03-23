class MeetingModel {
  final String id;
  final String title;
  final String description;
  final String date; // meeting_date (YYYY-MM-DD)
  final String time; // meeting_time (HH:mm)
  final String link;
  final String mentorId;
  final String? batchId;
  final String? studentId;
  final String status;
  final String type;

  MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.link,
    required this.mentorId,
    this.batchId,
    this.studentId,
    this.status = 'Scheduled',
    this.type = 'One-on-One',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': int.tryParse(id),
      'title': title,
      'description': description,
      'meeting_date': date,
      'meeting_time': time,
      'link': link,
      'mentor_id': int.tryParse(mentorId),
      'batch_id': batchId,
      'student_id': studentId != null ? int.tryParse(studentId!) : null,
      'status': status,
      'type': type,
    };
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? map['topic'] ?? '').toString(),
      description: (map['description'] ?? map['agenda'] ?? '').toString(),
      date: (map['meeting_date'] ?? map['date'] ?? '').toString(),
      time: (map['meeting_time'] ?? map['time'] ?? '').toString(),
      link: (map['link'] ?? '').toString(),
      mentorId: (map['mentor_id'] ?? map['mentorId'] ?? '').toString(),
      batchId: (map['batch_id'] ?? map['batchId'] ?? '').toString(),
      studentId: (map['student_id'] ?? map['studentId'])?.toString(),
      status: (map['status'] ?? 'Scheduled').toString(),
      type: (map['type'] ?? 'One-on-One').toString(),
    );
  }

  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? link,
    String? mentorId,
    String? batchId,
    String? studentId,
    String? status,
    String? type,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      link: link ?? this.link,
      mentorId: mentorId ?? this.mentorId,
      batchId: batchId ?? this.batchId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}
