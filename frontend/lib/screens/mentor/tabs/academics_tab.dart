import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mentor_provider.dart';
import '../../../models/semester_model.dart';

class AcademicsTab extends StatelessWidget {
  final String studentId;

  const AcademicsTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final semesters = mentorProvider.studentSemesters;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: semesters.length,
      itemBuilder: (context, index) {
        final semester = semesters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                'S${semester.semesterNumber}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Semester ${semester.semesterNumber}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SGPA: ${semester.sgpa.toStringAsFixed(2)}'),
                Text('CGPA: ${semester.cgpa.toStringAsFixed(2)}'),
                Text('Status: ${semester.resultStatus}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // Edit semester
                _showEditSemesterDialog(context, semester);
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showEditSemesterDialog(BuildContext context, SemesterModel semester) {
    final sgpaController =
        TextEditingController(text: semester.sgpa.toString());
    final cgpaController =
        TextEditingController(text: semester.cgpa.toString());
    String resultStatus = semester.resultStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Semester ${semester.semesterNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sgpaController,
              decoration: const InputDecoration(labelText: 'SGPA'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: cgpaController,
              decoration: const InputDecoration(labelText: 'CGPA'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              initialValue: resultStatus,
              decoration: const InputDecoration(labelText: 'Result Status'),
              items: const [
                DropdownMenuItem(value: 'Pass', child: Text('Pass')),
                DropdownMenuItem(value: 'Fail', child: Text('Fail')),
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              ],
              onChanged: (value) {
                resultStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updated = semester.copyWith(
                sgpa: double.tryParse(sgpaController.text) ?? semester.sgpa,
                cgpa: double.tryParse(cgpaController.text) ?? semester.cgpa,
                resultStatus: resultStatus,
              );
              Provider.of<MentorProvider>(context, listen: false)
                  .updateSemester(updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
