class MeetingLogModel {
  final String id;
  final String studentId;
  final String mentorId;
  final DateTime date;
  final String? type; // 'One-to-one' or 'Group'
  final String? agenda; // New
  final String? outcome; // New
  final bool attended; // New
  final String discussion;
  final String issues;
  final String suggestions;
  final List<String> actionItems;

  MeetingLogModel({
    required this.id,
    required this.studentId,
    required this.mentorId,
    required this.date,
    this.type = 'One-to-one',
    this.agenda,
    this.outcome,
    this.attended = true,
    required this.discussion,
    required this.issues,
    required this.suggestions,
    this.actionItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'mentorId': mentorId,
      'date': date.toIso8601String(),
      'type': type,
      'agenda': agenda,
      'outcome': outcome,
      'attended': attended,
      'discussion': discussion,
      'issues': issues,
      'suggestions': suggestions,
      'actionItems': actionItems,
    };
  }

  factory MeetingLogModel.fromMap(Map<String, dynamic> map) {
    return MeetingLogModel(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      mentorId: map['mentorId'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String? ?? 'One-to-one',
      agenda: map['agenda'] as String?,
      outcome: map['outcome'] as String?,
      attended: map['attended'] as bool? ?? true,
      discussion: map['discussion'] as String,
      issues: map['issues'] as String,
      suggestions: map['suggestions'] as String,
      actionItems: List<String>.from(map['actionItems'] as List? ?? []),
    );
  }
}
