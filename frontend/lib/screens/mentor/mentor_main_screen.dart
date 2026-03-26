import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../providers/notification_provider.dart';
import 'mentor_dashboard_screen.dart';
import 'student_list_screen.dart';
import 'broadcast_screen.dart';
import 'doc_approval_screen.dart';
import 'mentor_leaderboard_screen.dart';
import 'mentor_activity_approval_screen.dart';
import 'meeting_management_screen.dart';
import 'task_assignment_screen.dart';

class MentorMainScreen extends StatefulWidget {
  const MentorMainScreen({super.key});

  @override
  State<MentorMainScreen> createState() => _MentorMainScreenState();
}

class _MentorMainScreenState extends State<MentorMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  final List<Widget> _screens = [
    const MentorDashboardScreen(),
    const StudentListScreen(),
    const MentorLeaderboardScreen(),
    const BroadcastScreen(),
    const MeetingManagementScreen(),
    const TaskAssignmentScreen(),
    const DocApprovalScreen(),
    const MentorActivityApprovalScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'My Students',
    'Leaderboard',
    'Broadcasts',
    'Meetings',
    'Assign Tasks',
    'Doc Approvals',
    'Activity Approvals',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorProvider>(
      builder: (context, mentorProvider, _) {
        final mentor = mentorProvider.currentMentor;

        return Scaffold(
          appBar: _currentIndex == 0
              ? null
              : AppBar(
                  title: Text(_titles[_currentIndex]),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFF5F5F7),
                          child: Icon(Icons.account_circle_rounded,
                              size: 48, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        // Mentor name
                        Text(
                          mentor?.fullName.toUpperCase() ?? 'MENTOR PANEL',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Mentor email
                        if (mentor?.email != null)
                          Text(
                            mentor!.email,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      index: 0,
                      selectedIcon: Icons.dashboard),
                  _buildDrawerItem(
                      icon: Icons.groups_outlined,
                      title: 'My Mentees',
                      index: 1,
                      selectedIcon: Icons.people),
                  _buildDrawerItem(
                      icon: Icons.leaderboard_outlined,
                      title: 'Leaderboard',
                      index: 2,
                      selectedIcon: Icons.leaderboard),
                  _buildDrawerItem(
                      icon: Icons.campaign_outlined,
                      title: 'Send Broadcast',
                      index: 3,
                      selectedIcon: Icons.campaign),
                  _buildDrawerItem(
                      icon: Icons.video_camera_front_outlined,
                      title: 'Schedule Meetings',
                      index: 4,
                      selectedIcon: Icons.video_camera_front),
                  _buildDrawerItem(
                      icon: Icons.task_alt_rounded,
                      title: 'Assign Tasks',
                      index: 5,
                      selectedIcon: Icons.task_alt),
                  _buildDrawerItem(
                      icon: Icons.approval_rounded,
                      title: 'Document Approvals',
                      index: 6,
                      selectedIcon: Icons.approval),
                  _buildDrawerItem(
                      icon: Icons.playlist_add_check,
                      title: 'Activity Approvals',
                      index: 7,
                      selectedIcon: Icons.playlist_add_check_circle),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  ),
                  // Logout
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
                      Navigator.pop(context);
                      Provider.of<AuthProvider>(context, listen: false)
                          .signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
          body: _screens[_currentIndex],
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required String title,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        // No background fill — use subtle left bar instead
        tileColor: null,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vertical indicator bar
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
              color: isSelected ? Colors.black : Colors.black54,
              size: 22,
            ),
          ],
        ),
        title: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black54,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
