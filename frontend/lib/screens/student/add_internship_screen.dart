import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/internship_model.dart';
import 'package:file_picker/file_picker.dart';

class AddInternshipScreen extends StatefulWidget {
  final InternshipModel? internship;
  const AddInternshipScreen({super.key, this.internship});

  @override
  State<AddInternshipScreen> createState() => _AddInternshipScreenState();
}

class _AddInternshipScreenState extends State<AddInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _roleController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  String _mode = 'Vacation';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _certificateUrl;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.internship?.companyName);
    _roleController = TextEditingController(text: widget.internship?.role);
    _durationController =
        TextEditingController(text: widget.internship?.duration);
    _descriptionController =
        TextEditingController(text: widget.internship?.description);

    if (widget.internship != null) {
      _mode = widget.internship!.mode;
      _startDate = widget.internship!.startDate;
      _endDate = widget.internship!.endDate;
      _certificateUrl = widget.internship!.certificateUrl;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickCertificate() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          // In a real app, you'd upload this to a storage service (S3, Firebase, etc.)
          // and get a URL. For now, we'll use the local path as a placeholder.
          _certificateUrl = result.files.single.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${result.files.single.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);

      final internship = InternshipModel(
        id: widget.internship?.id ?? '',
        studentId: authProvider.userId!,
        companyName: _companyController.text.trim(),
        role: _roleController.text.trim(),
        duration: _durationController.text.trim(),
        mode: _mode,
        description: _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        certificateUrl: _certificateUrl,
        isVerified: widget.internship?.isVerified ?? false,
      );

      await studentProvider.updateInternship(internship);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.internship == null
                  ? 'Internship added successfully!'
                  : 'Internship updated successfully!')),
        );
      }
    } else if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.internship != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Internship' : 'Add Internship'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g., 3 months)',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _mode,
                decoration: const InputDecoration(
                  labelText: 'Mode',
                  prefixIcon: Icon(Icons.commute_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Vacation', child: Text('Vacation')),
                  DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                ],
                onChanged: (value) {
                  setState(() {
                    _mode = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _startDate != null
                        ? DateFormat('yyyy-MM-dd').format(_startDate!)
                        : 'Select start date',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    _endDate != null
                        ? DateFormat('yyyy-MM-dd').format(_endDate!)
                        : 'Select end date',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Certificate Upload Button
              OutlinedButton.icon(
                onPressed: _pickCertificate,
                icon: Icon(_certificateUrl != null
                    ? Icons.check_circle
                    : Icons.upload_file),
                label: Text(_certificateUrl != null
                    ? 'Certificate Selected'
                    : 'Upload Internship Certificate'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor:
                      _certificateUrl != null ? Colors.green : null,
                  side: _certificateUrl != null
                      ? const BorderSide(color: Colors.green)
                      : null,
                ),
              ),
              if (_certificateUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'File: ${_certificateUrl!.split('/').last}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),

              FilledButton(
                onPressed: _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEdit ? 'Update Internship' : 'Add Internship',
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
