import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentor_provider.dart';
import 'sheets/schedule_meeting_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force refresh
    final mentorProvider = Provider.of<MentorProvider>(context);
    final meetings = mentorProvider.meetings;
    final assignedStudents = mentorProvider.assignedStudents;
        
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Meetings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
                showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ScheduleMeetingSheet(),
              );
            },
          ),
        ],
      ),
      body: meetings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No meetings scheduled',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                        showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ScheduleMeetingSheet(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Schedule Meeting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                // Find student manually since we only have studentId
                // Use a simpler approach than list comprehension which might fail if empty
                var studentName = 'Unknown Student';
                try {
                  final student = assignedStudents.firstWhere((s) => s.id == meeting.studentId);
                  studentName = student.fullName;
                } catch (e) {
                  // Student might not be assigned or found
                }
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: const Color(0xFFF5F5F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                 const Icon(Icons.calendar_month, size: 16, color: Colors.black54),
                                 const SizedBox(width: 8),
                                 Text(
                                   '${meeting.date} • ${meeting.time}',
                                   style: const TextStyle(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 14,
                                   ),
                                 ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: meeting.status == 'Scheduled'
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    meeting.status.toUpperCase(),
                                    style: TextStyle(
                                      color: meeting.status == 'Scheduled'
                                          ? Colors.blue
                                          : Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black,
                                child: Text(
                                  studentName.isNotEmpty ? studentName[0] : '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                studentName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                           Text(
                             'Topic: ${meeting.title}',
                             style: const TextStyle(fontWeight: FontWeight.bold),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             meeting.description,
                             style: const TextStyle(color: Colors.black87),
                           ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (meeting.link.isNotEmpty)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final trimmedLink = meeting.link.trim();
                                    final url = Uri.tryParse(trimmedLink.startsWith('http')
                                        ? trimmedLink
                                        : 'https://$trimmedLink');
                                    if (url != null) {
                                      try {
                                        final launched = await launchUrl(url,
                                            mode: LaunchMode.externalApplication);
                                        if (!launched && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Could not launch meeting link')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Error launching meeting: $e')),
                                          );
                                        }
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Invalid meeting link')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.videocam,
                                      color: Colors.white, size: 18),
                                  label: const Text('JOIN MEETING',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            if (meeting.link.isNotEmpty)
                              const SizedBox(width: 8),
                            if (meeting.link.isNotEmpty)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final updatedMeeting =
                                        meeting.copyWith(link: '');
                                    await mentorProvider
                                        .updateMeeting(updatedMeeting);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Link unsent!')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.link_off,
                                      color: Colors.black54, size: 18),
                                  label: const Text('UNSEND LINK',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side: const BorderSide(color: Colors.black12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            if (meeting.link.isEmpty)
                              const Expanded(
                                child: Center(
                                  child: Text('No link provided',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Meeting'),
                                    content: const Text(
                                        'Are you sure you want to delete this meeting? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            await mentorProvider
                                                .deleteMeeting(meeting.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Meeting deleted successfully')),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error deleting meeting: $e')),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('DELETE',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.05),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
