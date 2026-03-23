import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';

class MentorTasksScreen extends StatelessWidget {
  const MentorTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentId = authProvider.userId ?? '';

    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<StudentProvider>(context, listen: false)
            .loadStudentData(studentId),
        builder: (context, snapshot) {
          return Consumer<StudentProvider>(
            builder: (context, studentProvider, child) {
              final tasks = studentProvider.tasks;

              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks assigned',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isOverdue = task.deadline.isBefore(DateTime.now()) &&
                      task.status != 'Completed';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isOverdue
                              ? Colors.red.withOpacity(0.2)
                              : Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(task.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(task.status),
                          color: _getStatusColor(task.status),
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(task.status),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'DEADLINE: ${DateFormat('yyyy-MM-dd').format(task.deadline)}',
                                style: TextStyle(
                                  color: isOverdue
                                      ? Colors.red.shade800
                                      : Colors.black54,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DESCRIPTION',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              if (task.mentorRemarks != null) ...[
                                const SizedBox(height: 20),
                                const Text(
                                  'MENTOR REMARKS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    task.mentorRemarks!,
                                    style: TextStyle(
                                      color: Colors.orange.shade900,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              if (task.status == 'Pending' ||
                                  task.status == 'Submitted')
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // 1. Pick File
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'pdf',
                                          'doc',
                                          'docx',
                                          'png',
                                          'jpg',
                                          'jpeg'
                                        ],
                                      );

                                      if (result != null &&
                                          result.files.single.path != null) {
                                        final fileName =
                                            result.files.single.name;

                                        // 2. Show Confirmation Dialog with the selected file name
                                        if (context.mounted) {
                                          bool? confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              title: const Text(
                                                  'Confirm Submission',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: -0.5)),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.cloud_done_outlined,
                                                      size: 64,
                                                      color: Colors.black87),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                      'Are you sure you want to submit this file?'),
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF5F5F7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .insert_drive_file_outlined,
                                                            size: 20,
                                                            color:
                                                                Colors.black87),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                            child: Text(
                                                                fileName,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('CANCEL',
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                FilledButton(
                                                  style: FilledButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.black),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child:
                                                      const Text('SUBMIT TASK'),
                                                ),
                                              ],
                                            ),
                                          );

                                          // 3. Update Status to 'Submitted' and save file
                                          if (confirm == true &&
                                              context.mounted) {
                                            try {
                                              await Provider.of<
                                                          StudentProvider>(
                                                      context,
                                                      listen: false)
                                                  .submitTaskWithFile(
                                                      task.id, fileName);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                        'Task successfully submitted with file!'),
                                                    backgroundColor:
                                                        Colors.green.shade700,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Failed to submit: $e'),
                                                      backgroundColor:
                                                          Colors.red.shade800),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.upload_outlined),
                                    label: Text(
                                      task.status == 'Pending'
                                          ? 'MARK AS COMPLETED'
                                          : 'UPDATE SUBMISSION',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                          fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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
}
