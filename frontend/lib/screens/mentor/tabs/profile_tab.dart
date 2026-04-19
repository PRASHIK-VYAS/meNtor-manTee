import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/mentor_provider.dart';
import '../doc_approval_screen.dart';

class ProfileTab extends StatelessWidget {
  final String studentId;

  const ProfileTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final student = mentorProvider.selectedStudent;

    if (student == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child: Text(
                      student.fullName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student.studentId,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Read-only fields
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(student.email),
                ),
                if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.phone_android_outlined),
                    title: const Text('Phone Number'),
                    subtitle: Text(student.phoneNumber!),
                  ),
                ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: const Text('Department'),
                  subtitle: Text(student.department),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Current Semester'),
                  subtitle: Text('Semester ${student.currentSemester}'),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_outlined),
                  title: const Text('Mentor Code'),
                  subtitle: Text(student.mentorCode ?? 'Not Linked'),
                ),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Admission Type'),
                  subtitle: Text(student.admissionType),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date of Birth'),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(student.dateOfBirth)),
                ),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Date of Joining'),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(student.dateOfJoining)),
                ),
                if (student.groupLeaderName != null)
                  ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text('Group Leader'),
                    subtitle: Text(student.groupLeaderName!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocApprovalScreen(studentId: student.id),
                  ),
                );
              },
              icon: const Icon(Icons.description_rounded),
              label: const Text(
                'VIEW SUBMITTED DOCUMENTS',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
