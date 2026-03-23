import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../providers/notification_provider.dart';
import 'sheets/schedule_meeting_sheet.dart';
import 'student_list_screen.dart';
import 'student_detail_view.dart';
import '../notifications_screen.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mentorId = authProvider.userId ?? '';
    _loadDataFuture = Provider.of<MentorProvider>(context, listen: false)
        .loadMentorData(mentorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load dashboard: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final auth =
                            Provider.of<AuthProvider>(context, listen: false);
                        _loadDataFuture =
                            Provider.of<MentorProvider>(context, listen: false)
                                .loadMentorData(auth.userId ?? '');
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Consumer<MentorProvider>(
          builder: (context, mentorProvider, child) {
            final mentor = mentorProvider.currentMentor;

            if (mentor == null) {
              return const Scaffold(
                body: Center(child: Text('Mentor data not found')),
              );
            }

            final batchStats = mentorProvider.getBatchStats();

            return Container(
              color: Colors.white,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Welcome Section
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(
                                  builder: (context) => IconButton(
                                    icon: const Icon(Icons.menu,
                                        color: Colors.black),
                                    onPressed: () =>
                                        Scaffold.of(context).openDrawer(),
                                  ),
                                ),
                                // Notification bell with badge
                                Consumer<NotificationProvider>(
                                  builder: (context, notificationProvider, _) =>
                                      Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.notifications_none,
                                          color: Colors.black,
                                          size: 28,
                                        ),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationsScreen()),
                                        ),
                                      ),
                                      if (notificationProvider.unreadCount > 0)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${notificationProvider.unreadCount}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black12, width: 1),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Color(0xFFF5F5F7),
                                    child: Icon(Icons.account_circle_rounded,
                                        size: 56, color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'WELCOME,',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        mentor.fullName.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                          fontSize: 28,
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        mentor.email,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildHeaderBadge(
                                              mentor.department.toUpperCase()),
                                          GestureDetector(
                                            onTap: () => _showEditBatchDialog(
                                                context,
                                                mentorProvider,
                                                mentor),
                                            child: _buildHeaderBadge(
                                                'CODE: ${mentor.mentorCode}'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.9,
                              children: [
                                _buildSummaryCard(
                                  context,
                                  'Total Mentees',
                                  batchStats['totalCount'] ??
                                      mentor.totalStudentsAssigned.toString(),
                                  Icons.groups_outlined,
                                  Colors.black,
                                  filter: 'all',
                                ),
                                _buildSummaryCard(
                                  context,
                                  'Attention Needed',
                                  batchStats['attentionCount'] ?? '0',
                                  Icons.notification_important_outlined,
                                  Colors.black,
                                  filter: 'attention',
                                ),
                                _buildSummaryCard(
                                  context,
                                  'Pending Review',
                                  batchStats['pendingDocs'] ?? '0',
                                  Icons.fact_check_outlined,
                                  Colors.black,
                                  filter: 'pending',
                                ),
                                _buildSummaryCard(
                                  context,
                                  'Low Doc Alerts',
                                  batchStats['lowDocAlerts'] ?? '0',
                                  Icons.assignment_late_outlined,
                                  Colors.black,
                                  filter: 'low_docs',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'STUDENTS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF2D3142),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const StudentListScreen(
                                                filter: 'all'),
                                      ),
                                    );
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (mentorProvider.assignedStudents.isEmpty)
                              Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.people_outline,
                                            size: 48, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        Text('No students assigned yet',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...mentorProvider.assignedStudents
                                  .take(5)
                                  .map((student) {
                                String riskLevel = 'Normal';
                                if (student.currentCGPA < 6.5 ||
                                    student.pendingTasks > 2) {
                                  riskLevel = 'High Risk';
                                } else if (student.currentCGPA < 7.0 ||
                                    student.documentCompletion < 60) {
                                  riskLevel = 'Attention';
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.05)),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      mentorProvider.selectStudent(student.id);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const StudentDetailView(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            radius: 28,
                                            backgroundColor: Colors.black,
                                            child: Text(
                                              student.fullName
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  student.fullName
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16,
                                                      letterSpacing: -0.5),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (riskLevel != 'Normal')
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  child: Text(
                                                    riskLevel.toUpperCase(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: 0.5),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            'SEM ${student.currentSemester} | CGPA: ${student.currentCGPA.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                          trailing: const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: Colors.black),
                                          onTap: () {
                                            mentorProvider
                                                .selectStudent(student.id);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const StudentDetailView(),
                                              ),
                                            );
                                          },
                                        ),
                                        if (riskLevel != 'Normal') ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    if (student.phoneNumber !=
                                                            null &&
                                                        student.phoneNumber!
                                                            .isNotEmpty) {
                                                      final Uri launchUri = Uri(
                                                          scheme: 'tel',
                                                          path: student
                                                              .phoneNumber);
                                                      launchUrl(launchUri);
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.call,
                                                    size: 16,
                                                    color:
                                                        (student.phoneNumber !=
                                                                    null &&
                                                                student
                                                                    .phoneNumber!
                                                                    .isNotEmpty)
                                                            ? Colors.green
                                                            : Colors.grey,
                                                  ),
                                                  label: Text(
                                                    'Call'.toUpperCase(),
                                                    style: TextStyle(
                                                      color: (student.phoneNumber !=
                                                                  null &&
                                                              student
                                                                  .phoneNumber!
                                                                  .isNotEmpty)
                                                          ? Colors.black
                                                          : Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: 1.0,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.black,
                                                    side: BorderSide(
                                                      color: (student.phoneNumber !=
                                                                  null &&
                                                              student
                                                                  .phoneNumber!
                                                                  .isNotEmpty)
                                                          ? Colors.black
                                                              .withOpacity(0.1)
                                                          : Colors.grey
                                                              .withOpacity(0.1),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder: (context) =>
                                                          ScheduleMeetingSheet(
                                                              preFilledStudent:
                                                                  student),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.calendar_month,
                                                      size: 16),
                                                  label: const Text('Schedule'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Performance Trends',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('AVG. MENTEE CGPA',
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                              letterSpacing: 1.0)),
                                      Text(
                                        (mentorProvider.assignedStudents
                                                    .map((s) => s.currentCGPA)
                                                    .fold(
                                                        0.0, (a, b) => a + b) /
                                                (mentorProvider.assignedStudents
                                                        .isEmpty
                                                    ? 1
                                                    : mentorProvider
                                                        .assignedStudents
                                                        .length))
                                            .toStringAsFixed(2),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 24),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildTrendIndicator(
                                          'PASS RATE',
                                          batchStats['passRate'] ?? '0%',
                                          Icons.arrow_upward),
                                      _buildTrendIndicator(
                                          'TASKS DONE',
                                          batchStats['tasksDone'] ?? '0%',
                                          Icons.trending_up),
                                      _buildTrendIndicator(
                                          'AVG. CERTS',
                                          batchStats['avgCerts'] ?? '0',
                                          Icons.stars),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
      child: Text(text,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildTrendIndicator(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {String? filter}) {
    return GestureDetector(
      onTap: () {
        if (filter != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentListScreen(filter: filter)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 28, color: Colors.black),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(title.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBatchDialog(
      BuildContext context, MentorProvider provider, dynamic mentor) {
    final codeController = TextEditingController(text: mentor.mentorCode);
    final batchController =
        TextEditingController(text: mentor.activeBatch ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Batch Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: codeController,
                decoration: const InputDecoration(
                    labelText: 'Batch Code',
                    helperText: 'Unique code for students to join')),
            const SizedBox(height: 16),
            TextField(
                controller: batchController,
                decoration: const InputDecoration(
                    labelText: 'Active Batch Name',
                    hintText: 'e.g., 2021-2025')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.isNotEmpty) {
                await provider.updateBatchInfo(
                    codeController.text, batchController.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
