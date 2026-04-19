import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentor_provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _handleApproval({
    required String id,
    required String type,
    required bool approve,
  }) async {
    String? rejectionReason;

    if (!approve) {
      final controller = TextEditingController();
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reject Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason for rejection',
              hintText: 'e.g. Invalid document link',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('REJECT'),
            ),
          ],
        ),
      );

      if (reason == null || reason.isEmpty) return;
      rejectionReason = reason;
    }

    try {
      await Provider.of<MentorProvider>(context, listen: false).reviewItem(
        type: type.toLowerCase(),
        id: id,
        status: approve ? 'Approved' : 'Rejected',
        rejectionReason: rejectionReason,
      );

      if (mounted) {
        setState(() {
          _pendingActivitiesFuture =
              Provider.of<MentorProvider>(context, listen: false)
                  .getPendingActivities();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Item Approved' : 'Item Rejected'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
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
            final item = pendingActivities[index];
            final type = item['type'] ?? 'Activity';
            final student = item['Student'] ?? {};

            String title = '';
            String details = '';
            String? proofUrl;
            IconData icon = Icons.event_note;

            if (type == 'Activity') {
              title = item['event_name'] ?? 'Unknown Event';
              details = 'Role: ${item['role'] ?? ''} | Level: ${item['level'] ?? ''}';
              proofUrl = item['proof_url'];
              icon = Icons.star_border_rounded;
            } else if (type == 'Internship') {
              title = item['company_name'] ?? 'Unknown Company';
              details = 'Role: ${item['role'] ?? ''} | Mode: ${item['mode'] ?? ''}';
              proofUrl = item['certificate_url'];
              icon = Icons.work_outline_rounded;
            } else if (type == 'Certification') {
              title = item['title'] ?? 'Unknown Certification';
              details = 'Issuer: ${item['issuer'] ?? ''} | Points: ${item['points'] ?? ''}';
              proofUrl = item['certificate_url'];
              icon = Icons.verified_user_outlined;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: Colors.black87),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: Colors.black38,
                              ),
                            ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BY: ${student['full_name']} (${student['student_id'] ?? ''})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item['date'] != null || item['start_date'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item['date'] ?? item['start_date']))}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                    if (proofUrl != null) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(proofUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'View Attachment',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 12, color: Colors.blue.shade300),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleApproval(
                              id: item['id'].toString(),
                              type: type,
                              approve: false,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('REJECT',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _handleApproval(
                              id: item['id'].toString(),
                              type: type,
                              approve: true,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('APPROVE',
                                style: TextStyle(fontWeight: FontWeight.w900)),
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
      },
    );
  }
}
