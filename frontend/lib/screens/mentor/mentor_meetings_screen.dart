import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/mentor_provider.dart';
import '../../models/meeting_model.dart';
import 'create_meeting_screen.dart';

class MentorMeetingsScreen extends StatelessWidget {
  const MentorMeetingsScreen({super.key});

  // Parse MeetingModel's date+time strings into a DateTime for comparison
  DateTime _parseMeetingDateTime(MeetingModel meeting) {
    try {
      // date: 'YYYY-MM-DD', time: 'HH:mm' or 'HH:mm:ss'
      final parts = '${meeting.date} ${meeting.time}'.trim();
      return DateTime.parse(
          parts.replaceAll('T', ' ').substring(0, 16).padRight(16, '0'));
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MentorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No meetings scheduled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + button to schedule a meeting',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final sortedMeetings = [...provider.meetings];
          sortedMeetings.sort((a, b) =>
              _parseMeetingDateTime(a).compareTo(_parseMeetingDateTime(b)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedMeetings.length,
            itemBuilder: (context, index) {
              final meeting = sortedMeetings[index];
              return _buildMeetingCard(context, meeting);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateMeetingScreen()),
          );
        },
        label: const Text('Schedule Meeting'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, MeetingModel meeting) {
    final meetingDt = _parseMeetingDateTime(meeting);
    final isUpcoming = meetingDt.isAfter(DateTime.now());
    final dateStr = meeting.date.isNotEmpty
        ? DateFormat('EEE, MMM d').format(meetingDt)
        : 'TBD';
    final timeStr =
        meeting.time.isNotEmpty ? DateFormat('h:mm a').format(meetingDt) : '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isUpcoming ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUpcoming
                          ? Colors.blue.shade200
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Past',
                    style: TextStyle(
                      color: isUpcoming
                          ? Colors.blue.shade900
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  timeStr.isNotEmpty ? '$dateStr • $timeStr' : dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meeting.title, // was meeting.topic — use correct field
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (meeting.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meeting.description, // was meeting.agenda
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (meeting.batchId != null)
                  const Chip(
                    label: Text('Batch'),
                    avatar: Icon(Icons.groups, size: 16),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  const Chip(
                    label: Text('1-on-1'),
                    avatar: Icon(Icons.person, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                const Spacer(),
                if (isUpcoming && meeting.link.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      if (meeting.link.isEmpty) return;
                      final url = Uri.parse(meeting.link.startsWith('http')
                          ? meeting.link
                          : 'https://${meeting.link}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Cannot open link: ${meeting.link}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text('Join'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
