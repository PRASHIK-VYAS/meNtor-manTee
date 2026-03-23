import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import 'student_dashboard_screen.dart';
import 'student_profile_screen.dart';
import 'academic_records_screen.dart';
import 'internships_screen.dart';
import 'certifications_screen.dart';
import 'activities_screen.dart';
import 'mentor_tasks_screen.dart';
import 'student_documents_screen.dart';
import 'student_meetings_screen.dart';
import 'student_broadcasts_screen.dart';
import 'student_leaderboard_screen.dart';
import 'student_ai_summary_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentDashboardScreen(),
    const StudentProfileScreen(),
    const AcademicRecordsScreen(),
    const StudentDocumentsScreen(),
    const InternshipsScreen(),
    const CertificationsScreen(),
    const MentorTasksScreen(),
    const StudentMeetingsScreen(),
    const StudentBroadcastsScreen(),
    const StudentLeaderboardScreen(),
    const StudentAiSummaryScreen(),
    const ActivitiesScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'My Profile',
    'Academic Records',
    'My Documents',
    'Internships',
    'Certifications',
    'Mentor Tasks',
    'My Meetings',
    'Broadcasts',
    'Leaderboard',
    'AI Summary',
    'Activities',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _currentIndex == 0,
      appBar: AppBar(
        title: _currentIndex == 0
            ? null
            : Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
        centerTitle: true,
        backgroundColor: _currentIndex == 0 ? Colors.transparent : Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Consumer<StudentProvider>(
                  builder: (context, studentProvider, _) {
                    final student = studentProvider.currentStudent;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFF5F5F7),
                          child: Icon(Icons.account_circle_rounded,
                              size: 48, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          student?.fullName.toUpperCase() ?? 'STUDENT PANEL',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (student?.email != null)
                          Text(
                            student!.email,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                  0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard),
              _buildDrawerItem(
                  1, 'Profile', Icons.person_outline, Icons.person),
              _buildDrawerItem(
                  2, 'Academics', Icons.school_outlined, Icons.school),
              _buildDrawerItem(3, 'Documents', Icons.description_outlined,
                  Icons.description),
              _buildDrawerItem(
                  4, 'Internships', Icons.work_outline, Icons.work),
              _buildDrawerItem(
                  5, 'Certifications', Icons.verified_outlined, Icons.verified),
              _buildDrawerItem(
                  6, 'Tasks', Icons.assignment_outlined, Icons.assignment),
              _buildDrawerItem(
                  7, 'Meetings', Icons.groups_outlined, Icons.groups),
              _buildDrawerItem(
                  8, 'Broadcasts', Icons.campaign_outlined, Icons.campaign),
              _buildDrawerItem(9, 'Leaderboard', Icons.leaderboard_outlined,
                  Icons.leaderboard),
              _buildDrawerItem(10, 'AI Insight', Icons.psychology_outlined,
                  Icons.psychology),
              _buildDrawerItem(
                  11, 'Activities', Icons.event_outlined, Icons.event),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: _screens[_currentIndex],
    );
  }

  Widget _buildDrawerItem(
      int index, String title, IconData icon, IconData selectedIcon) {
    bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: null,
        selectedTileColor: Colors.black.withOpacity(0.07),
        selected: isSelected,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.black : Colors.black87,
              size: 22,
            ),
          ],
        ),
        title: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer first
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
