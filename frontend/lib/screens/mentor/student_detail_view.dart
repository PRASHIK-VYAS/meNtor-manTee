import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentor_provider.dart';
import 'tabs/profile_tab.dart';
import 'tabs/academics_tab.dart';
import 'tabs/internships_tab.dart';
import 'tabs/certifications_tab.dart';
import 'tabs/activities_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/ai_insight_tab.dart'; // New
import 'tabs/meetings_tab.dart'; // Restored

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

    return DefaultTabController(
      length: 8, // Increased from 7
      child: Scaffold(
        appBar: AppBar(
          title: Text(student.fullName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Academics'),
              Tab(text: 'Internships'),
              Tab(text: 'Certifications'),
              Tab(text: 'Activities'),
              Tab(text: 'Tasks'),
              Tab(text: 'Meetings'),
              Tab(text: 'AI Insight'), // New Tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProfileTab(studentId: student.id),
            AcademicsTab(studentId: student.id),
            InternshipsTab(studentId: student.id),
            CertificationsTab(studentId: student.id),
            ActivitiesTab(studentId: student.id),
            TasksTab(studentId: student.id),
            MeetingsTab(studentId: student.id),
            AiInsightTab(studentId: student.id), // New View
          ],
        ),
      ),
    );
  }
}
