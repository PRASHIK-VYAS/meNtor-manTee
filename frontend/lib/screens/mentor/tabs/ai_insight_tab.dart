import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mentor_provider.dart';
import '../../../services/ai_service.dart';

class AiInsightTab extends StatefulWidget {
  final String studentId;

  const AiInsightTab({super.key, required this.studentId});

  @override
  State<AiInsightTab> createState() => _AiInsightTabState();
}

class _AiInsightTabState extends State<AiInsightTab> {
  final AiService _aiService = AiService();
  MentorStudentInsight? _insight;
  bool _isLoading = false;

  Future<void> _generateInsight(MentorProvider provider) async {
    final student = provider.selectedStudent;
    if (student == null) return;

    setState(() => _isLoading = true);

    // Mock data for things we don't track yet
    // In a real app, these would come from the database/provider
    const previousCgpa = 7.0; 
    const meetingsAttended = 5;
    const daysSinceInteraction = 10;

    // Get tasks for this student
    // We need to access student specific data which might not be fully loaded in MentorProvider
    // effectively. For this mock, we will rely on the structure.
    // Ideally, we'd fetch tasks for this student specifically.
    // For now, let's pass an empty list if we can't easily get them, 
    // OR -- better -- we can get them if the provider has them.
    // Let's assume for this mock we generate based on the student object mostly.
    
    try {
      final insight = await _aiService.generateMentorStudentInsight(
        student: student,
        tasks: [], // passing empty for now as they are not loaded in this view context easily without extra calls
        certifications: [],
        previousCgpa: previousCgpa,
        meetingsAttended: meetingsAttended,
        daysSinceInteraction: daysSinceInteraction,
      );

      if (mounted) {
        setState(() {
          _insight = insight;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generation failed.')),
        );
      }
    }
  }

  void _showRiskExplanation(String risk, MentorProvider provider) {
    final student = provider.selectedStudent;
    if (student == null) return;

    final explanation = _aiService.explainRiskCategory(
      riskCategory: risk,
      student: student,
      pendingTasks: 1, // mock
      daysSinceInteraction: 10, // mock
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$risk Explanation'),
        content: Text(explanation),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MentorProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_insight == null && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.analytics_outlined, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Generate comprehensive AI insight for this student?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _generateInsight(provider),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('GENERATE INSIGHT'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.black),
                    ),
                  ],
                ),
              ),
            )
          else if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Colors.black),
            ))
          else if (_insight != null)
            Column(
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  color: _getRiskColor(_insight!.riskStatus).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _getRiskColor(_insight!.riskStatus), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.report_problem_rounded, color: _getRiskColor(_insight!.riskStatus)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OVERALL RISK STATUS',
                                style: TextStyle(
                                  color: _getRiskColor(_insight!.riskStatus),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10, 
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _insight!.riskStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: _getRiskColor(_insight!.riskStatus),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, size: 18),
                                    color: _getRiskColor(_insight!.riskStatus),
                                    onPressed: () => _showRiskExplanation(_insight!.riskStatus, provider),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Trend
                 _buildSection(
                  'Trend Analysis',
                  [_insight!.trendAnalysis],
                  Icons.trending_up,
                  Colors.blue,
                ),

                const SizedBox(height: 16),

                // Strengths
                _buildSection(
                  'Strength Areas',
                  _insight!.strengths,
                  Icons.check_circle_outline,
                  Colors.green,
                ),

                const SizedBox(height: 16),

                // Weaknesses
                _buildSection(
                  'Weak Areas',
                  _insight!.weaknesses,
                  Icons.warning_amber_rounded,
                  Colors.orange,
                ),

                const SizedBox(height: 16),

                // Actions
                _buildSection(
                  'Suggested Mentor Actions',
                  _insight!.suggestedActions,
                  Icons.checklist_rtl_rounded,
                  Colors.purple,
                ),
                
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => setState(() => _insight = null),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Insight'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                )
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'High Risk': return Colors.red;
      case 'Attention Needed': return Colors.orange;
      default: return Colors.green;
    }
  }
}
