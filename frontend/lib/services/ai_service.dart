import '../models/student_model.dart';
import '../models/task_model.dart';
import '../models/certification_model.dart';

// --- Student Report (Student View) ---
class AiReport {
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String riskStatus; // 'Low', 'Medium', 'High'

  AiReport({
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.riskStatus,
  });
}

// --- Mentor Insight (Mentor View) ---
class MentorStudentInsight {
  final String riskStatus;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestedActions;
  final String trendAnalysis; // Improving / Stable / Declining

  MentorStudentInsight({
    required this.riskStatus,
    required this.strengths,
    required this.weaknesses,
    required this.suggestedActions,
    required this.trendAnalysis,
  });
}

// --- Batch Insight ---
class BatchInsight {
  final String summary;
  final String prioritySuggestion;

  BatchInsight({
    required this.summary,
    required this.prioritySuggestion,
  });
}

class AiService {
  // Singleton pattern
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // ---------------------------------------------------------------------------
  // 1. Student Self-View Report
  // ---------------------------------------------------------------------------
  Future<AiReport> generateStudentReport({
    required StudentModel student,
    required List<TaskModel> tasks,
    required List<CertificationModel> certifications,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Calculate metrics
    final completedTasks = tasks.where((t) => t.status == 'Completed').length;
    final overdueTasks = tasks.where((t) => 
        t.status != 'Completed' && t.deadline.isBefore(DateTime.now())).length;
    final totalTasks = tasks.length;
    final cgpa = student.currentCGPA;
    final docCompletion = student.documentCompletion;
    final certPoints = student.certificationPoints;

    // Risk Assessment
    String risk = 'Low';
    int riskScore = 0;
    if (cgpa < 6.5) riskScore += 2;
    if (cgpa < 7.5 && cgpa >= 6.5) riskScore += 1;
    if (docCompletion < 50) riskScore += 1;
    if (overdueTasks > 0) riskScore += 1;
    if (riskScore >= 3) {
      risk = 'High';
    } else if (riskScore >= 1) {
      risk = 'Medium';
    }

    // Strengths
    final strengths = <String>[];
    if (cgpa >= 8.0) strengths.add('Excellent academic performance with consistent high grades.');
    if (cgpa >= 7.0 && cgpa < 8.0) strengths.add('Stable academic record with potential for growth.');
    if (certPoints >= 5) strengths.add('Strong engagement in additional certifications.');
    if (completedTasks == totalTasks && totalTasks > 0) strengths.add('Reliable task submission record.');
    if (docCompletion > 90) strengths.add('Excellent documentation compliance.');
    if (strengths.isEmpty) strengths.add('Maintains regular attendance and communication.');

    // Improvements
    final improvements = <String>[];
    if (docCompletion < 80) improvements.add('Prioritize uploading pending documents to reach 100% completion.');
    if (cgpa < 7.0) improvements.add('Focus on core subjects to improve SGPA.');
    if (certPoints < 5) improvements.add('Enroll in more technical certifications to boost skill breadth.');
    if (overdueTasks > 0) improvements.add('Clear the $overdueTasks overdue tasks immediately.');
    
    // Summary
    String summary = '';
    if (risk == 'Low') {
      summary = '${student.fullName} is demonstrating solid progress. With a CGPA of ${cgpa.toStringAsFixed(2)}, they are on a good track. Continuing to focus on certifications and maintaining this momentum will yield great results.';
    } else if (risk == 'Medium') {
      summary = '${student.fullName} has a respectable foundation but needs to address a few gaps. While SGPA is stable, attention is needed on ${overdueTasks > 0 ? "task deadlines" : "documentation"} to ensure a smooth semester.';
    } else {
      summary = 'Immediate attention is required for ${student.fullName}. Current performance indicators suggest challenges that need intervention, particularly regarding ${cgpa < 6.5 ? "academic scores" : "compliance tasks"}.';
    }

    return AiReport(
      summary: summary,
      strengths: strengths.take(3).toList(),
      improvements: improvements.take(3).toList(),
      riskStatus: risk,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Mentor Insight (Individual Student)
  // ---------------------------------------------------------------------------
  Future<MentorStudentInsight> generateMentorStudentInsight({
    required StudentModel student,
    required List<TaskModel> tasks,
    required List<CertificationModel> certifications,
    required double previousCgpa, // To determine trend
    required int meetingsAttended,
    required int daysSinceInteraction,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final cgpa = student.currentCGPA;
    final overdueTasks = tasks.where((t) => t.status != 'Completed' && t.deadline.isBefore(DateTime.now())).length;
    final docCompletion = student.documentCompletion;

    // 1. Risk Status
    String risk = 'Normal';
    if (cgpa < 6.0 || docCompletion < 30 || overdueTasks > 2) {
      risk = 'High Risk';
    } else if (cgpa < 7.0 || docCompletion < 60 || overdueTasks > 0) {
      risk = 'Attention Needed';
    }

    // 2. Trend Analysis
    String trend = 'Stable';
    if (cgpa > previousCgpa + 0.2) trend = 'Improving (CGPA up from $previousCgpa)';
    if (cgpa < previousCgpa - 0.2) trend = 'Declining (CGPA down from $previousCgpa)';

    // 3. Strengths
    final strengths = <String>[];
    if (cgpa >= 7.5) strengths.add('Good academic standing.');
    if (student.certificationPoints >= 5) strengths.add('Active in skill development.');
    if (overdueTasks == 0) strengths.add('Timely task completion.');
    if (strengths.isEmpty) strengths.add('Regular communication.');

    // 4. Weak Areas
    final weaks = <String>[];
    if (cgpa < 6.5) weaks.add('Low academic performance.');
    if (docCompletion < 100) weaks.add('Incomplete documentation ($docCompletion%).');
    if (daysSinceInteraction > 14) weaks.add('Low mentor interaction (Last: $daysSinceInteraction days ago).');
    if (overdueTasks > 0) weaks.add('$overdueTasks tasks overdue.');

    // 5. Suggested Actions
    final actions = <String>[];
    if (risk == 'High Risk') actions.add('Schedule an immediate 1:1 intervention meeting.');
    if (docCompletion < 80) actions.add('Send a reminder for pending documents.');
    if (cgpa < 6.5) actions.add('Refer to peer tutoring or remedial classes.');
    if (actions.isEmpty) actions.add('Send a commendation message for good progress.');

    return MentorStudentInsight(
      riskStatus: risk,
      strengths: strengths.take(3).toList(),
      weaknesses: weaks.take(3).toList(),
      suggestedActions: actions.take(2).toList(),
      trendAnalysis: trend,
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Batch Insight (Dashboard)
  // ---------------------------------------------------------------------------
  Future<BatchInsight> generateBatchInsight({
    required List<StudentModel> students,
    required List<TaskModel> allTasks,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (students.isEmpty) {
      return BatchInsight(summary: "No students assigned.", prioritySuggestion: "Assign students to start tracking.");
    }

    int highRisk = 0;
    int attention = 0;
    int lowDoc = 0;
    double totalCgpa = 0;

    for (var s in students) {
      // Simple risk logic for batch
      bool isHigh = s.currentCGPA < 6.0 || s.documentCompletion < 30;
      bool isAttn = !isHigh && (s.currentCGPA < 7.0 || s.documentCompletion < 60);

      if (isHigh) highRisk++;
      if (isAttn) attention++;
      if (s.documentCompletion < 50) lowDoc++;
      totalCgpa += s.currentCGPA;
    }

    final avgCgpa = totalCgpa / students.length;
    final pendingReview = allTasks.where((t) => t.status == 'Submitted').length;

    String summary = 'Your batch of ${students.length} students has an average CGPA of ${avgCgpa.toStringAsFixed(2)}. '
        'Currently, $highRisk students are High Risk and $attention need attention. '
        'There are $lowDoc students with critically low documentation compliance.';

    String suggestion = '';
    if (highRisk > 0) {
      suggestion = 'Prioritize meeting with the $highRisk high-risk students this week.';
    } else if (lowDoc > 0) {
      suggestion = 'Send a broadcast message regarding document submission deadlines.';
    } else if (pendingReview > 0) {
      suggestion = 'Review the $pendingReview pending task submissions.';
    } else {
      suggestion = 'Everything looks good. Consider assigning a new skill-building task.';
    }

    return BatchInsight(
      summary: summary,
      prioritySuggestion: suggestion,
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Risk Explanation (Tooltip/Dialog)
  // ---------------------------------------------------------------------------
  String explainRiskCategory({
    required String riskCategory,
    required StudentModel student,
    required int pendingTasks,
    required int daysSinceInteraction,
  }) {
    if (riskCategory == 'High Risk') {
      if (student.currentCGPA < 6.0) return "Classified as High Risk primarily due to critical academic performance (CGPA < 6.0).";
      if (student.documentCompletion < 30) return "Classified as High Risk due to severe lack of documentation compliance (< 30%).";
      return "Classified as High Risk due to a combination of overdue tasks and low engagement.";
    } else if (riskCategory == 'Attention Needed') {
      if (student.currentCGPA < 7.0) return "Needs attention as CGPA is below the 7.0 threshold, indicating potential academic struggle.";
      if (student.documentCompletion < 60) return "Needs attention due to lagging document submissions.";
      if (daysSinceInteraction > 14) return "Needs attention because there has been no mentor interaction for over 2 weeks.";
      return "Flagged for attention due to pending overdue tasks.";
    }
    return "Student is in the Normal category with all metrics within acceptable ranges.";
  }
}
