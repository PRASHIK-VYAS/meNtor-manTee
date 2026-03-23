import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/mentor_provider.dart';
import '../../../models/task_model.dart';
import '../assign_task_screen.dart';

class TasksTab extends StatelessWidget {
  final String studentId;

  const TasksTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final tasks = mentorProvider.studentTasks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignTaskScreen(studentId: studentId),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Assign New Task'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(task.status),
                    child: Icon(
                      _getStatusIcon(task.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(task.title),
                  subtitle: Text('Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${task.description}'),
                          const SizedBox(height: 16),
                          Text('Status: ${task.status}'),
                          if (task.submissionUrl != null)
                            Text('Submission: Uploaded'),
                          if (task.mentorRemarks != null) ...[
                            const SizedBox(height: 16),
                            Text('Remarks: ${task.mentorRemarks}'),
                          ],
                          const SizedBox(height: 16),
                          if (task.status == 'Submitted')
                            FilledButton(
                              onPressed: () {
                                _showReviewDialog(context, task);
                              },
                              child: const Text('Review Task'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Submitted':
        return Colors.blue;
      case 'Reviewed':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending;
      case 'Submitted':
        return Icons.upload;
      case 'Reviewed':
        return Icons.rate_review;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  void _showReviewDialog(BuildContext context, TaskModel task) {
    final remarksController = TextEditingController();
    String reviewStatus = 'Reviewed';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                hintText: 'Enter your remarks...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: reviewStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'Reviewed', child: Text('Reviewed')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                reviewStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updated = task.copyWith(
                status: reviewStatus,
                mentorRemarks: remarksController.text,
                reviewedAt: DateTime.now(),
              );
              Provider.of<MentorProvider>(context, listen: false)
                  .reviewTask(updated);
              Navigator.pop(context);
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
