import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/mentor_provider.dart';
import '../../services/ai_service.dart';
import 'sheets/schedule_meeting_sheet.dart';

class MentorAiInsightsScreen extends StatelessWidget {
  const MentorAiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final mentor = mentorProvider.currentMentor;

    if (mentor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.purple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Batch Insights',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Real-time analysis of your mentee cohort',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Batch Insight FutureBuilder
          FutureBuilder<BatchInsight>(
            future: AiService().generateBatchInsight(
              students: mentorProvider.assignedStudents,
              allTasks: [], 
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Colors.purple),
                ));
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("Unable to generate insights."));
              }

              final insight = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInsightCard(
                    context,
                    'Batch Overview',
                    insight.summary,
                    Colors.indigo,
                    Icons.analytics_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInsightCard(
                    context,
                    'Priority Suggestion',
                    insight.prioritySuggestion,
                    Colors.teal,
                    Icons.lightbulb_rounded,
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          Text(
            'High Priority Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          _buildPriorityActionList(context, mentorProvider),

          const SizedBox(height: 32),
          const Text(
            'Risk Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildRiskDistribution(mentorProvider),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String content, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityActionList(BuildContext context, MentorProvider provider) {
    final priorityStudents = provider.assignedStudents.where((s) {
      return s.currentCGPA < 6.5 || s.pendingTasks > 2 || s.documentCompletion < 60;
    }).toList();

    if (priorityStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'All students are on track! No immediate actions required.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: priorityStudents.length,
      itemBuilder: (context, index) {
        final student = priorityStudents[index];
        // Risk Calculation Logic
        String riskLevel = 'Attention';
        Color riskColor = Colors.orange;
        if (student.currentCGPA < 6.5 || student.pendingTasks > 2) {
          riskLevel = 'High Risk';
          riskColor = Colors.red;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: riskColor.withOpacity(0.1),
                      child: Text(
                        student.fullName.substring(0, 1).toUpperCase(),
                         style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '$riskLevel • CGPA: ${student.currentCGPA.toStringAsFixed(2)}',
                            style: TextStyle(color: riskColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty) {
                            final Uri launchUri = Uri(scheme: 'tel', path: student.phoneNumber);
                            launchUrl(launchUri);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Contact Details Unavailable'),
                                content: const Text(
                                  'Student phone number is not verified. Use messaging or schedule a meeting.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.call, 
                          size: 16,
                          color: (student.phoneNumber != null && student.phoneNumber!.isNotEmpty) 
                              ? Colors.green 
                              : Colors.grey,
                        ),
                        label: Text(
                          'Call',
                          style: TextStyle(
                            color: (student.phoneNumber != null && student.phoneNumber!.isNotEmpty) 
                                ? Colors.black 
                                : Colors.grey,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black.withOpacity(0.1)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ScheduleMeetingSheet(preFilledStudent: student),
                          );
                        },
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: const Text('Schedule'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskDistribution(MentorProvider provider) {
    int highRisk = 0;
    int attention = 0;
    int normal = 0;

    for (var s in provider.assignedStudents) {
      if (s.currentCGPA < 6.0 || s.documentCompletion < 30) {
        highRisk++;
      } else if (s.currentCGPA < 7.0 || s.documentCompletion < 60) {
        attention++;
      } else {
        normal++;
      }
    }

    return Row(
      children: [
        Expanded(child: _buildStatCard('High Risk', highRisk.toString(), Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Attention', attention.toString(), Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('On Track', normal.toString(), Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
