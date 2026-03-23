import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentId = authProvider.userId ?? '';

    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<StudentProvider>(context, listen: false)
            .loadStudentData(studentId),
        builder: (context, snapshot) {
          return Consumer<StudentProvider>(
            builder: (context, studentProvider, child) {
              final student = studentProvider.currentStudent;

              if (student == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Improved Header Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.black12)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 45,
                              backgroundColor: Color(0xFFF5F5F7),
                              child: Icon(Icons.account_circle_rounded,
                                  size: 70, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            student.fullName.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              fontSize: 26,
                              letterSpacing: -1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.department.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeaderBadge('ID: ${student.studentId}'),
                              const SizedBox(width: 8),
                              _buildHeaderBadge('SEM ${student.currentSemester}'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ABOUT YOUR ACCOUNT',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 2.0,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Details Cards
                          _buildDetailItem(
                            Icons.email_outlined,
                            'EMAIL',
                            student.email,
                          ),
                          if (student.phoneNumber != null &&
                              student.phoneNumber!.isNotEmpty)
                            _buildDetailItem(
                              Icons.phone_outlined,
                              'PHONE NUMBER',
                              student.phoneNumber!,
                            ),
                          _buildDetailItem(
                            Icons.school_outlined,
                            'ADMISSION TYPE',
                            student.admissionType,
                          ),
                          _buildDetailItem(
                            Icons.calendar_today_outlined,
                            'DATE OF BIRTH',
                            DateFormat('yyyy-MM-dd')
                                .format(student.dateOfBirth),
                          ),
                          _buildDetailItem(
                            Icons.event_outlined,
                            'JOINING DATE',
                            DateFormat('yyyy-MM-dd')
                                .format(student.dateOfJoining),
                          ),
                          if (student.mentorName != null)
                            _buildDetailItem(
                              Icons.person_outline,
                              'MENTOR',
                              student.mentorName!.toUpperCase(),
                            ),
                          if (student.mentorCode != null)
                            _buildDetailItem(
                              Icons.qr_code,
                              'MENTOR CODE',
                              student.mentorCode!,
                            ),
                          if (student.groupLeaderName != null)
                            _buildDetailItem(
                              Icons.group_outlined,
                              'GROUP LEADER',
                              student.groupLeaderName!.toUpperCase(),
                            ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                authProvider.signOut();
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text('SIGN OUT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      color: Colors.black45,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
