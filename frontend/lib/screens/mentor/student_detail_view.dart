import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentor_provider.dart';
import 'tabs/profile_tab.dart';

class StudentDetailView extends StatelessWidget {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final student = mentorProvider.selectedStudent;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Details')),
        body: const Center(child: Text('No student selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
      ),
      body: ProfileTab(studentId: student.id),
    );
  }
}
