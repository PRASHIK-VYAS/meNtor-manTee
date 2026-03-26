import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/student_provider.dart';
import '../../models/meeting_model.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentMeetingsScreen extends StatelessWidget {
  const StudentMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          final meetings = provider.meetings;

          if (meetings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshMeetings(),
            color: Colors.black,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                return _buildMeetingCard(context, meetings[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_camera_front_outlined,
              size: 64, color: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            'NO MEETINGS SCHEDULED',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, MeetingModel meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    meeting.type.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  meeting.status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                    color: meeting.status == 'Scheduled'
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              meeting.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meeting.description,
              style:
                  TextStyle(color: Colors.black.withOpacity(0.6), height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoChip(Icons.calendar_today_outlined, meeting.date),
                const SizedBox(width: 16),
                _buildInfoChip(Icons.access_time, meeting.time),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: meeting.link.isEmpty
                    ? null
                    : () async {
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
                              SnackBar(
                                  content:
                                      Text('Invalid meeting link: ${meeting.link}')),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('JOIN VIA GOOGLE MEET',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
