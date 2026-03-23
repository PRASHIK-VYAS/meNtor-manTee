import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentor_provider.dart';
import 'package:intl/intl.dart';

class MentorActivityApprovalScreen extends StatefulWidget {
  const MentorActivityApprovalScreen({super.key});

  @override
  State<MentorActivityApprovalScreen> createState() =>
      _MentorActivityApprovalScreenState();
}

class _MentorActivityApprovalScreenState
    extends State<MentorActivityApprovalScreen> {
  late Future<List<Map<String, dynamic>>> _pendingActivitiesFuture;

  @override
  void initState() {
    super.initState();
    _pendingActivitiesFuture =
        Provider.of<MentorProvider>(context, listen: false)
            .getPendingActivities();
  }

  void _handleApproval(String activityId, bool approve) async {
    try {
      await Provider.of<MentorProvider>(context, listen: false)
          .reviewActivity(activityId, approve);
      if (mounted) {
        setState(() {
          _pendingActivitiesFuture =
              Provider.of<MentorProvider>(context, listen: false)
                  .getPendingActivities();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve
                ? 'Activity Approved'
                : 'Activity Rejected (Pending deleted/handled)'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating activity: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pendingActivitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading activities: ${snapshot.error}'));
        }

        final pendingActivities = snapshot.data ?? [];

        if (pendingActivities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('All activities reviewed!',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingActivities.length,
          itemBuilder: (context, index) {
            final activity = pendingActivities[index];
            final student = activity['Student'] ?? {};

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(activity['event_name'] ?? 'Unknown Event',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                              'By ${student['full_name']} • ${student['student_id'] ?? ''}'),
                          const SizedBox(height: 4),
                          Text(
                              'Role: ${activity['role'] ?? ''} | Level: ${activity['level'] ?? ''}'),
                          Text(
                              'Date: ${activity['date'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(activity['date'])) : ''}'),
                        ],
                      ),
                      trailing: activity['proof_url'] != null
                          ? const Icon(Icons.attach_file, color: Colors.indigo)
                          : null,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              _handleApproval(activity['id'].toString(), false),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () =>
                              _handleApproval(activity['id'].toString(), true),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
