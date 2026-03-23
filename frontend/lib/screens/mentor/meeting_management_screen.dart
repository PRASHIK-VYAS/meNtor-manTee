import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/mentor_provider.dart';
import '../../models/meeting_model.dart';
import '../../providers/auth_provider.dart';

class MeetingManagementScreen extends StatefulWidget {
  const MeetingManagementScreen({super.key});

  @override
  State<MeetingManagementScreen> createState() =>
      _MeetingManagementScreenState();
}

class _MeetingManagementScreenState extends State<MeetingManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MentorProvider>(
      builder: (context, provider, child) {
        final meetings = provider.meetings;

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showScheduleDialog(context),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('SCHEDULE',
                style:
                    TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          body: meetings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    return _buildMeetingCard(context, meetings[index]);
                  },
                ),
        );
      },
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
    final bool isCompleted = meeting.status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (meeting.link.isNotEmpty) {
                        final uri = Uri.tryParse(meeting.link);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Could not open meeting link')),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No meeting link available')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('JOIN MEETING',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    if (meeting.link.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: meeting.link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meeting link copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
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

  void _showScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final linkController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        DateTime selectedDate = DateTime.now();
        TimeOfDay selectedTime = TimeOfDay.now();
        String selectedType = 'One-on-One';

        return StatefulBuilder(
          builder: (sheetContext, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SCHEDULE MEETING',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 24),
                    _buildFieldLabel('TITLE'),
                    TextField(
                      controller: titleController,
                      decoration: _buildInputDecoration('Project Review...'),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel('DESCRIPTION'),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: _buildInputDecoration(
                          'Discussing architecture details...'),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel('MEETING LINK (GOOGLE MEET)'),
                    TextField(
                      controller: linkController,
                      decoration:
                          _buildInputDecoration('https://meet.google.com/...'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('DATE'),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: sheetContext,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setDialogState(() => selectedDate = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 18),
                                      const SizedBox(width: 12),
                                      Text(DateFormat('yyyy-MM-dd')
                                          .format(selectedDate)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('TIME'),
                              InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: sheetContext,
                                    initialTime: selectedTime,
                                  );
                                  if (picked != null) {
                                    setDialogState(() => selectedTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 18),
                                      const SizedBox(width: 12),
                                      Text(
                                          '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) return;

                          final auth = Provider.of<AuthProvider>(sheetContext,
                              listen: false);
                          final mentorId = auth.userId ?? '';

                          final meeting = MeetingModel(
                            id: '',
                            title: titleController.text,
                            description: descController.text,
                            date: DateFormat('yyyy-MM-dd').format(selectedDate),
                            time:
                                '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            link: linkController.text,
                            mentorId: mentorId,
                            type: selectedType,
                            status: 'Scheduled',
                          );

                          await Provider.of<MentorProvider>(sheetContext,
                                  listen: false)
                              .scheduleVideoMeeting(meeting);
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('CREATE MEETING',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1,
          color: Colors.black45,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
