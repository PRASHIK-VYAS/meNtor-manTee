import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/mentor_provider.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import 'task_success_screen.dart';

class TaskAssignmentScreen extends StatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _proofRequired = true;
  final Set<String> _selectedStudentIds = {};
  String _studentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MentorProvider>(context, listen: false);
      if (provider.assignedStudents.isEmpty) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.userId != null) {
          provider.loadMentorData(auth.userId!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if (auth.userId != null) {
                  await Provider.of<MentorProvider>(context, listen: false)
                      .loadMentorData(auth.userId!);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('TASK DETAILS'),
                      const SizedBox(height: 16),
                      _buildTextField('TITLE', _titleController,
                          'e.g. Complete Unit 1 Assignment'),
                      const SizedBox(height: 20),
                      _buildTextField('DESCRIPTION', _descController,
                          'Detailed instructions...',
                          maxLines: 3),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('DEADLINE'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickDate,
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
                                        Text(DateFormat('MMM dd, yyyy')
                                            .format(_selectedDate)),
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
                                _buildSectionTitle('REQUIREMENTS'),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  value: _proofRequired,
                                  onChanged: (val) =>
                                      setState(() => _proofRequired = val),
                                  title: const Text('PROOF',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('SELECT RECIPIENTS'),
                          Consumer<MentorProvider>(
                            builder: (context, provider, child) {
                              final allStudentsIds = provider.assignedStudents
                                  .map((s) => s.id)
                                  .toSet();
                              final allSelected = allStudentsIds.isNotEmpty &&
                                  allStudentsIds.every(
                                      (id) => _selectedStudentIds.contains(id));

                              return Row(
                                children: [
                                  if (_selectedStudentIds.isNotEmpty)
                                    TextButton(
                                      onPressed: () => setState(
                                          () => _selectedStudentIds.clear()),
                                      child: const Text('CLEAR ALL',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.red)),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (allSelected) {
                                          _selectedStudentIds.clear();
                                        } else {
                                          _selectedStudentIds
                                              .addAll(allStudentsIds);
                                        }
                                      });
                                    },
                                    child: Text(
                                      allSelected
                                          ? 'DESELECT ALL'
                                          : 'SELECT ALL',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStudentSelector(),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: Colors.black45,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1.5,
          color: Colors.black38),
    );
  }

  Widget _buildStudentSelector() {
    return Consumer<MentorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.assignedStudents.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: Colors.black),
          ));
        }

        var students = provider.assignedStudents;

        // Apply search filter if text entered
        if (_studentSearchQuery.isNotEmpty) {
          students = students.where((s) {
            return s.fullName
                    .toLowerCase()
                    .contains(_studentSearchQuery.toLowerCase()) ||
                s.studentId
                    .toLowerCase()
                    .contains(_studentSearchQuery.toLowerCase());
          }).toList();
        }

        if (provider.assignedStudents.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child:
                Text('No students found', style: TextStyle(color: Colors.grey)),
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar for students
            TextField(
              decoration: InputDecoration(
                hintText: 'Search students by name or ID...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _studentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setState(() => _studentSearchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _studentSearchQuery = val),
            ),
            const SizedBox(height: 12),
            if (students.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No matching students',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 64),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isSelected = _selectedStudentIds.contains(student.id);

                    return ListTile(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedStudentIds.remove(student.id);
                          } else {
                            _selectedStudentIds.add(student.id);
                          }
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor:
                            isSelected ? Colors.black : Colors.white,
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text(student.fullName[0],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                      ),
                      title: Text(student.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(student.studentId,
                          style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('ASSIGN TASK',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one student')));
      return;
    }

    final mentorProvider = Provider.of<MentorProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final template = TaskModel(
      id: '',
      studentId: '', // To be filled by provider for single, or ignored for bulk
      mentorId: authProvider.userId ?? '',
      title: _titleController.text,
      description: _descController.text,
      deadline: _selectedDate,
      status: 'Pending',
      proofRequired: _proofRequired,
    );

    try {
      if (_selectedStudentIds.length == 1) {
        await mentorProvider.assignTask(
            template.copyWith(studentId: _selectedStudentIds.first));
      } else {
        await mentorProvider.assignBulkTasks(
            template, _selectedStudentIds.toList());
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TaskSuccessScreen(taskCount: _selectedStudentIds.length),
          ),
        );
        _titleController.clear();
        _descController.clear();
        setState(() => _selectedStudentIds.clear());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to assign tasks'),
            backgroundColor: Colors.red));
      }
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
