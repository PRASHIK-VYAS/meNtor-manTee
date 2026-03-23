import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/meeting_log_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/mentor_provider.dart';

class ScheduleMeetingSheet extends StatefulWidget {
  final StudentModel? preFilledStudent;

  const ScheduleMeetingSheet({super.key, this.preFilledStudent});

  @override
  State<ScheduleMeetingSheet> createState() => _ScheduleMeetingSheetState();
}

class _ScheduleMeetingSheetState extends State<ScheduleMeetingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _agendaController = TextEditingController();
  
  bool _isGroupMeeting = false;
  StudentModel? _selectedStudent;
  final List<StudentModel> _selectedGroupStudents = [];
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.preFilledStudent;
  }

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    
    // Fallback if mentor not loaded yet (should be)
    if (mentorProvider.currentMentor == null) return const SizedBox.shrink();

    final mentor = mentorProvider.currentMentor!;

    // Populate students for dropdown
    final students = mentorProvider.assignedStudents;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedule Meeting',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Meeting Type Toggle (Only if not prefilled)
              if (widget.preFilledStudent == null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isGroupMeeting = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isGroupMeeting ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isGroupMeeting ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Individual',
                              style: TextStyle(
                                fontWeight: !_isGroupMeeting ? FontWeight.bold : FontWeight.normal,
                                color: !_isGroupMeeting ? Colors.black : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isGroupMeeting = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isGroupMeeting ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isGroupMeeting ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Group',
                              style: TextStyle(
                                fontWeight: _isGroupMeeting ? FontWeight.bold : FontWeight.normal,
                                color: _isGroupMeeting ? Colors.black : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Student Selection
              if (widget.preFilledStudent != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.preFilledStudent!.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else if (!_isGroupMeeting)
                DropdownButtonFormField<StudentModel>(
                  initialValue: _selectedStudent,
                  decoration: InputDecoration(
                    labelText: 'Select Student',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: students.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.fullName),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStudent = val),
                   validator: (val) => val == null && !_isGroupMeeting ? 'Please select a student' : null,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Students:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: students.map((s) {
                          final isSelected = _selectedGroupStudents.contains(s);
                          return CheckboxListTile(
                            title: Text(s.fullName),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedGroupStudents.add(s);
                                } else {
                                  _selectedGroupStudents.remove(s);
                                }
                              });
                            },
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          );
                        }).toList(),
                      ),
                    ),
                    if (_selectedGroupStudents.isEmpty) // Visual validation hint
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          'Select at least one student',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
  
              const SizedBox(height: 16),
  
              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text(_selectedTime.format(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
  
              const SizedBox(height: 16),
  
              // Agenda
              TextFormField(
                controller: _agendaController,
                decoration: InputDecoration(
                  labelText: 'Agenda / Topic',
                  prefixIcon: const Icon(Icons.topic_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter agenda' : null,
              ),
  
              const SizedBox(height: 24),
  
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Custom validation for Group Mode
                      if (_isGroupMeeting && _selectedGroupStudents.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one student for group meeting')),
                        );
                        return;
                      }
                      
                      // Custom validation for Individual Mode
                      if (!_isGroupMeeting && _selectedStudent == null && widget.preFilledStudent == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a student')),
                        );
                        return;
                      }

                      final meetingDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );

                      if (!_isGroupMeeting) {
                        // Individual Meeting
                        final student = _selectedStudent ?? widget.preFilledStudent!;
                        final meeting = MeetingLogModel(
                          id: const Uuid().v4(),
                          studentId: student.id,
                          mentorId: mentor.id,
                          date: meetingDate,
                          agenda: _agendaController.text,
                          discussion: '',
                          issues: '',
                          suggestions: '',
                          attended: false,
                          type: 'One-to-one', 
                        );
                        await mentorProvider.scheduleMeetingLog(meeting);
                      } else {
                        // Group Meeting
                         final newMeetings = _selectedGroupStudents.map((student) {
                          return MeetingLogModel(
                            id: const Uuid().v4(),
                            studentId: student.id,
                            mentorId: mentor.id,
                            date: meetingDate,
                            agenda: _agendaController.text,
                            discussion: '',
                            issues: '',
                            suggestions: '',
                            attended: false,
                            type: 'Group',
                          );
                        }).toList();
                        await mentorProvider.scheduleMultipleMeetings(newMeetings);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_isGroupMeeting ? 'Group meeting scheduled!' : 'Meeting Scheduled Successfully!')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SCHEDULE MEETING'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
