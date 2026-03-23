import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../models/meeting_log_model.dart';

class MeetingLogScreen extends StatefulWidget {
  final String studentId;

  const MeetingLogScreen({super.key, required this.studentId});

  @override
  State<MeetingLogScreen> createState() => _MeetingLogScreenState();
}

class _MeetingLogScreenState extends State<MeetingLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _discussionController = TextEditingController();
  final _issuesController = TextEditingController();
  final _suggestionsController = TextEditingController();
  final _actionItemController = TextEditingController();
  final _agendaController = TextEditingController(); // New
  final _outcomeController = TextEditingController(); // New
  DateTime? _meetingDate;
  String _meetingType = 'One-to-one'; // New
  bool _attended = true; // New
  final List<String> _actionItems = [];

  @override
  void dispose() {
    _discussionController.dispose();
    _issuesController.dispose();
    _suggestionsController.dispose();
    _actionItemController.dispose();
    _agendaController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _meetingDate = picked;
      });
    }
  }

  void _addActionItem() {
    if (_actionItemController.text.isNotEmpty) {
      setState(() {
        _actionItems.add(_actionItemController.text.trim());
        _actionItemController.clear();
      });
    }
  }

  void _removeActionItem(int index) {
    setState(() {
      _actionItems.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && _meetingDate != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final mentorProvider = Provider.of<MentorProvider>(context, listen: false);

      final meetingLog = MeetingLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: widget.studentId,
        mentorId: authProvider.userId!,
        date: _meetingDate!,
        type: _meetingType,
        agenda: _agendaController.text.trim(),
        outcome: _outcomeController.text.trim(),
        attended: _attended,
        discussion: _discussionController.text.trim(),
        issues: _issuesController.text.trim(),
        suggestions: _suggestionsController.text.trim(),
        actionItems: _actionItems,
      );

      await mentorProvider.addMeetingLog(meetingLog);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting log added successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meeting Log'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Meeting Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _meetingDate != null
                        ? DateFormat('yyyy-MM-dd').format(_meetingDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                initialValue: _meetingType,
                decoration: const InputDecoration(
                  labelText: 'Meeting Type',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                items: ['One-to-one', 'Group'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _meetingType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              CheckboxListTile(
                title: const Text('Student Attended'),
                value: _attended,
                onChanged: (bool? value) {
                  setState(() {
                    _attended = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _agendaController,
                decoration: const InputDecoration(
                  labelText: 'Agenda',
                  prefixIcon: Icon(Icons.list_alt_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _outcomeController,
                decoration: const InputDecoration(
                  labelText: 'Expected Outcome',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _discussionController,
                decoration: const InputDecoration(
                  labelText: 'Discussion',
                  prefixIcon: Icon(Icons.chat_outlined),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter discussion points';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _issuesController,
                decoration: const InputDecoration(
                  labelText: 'Issues',
                  prefixIcon: Icon(Icons.warning_outlined),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter issues';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _suggestionsController,
                decoration: const InputDecoration(
                  labelText: 'Suggestions',
                  prefixIcon: Icon(Icons.lightbulb_outlined),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter suggestions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Action Items
              Text(
                'Action Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _actionItemController,
                      decoration: const InputDecoration(
                        hintText: 'Enter action item',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addActionItem,
                  ),
                ],
              ),
              
              if (_actionItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                ..._actionItems.asMap().entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeActionItem(entry.key),
                      ),
                    ),
                  );
                }),
              ],
              
              const SizedBox(height: 30),
              
              FilledButton(
                onPressed: _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Meeting Log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
