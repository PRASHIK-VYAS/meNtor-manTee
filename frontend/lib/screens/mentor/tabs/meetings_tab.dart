import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/mentor_provider.dart';

class MeetingsTab extends StatelessWidget {
  final String studentId;

  const MeetingsTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final meetings = mentorProvider.meetingLogs;

    if (meetings.isEmpty) {
      return const Center(child: Text('No meetings recorded yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              child: Icon(
                meeting.type == 'Group' ? Icons.groups : Icons.person,
                color: Colors.indigo,
              ),
            ),
            title: Text(
              DateFormat('MMM dd, yyyy').format(meeting.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${meeting.type} • ${meeting.attended ? "Attended" : "Absent"}'),
            trailing: meeting.attended 
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : const Icon(Icons.cancel, color: Colors.red, size: 20),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (meeting.agenda != null && meeting.agenda!.isNotEmpty) ...[
                      const Text('Agenda:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(meeting.agenda!),
                      const SizedBox(height: 8),
                    ],
                    const Text('Discussion:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(meeting.discussion),
                    const SizedBox(height: 8),
                    if (meeting.outcome != null && meeting.outcome!.isNotEmpty) ...[
                      const Text('Outcome:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(meeting.outcome!),
                      const SizedBox(height: 8),
                    ],
                    if (meeting.actionItems.isNotEmpty) ...[
                      const Text('Action Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...meeting.actionItems.map((item) => Text('• $item')),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
