import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/certification_model.dart';

class AddCertificationScreen extends StatefulWidget {
  final CertificationModel? certification;
  const AddCertificationScreen({super.key, this.certification});

  @override
  State<AddCertificationScreen> createState() => _AddCertificationScreenState();
}

class _AddCertificationScreenState extends State<AddCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _eventController;
  late final TextEditingController _issuerController;

  String _category = 'Internal'; // Internal / External
  String _type = 'Technical'; // Technical / Cultural / etc.
  String _level = 'College'; // College / State / National
  DateTime? _date;
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _eventController = TextEditingController(text: widget.certification?.title);
    _issuerController =
        TextEditingController(text: widget.certification?.issuer);

    if (widget.certification != null) {
      _category = widget.certification!.category.isNotEmpty
          ? widget.certification!.category
          : 'Internal';
      _type = widget.certification!.type.isNotEmpty
          ? widget.certification!.type
          : 'Technical';
      _level = widget.certification!.level.isNotEmpty
          ? widget.certification!.level
          : 'College';
      _date = widget.certification!.date;
      _selectedFilePath = widget.certification!.certificateUrl;
      if (_selectedFilePath != null) {
        _selectedFileName = _selectedFilePath!.split('/').last;
      }
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    _issuerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
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
      if (_selectedFilePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a certificate file')),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);

      final certification = CertificationModel(
        id: widget.certification?.id ?? '',
        studentId: authProvider.userId!,
        title: _eventController.text.trim(),
        issuer: _issuerController.text.trim(),
        date: _date!,
        points: widget.certification?.points ?? 0,
        category: _category,
        type: _type,
        level: _level,
        certificateUrl: _selectedFilePath,
        isVerified: widget.certification?.isVerified ?? false,
      );

      await studentProvider.updateCertification(certification);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.certification == null
                  ? 'Certification submitted for approval!'
                  : 'Certification updated successfully!')),
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
    final bool isEdit = widget.certification != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Certification' : 'Add Certification'),
      ),
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
                  prefixIcon: Icon(Icons.emoji_events_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: 'Issuing Organization',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter organization name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Internal',
                      child: Text('Internal (College Level)')),
                  DropdownMenuItem(
                      value: 'External',
                      child: Text('External (Out of College)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.tips_and_updates_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Technical', child: Text('Technical')),
                  DropdownMenuItem(value: 'Cultural', child: Text('Cultural')),
                  DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                  DropdownMenuItem(value: 'Social', child: Text('Social')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _level,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'College', child: Text('College')),
                  DropdownMenuItem(value: 'State', child: Text('State')),
                  DropdownMenuItem(value: 'National', child: Text('National')),
                  DropdownMenuItem(
                      value: 'International', child: Text('International')),
                ],
                onChanged: (value) {
                  setState(() {
                    _level = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Achievement',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _date != null
                        ? DateFormat('yyyy-MM-dd').format(_date!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // File Picker UI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                        _selectedFileName != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 48,
                        color: _selectedFileName != null
                            ? Colors.green
                            : Colors.indigo),
                    const SizedBox(height: 8),
                    Text(_selectedFileName ?? 'Upload Certificate (PDF/Image)'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _pickFile,
                      child: const Text('Choose File'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              FilledButton(
                onPressed: _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEdit ? 'Update Certification' : 'Submit for Approval',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
