// frontend\lib\screens\mentor\create_meeting_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/meeting_model.dart';
import '../../providers/mentor_provider.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _agendaController = TextEditingController();
  final _linkController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _meetingType = 'Batch'; // 'Batch' or '1-on-1'
  String? _selectedStudentId;

  @override
  void dispose() {
    _topicController.dispose();
    _agendaController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _generateLink() {
    final randomId = const Uuid().v4().substring(0, 8);
    final topicSlug = _topicController.text.trim().replaceAll(RegExp(r'\s+'), '_');
    
    setState(() {
      _linkController.text = topicSlug.isNotEmpty 
          ? '${topicSlug}_$randomId' 
          : 'channel_$randomId';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_linkController.text.isEmpty) {
        _generateLink();
      }

      final mentorProvider = Provider.of<MentorProvider>(context, listen: false);
      final mentor = mentorProvider.currentMentor;

      if (mentor == null) return;

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

// 1. We removed the unused 'dateTime' variable entirely.

      final meeting = MeetingModel(
        id: const Uuid().v4(),
        title: _topicController.text.trim(),
        description: _agendaController.text.trim(),
        
        // 2. Format the DateTime object into a String (e.g., "2024-05-20")
        date: DateFormat('yyyy-MM-dd').format(_selectedDate), 
        
        // 3. Format the TimeOfDay object into a String (e.g., "10:00 AM")
        time: _selectedTime.format(context), 
        
        link: _linkController.text.trim(),
        mentorId: mentor.id,
        batchId: _meetingType == 'Batch' ? mentor.activeBatch : null,
        studentId: _meetingType == '1-on-1' ? _selectedStudentId : null,
        status: 'Scheduled',
      );

      try {
        await mentorProvider.scheduleVideoMeeting(meeting);
        
        // Notify Students (Mock Broadcast)
        // In a real app, this would be a backend trigger. 
        // Here we simulate it by adding a notification to a local provider or DB.
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting scheduled & students notified!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meeting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Topic',
                  hintText: 'e.g., Weekly Project Review',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a topic' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _agendaController,
                decoration: const InputDecoration(
                  labelText: 'Agenda',
                  hintText: 'e.g., Discuss roadmap and blockers',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter an agenda' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _meetingType,
                decoration: const InputDecoration(
                  labelText: 'Meeting Type',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Batch', child: Text('Batch Meeting')),
                  DropdownMenuItem(value: '1-on-1', child: Text('1-on-1 Session')),
                ],
                onChanged: (value) {
                  setState(() {
                    _meetingType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_meetingType == '1-on-1')
                 Consumer<MentorProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedStudentId,
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: provider.assignedStudents.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.fullName} (${s.studentId})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                      },
                      validator: (value) => _meetingType == '1-on-1' && value == null
                          ? 'Please select a student'
                          : null,
                    );
                  },
                ),
              if (_meetingType == '1-on-1') const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Link',
                        hintText: 'https://meet.google.com/... or https://zoom.us/...',
                        prefixIcon: Icon(Icons.link),
                      ),
                      readOnly: false, // Allow manual entry
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please generate a link'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _generateLink,
                    child: const Text('Generate'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Schedule Meeting', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
