import 'package:flutter/material.dart';
import '../../models/student_model.dart';

class StudentAiInsightScreen extends StatelessWidget {
  final StudentModel student;

  const StudentAiInsightScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Performance Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.shade50,
                  child: Text(
                    student.fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${student.studentId} | ${student.department}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // AI Insight Cards
            _buildInsightSection(
              context,
              'Strength Areas',
              [
                'Consistent SGPA above 7.0 in core technical subjects.',
                'Proactive completion of internship hours.',
                'Excellent participation in technical workshops.',
              ],
              Colors.green,
              Icons.thumb_up_alt_outlined,
            ),
            const SizedBox(height: 16),
            _buildInsightSection(
              context,
              'Weak Areas / Risks',
              [
                 if (student.currentCGPA < 6.5) 'Current CGPA (${student.currentCGPA}) is below the placement threshold.',
                 if (student.documentCompletion < 70) 'Profile compliance is low (${student.documentCompletion}% documents).',
                 'Noticeable decline in task submission speed last month.',
              ],
              Colors.red,
              Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 16),
            _buildInsightSection(
              context,
              'Suggested Actions',
              [
                'Schedule a 1-on-1 career guidance session.',
                'Recommend focused study for upcoming semester exams.',
                'Remind student to upload pending 12th marksheet and ID proof.',
              ],
              Colors.blue,
              Icons.auto_awesome_outlined,
            ),
            const SizedBox(height: 16),
            _buildInsightSection(
              context,
              'Trend Analysis',
              [
                'Academic Trend: Stable but needs a boost to hit 7.5.',
                'Task Trend: Declining (3 delayed tasks in 30 days).',
                'Overall Sentiment: Student seems persistent but overwhelmed.',
              ],
              Colors.orange,
              Icons.trending_up_rounded,
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'AI Insights are generated based on cross-referenced data from academics, tasks, and document compliance. This is for reference; please use your professional judgment.',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context, String title, List<String> points, Color color, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.1)),
      ),
      color: color.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: CircleAvatar(radius: 3, backgroundColor: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
