class LeaderboardMember {
  final String id;
  final String fullName;
  final double currentCGPA;
  final int certificationsCount;
  final int internshipsCount;
  final int completedTasksCount;
  final int attendedMeetingsCount;
  final double totalScore;

  LeaderboardMember({
    required this.id,
    required this.fullName,
    required this.currentCGPA,
    required this.certificationsCount,
    required this.internshipsCount,
    required this.completedTasksCount,
    required this.attendedMeetingsCount,
    required this.totalScore,
  });

  factory LeaderboardMember.fromMap(Map<String, dynamic> map) {
    return LeaderboardMember(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName'] ?? '',
      currentCGPA: (map['currentCGPA'] ?? 0.0).toDouble(),
      certificationsCount: map['certificationsCount'] ?? 0,
      internshipsCount: map['internshipsCount'] ?? 0,
      completedTasksCount: map['completedTasksCount'] ?? 0,
      attendedMeetingsCount: map['attendedMeetingsCount'] ?? 0,
      totalScore: (map['totalScore'] ?? 0.0).toDouble(),
    );
  }
}
