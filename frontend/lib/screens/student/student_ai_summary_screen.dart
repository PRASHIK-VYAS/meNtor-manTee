import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../services/ai_service.dart';

class StudentAiSummaryScreen extends StatefulWidget {
  const StudentAiSummaryScreen({super.key});

  @override
  State<StudentAiSummaryScreen> createState() => _StudentAiSummaryScreenState();
}

class _StudentAiSummaryScreenState extends State<StudentAiSummaryScreen> {
  AiReport? _report;
  bool _isLoading = false;
  final AiService _aiService = AiService();

  Future<void> _generateReport(StudentProvider studentProvider) async {
    final student = studentProvider.currentStudent;
    if (student == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final report = await _aiService.generateStudentReport(
        student: student,
        tasks: studentProvider.tasks,
        certifications: studentProvider.certifications,
      );

      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, child) {
          if (studentProvider.currentStudent == null) {
            return const Center(child: Text("Loading student data..."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AI Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey.shade100 : Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.purple)
                          : Icon(Icons.psychology, size: 64, color: Colors.purple.shade700),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI Performance Insight',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _report != null 
                          ? 'Generated on ${DateTime.now().toString().split(' ')[0]}' 
                          : 'Unlock your academic potential with AI analysis.',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                if (_report == null && !_isLoading)
                   Center(
                     child: FilledButton.icon(
                      onPressed: () => _generateReport(studentProvider),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('GENERATE REPORT'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), 
                      ),
                     ),
                   )
                else if (_report != null) 
                  ..._buildReportContent(_report!),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildReportContent(AiReport report) {
    return [
       // Summary Card (New Feature)
       Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  _buildRiskBadge(report.riskStatus),
                ],
               ),
               const Divider(height: 24),
               Text(
                 report.summary,
                 style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
               ),
            ],
          ),
        ),
       ),
       const SizedBox(height: 16),

       _buildAiSection(
        context,
        'Strengths',
        report.strengths,
        Colors.green,
        Icons.thumb_up_alt_outlined,
      ),
       const SizedBox(height: 16),
       
       _buildAiSection(
        context,
        'Areas for Improvement',
        report.improvements,
        Colors.orange,
        Icons.trending_up,
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
           'Disclaimer: This report is generated by AI based on your academic records, tasks, and mentor feedback. Please consult your mentor for official guidance.',
           style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
           textAlign: TextAlign.center,
         ),
       ),
       const SizedBox(height: 16),
       TextButton.icon(
         onPressed: () => setState(() => _report = null),
         icon: const Icon(Icons.refresh),
         label: const Text("Generate New Report"),
         style: TextButton.styleFrom(foregroundColor: Colors.grey),
       )
    ];
  }

  Widget _buildRiskBadge(String status) {
    Color color;
    switch (status) {
      case 'High': color = Colors.red; break;
      case 'Medium': color = Colors.orange; break;
      case 'Low': color = Colors.green; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        'RISK: ${status.toUpperCase()}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildAiSection(BuildContext context, String title, List<String> points, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            if (points.isNotEmpty) ...[
              const Divider(height: 24),
                  ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CircleAvatar(radius: 3, backgroundColor: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(point, style: const TextStyle(fontSize: 15, height: 1.4))),
                  ],
                ),
              )),
            ] else 
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("None detected", style: TextStyle(color: Colors.grey)),
              )
          ],
        ),
      ),
    );
  }
}
