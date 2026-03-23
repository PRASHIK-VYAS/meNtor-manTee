import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mentor_provider.dart';
import '../../models/student_model.dart';
import 'student_detail_view.dart';
import 'student_ai_insight_screen.dart'; // New

class StudentListScreen extends StatefulWidget {
  final String? filter;
  const StudentListScreen({super.key, this.filter});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filter == null 
            ? 'All Students' 
            : '${widget.filter![0].toUpperCase()}${widget.filter!.substring(1)} Students'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<MentorProvider>(
            builder: (context, mentorProvider, child) {
              List<StudentModel> students = widget.filter != null 
                  ? mentorProvider.getFilteredStudents(widget.filter!)
                  : mentorProvider.assignedStudents;

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                students = students.where((student) {
                  return student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      student.studentId.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();
              }

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  
                  // Student List
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No students assigned'
                                      : 'No students found',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final hasLowCGPA = student.currentCGPA < 7.0;
                              final hasPendingTasks = student.pendingTasks > 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: hasLowCGPA ? Colors.red.shade50 : const Color(0xFFF5F5F7),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.black.withOpacity(0.05)),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    mentorProvider.selectStudent(student.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const StudentDetailView(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          child: Text(
                                            student.fullName.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(
                                          student.fullName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('ID: ${student.studentId}', style: const TextStyle(fontSize: 12)),
                                            Text('CGPA: ${student.currentCGPA.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                            if (hasPendingTasks)
                                              Text(
                                                '${student.pendingTasks} pending tasks',
                                                style: const TextStyle(color: Colors.orange, fontSize: 12),
                                              ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (hasLowCGPA)
                                              const Icon(Icons.warning, color: Colors.red, size: 20),
                                            const Icon(Icons.chevron_right, color: Colors.black54),
                                          ],
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => StudentAiInsightScreen(student: student),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.psychology, size: 18),
                                            label: const Text('AI Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                                            style: TextButton.styleFrom(foregroundColor: Colors.purple),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
