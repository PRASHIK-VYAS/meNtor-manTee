import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/semester_model.dart';
import '../../../models/student_model.dart';
import '../../../services/api_service.dart';

class MentorAcademicRecordsScreen extends StatefulWidget {
  const MentorAcademicRecordsScreen({super.key});

  @override
  State<MentorAcademicRecordsScreen> createState() =>
      _MentorAcademicRecordsScreenState();
}

class _MentorAcademicRecordsScreenState
    extends State<MentorAcademicRecordsScreen> {
  bool _isLoading = true;
  List<dynamic> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final mentorId = authProvider.userId;
      if (mentorId != null) {
        final apiService = ApiService();
        final response =
            await apiService.get('/students/leaderboard?mentorId=$mentorId');
        if (mounted) {
          setState(() {
            _students = response as List;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching students: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.group_off, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'No assigned students found',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.indigo),
              ),
              title: Text(
                student['fullName'] ?? 'Unknown Student',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('CGPA: ${(student['currentCGPA'] ?? 0.0).toStringAsFixed(2)}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MentorStudentAcademicDetail(
                      studentId: student['id'].toString(),
                      studentName: student['fullName'] ?? 'Student',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MentorStudentAcademicDetail extends StatefulWidget {
  final String studentId;
  final String studentName;

  const MentorStudentAcademicDetail({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<MentorStudentAcademicDetail> createState() =>
      _MentorStudentAcademicDetailState();
}

class _MentorStudentAcademicDetailState
    extends State<MentorStudentAcademicDetail> {
  bool _isLoading = true;
  List<SemesterModel> _semesters = [];
  StudentModel? _studentProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = ApiService();
      final results = await Future.wait([
        apiService.get('/students/${widget.studentId}'),
        apiService.get('/semesters/student/${widget.studentId}'),
      ]);

      if (mounted) {
        setState(() {
          _studentProfile = StudentModel.fromMap(results[0]);
          _semesters = (results[1] as List)
              .map((data) => SemesterModel.fromMap(data))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.studentName}\'s Records')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    int startSemester = _studentProfile?.admissionType == 'DSE' ? 3 : 1;
    int endSemester = 8;
    List<int> semesterNumbers = List.generate(
      endSemester - startSemester + 1,
      (index) => startSemester + index,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.studentName}\'s Records'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(), // Ensure it's always scrollable for pull-to-refresh
          itemCount: semesterNumbers.length,
          itemBuilder: (context, index) {
            final semNum = semesterNumbers[index];
            final semester = _semesters.firstWhere(
              (s) => s.semesterNumber == semNum,
              orElse: () => SemesterModel(
                id: '',
                studentId: widget.studentId,
                semesterNumber: semNum,
                sgpa: 0.0,
                cgpa: 0.0,
                resultStatus: 'Pending',
                subjects: [],
              ),
            );

            return _buildSemesterCard(semNum, semester);
          },
        ),
      ),
    );
  }

  Widget _buildSemesterCard(int semNum, SemesterModel semester) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'S$semNum',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            'SEMESTER $semNum',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 18,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: semester.resultStatus == 'Pass'
                      ? Colors.green.withOpacity(0.1)
                      : semester.resultStatus == 'Fail'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  semester.resultStatus.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                    color: semester.resultStatus == 'Pass'
                        ? Colors.green[800]
                        : semester.resultStatus == 'Fail'
                            ? Colors.red[800]
                            : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'SGPA',
                        semester.sgpa.toStringAsFixed(2),
                        Icons.grade_outlined,
                      ),
                      _buildStatCard(
                        'CGPA',
                        semester.cgpa.toStringAsFixed(2),
                        Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SUBJECTS & MARKS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black45,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (semester.subjects.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: const Center(
                        child: Text(
                          'No subjects recorded.',
                          style: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2.5),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FB),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black.withOpacity(0.05))),
                            ),
                            children: [
                              _buildTableCell('SUBJECT', isHeader: true),
                              _buildTableCell('INT', isHeader: true),
                              _buildTableCell('EXT', isHeader: true),
                            ],
                          ),
                          ...semester.subjects.map((mark) => TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black.withOpacity(0.02))),
                                ),
                                children: [
                                  _buildTableCell(mark.subjectName),
                                  _buildTableCell(mark.internal.toStringAsFixed(0)),
                                  _buildTableCell(mark.external.toStringAsFixed(0)),
                                ],
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.w900 : FontWeight.w600,
          fontSize: isHeader ? 10 : 13,
          letterSpacing: isHeader ? 1.0 : 0.0,
          color: isHeader ? Colors.black45 : Colors.black87,
        ),
        textAlign:
            isHeader && text != 'SUBJECT' ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
