import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/activity_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';

class AddActivityScreen extends StatefulWidget {
  final ActivityModel? activity;

  const AddActivityScreen({super.key, this.activity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventController = TextEditingController();
  final _roleController =
      TextEditingController(); // e.g., Participant, Winner, Coordinator

  String _level = 'College';
  DateTime? _date;
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _eventController.text = widget.activity!.eventName;
      _roleController.text = widget.activity!.role;
      _level = widget.activity!.level;
      _date = widget.activity!.date;
      _selectedFilePath = widget.activity!.proofUrl;
      // Get filename from path if it exists
      if (_selectedFilePath != null) {
        _selectedFileName = _selectedFilePath!.split('/').last;
      }
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && _date != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);

      final activity = ActivityModel(
        id: widget.activity?.id ?? '', // Empty string indicates new record
        studentId: authProvider.userId!,
        eventName: _eventController.text.trim(),
        role: _roleController.text.trim(),
        date: _date!,
        level: _level,
        proofUrl: _selectedFilePath,
        isVerified: widget.activity?.isVerified ?? false,
      );

      await studentProvider.updateActivity(activity);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.activity == null
                  ? 'Activity added successfully!'
                  : 'Activity updated successfully!')),
        );
      }
    } else if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.activity != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Activity' : 'Add Activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _eventController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  prefixIcon: Icon(Icons.event_note),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter event name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role / Achievement',
                  hintText: 'e.g. Participant, First Place, Organizer',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter your role' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  prefixIcon: Icon(Icons.layers_outlined),
                  border: OutlineInputBorder(),
                ),
                items: ['College', 'State', 'National', 'International']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) => setState(() => _level = val!),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _date != null
                        ? DateFormat('yyyy-MM-dd').format(_date!)
                        : 'Select Date',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // File Picker
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFileName != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                      size: 40,
                      color: _selectedFileName != null
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName ?? 'Upload Proof (Optional)',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickFile,
                      child: const Text('Select File'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _handleSubmit,
                style:
                    FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: Text(
                    isEditing ? 'Update Activity' : 'Submit for Approval',
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
