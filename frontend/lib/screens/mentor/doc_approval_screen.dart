import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import '../../providers/mentor_provider.dart';
import '../../models/student_model.dart';

class DocApprovalScreen extends StatefulWidget {
  const DocApprovalScreen({super.key});

  @override
  State<DocApprovalScreen> createState() => _DocApprovalScreenState();
}

class _DocApprovalScreenState extends State<DocApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Approve OR reject a pending document uploaded by a student.
  /// Updates the student's documentStatuses map via the provider.
  Future<void> _handleApproval(BuildContext context, StudentModel student,
      String docName, bool approved) async {
    final mentorProvider = Provider.of<MentorProvider>(context, listen: false);

    // Use dedicated provider method — it patches /mentors/students/:id
    await mentorProvider.updateStudentDocumentStatus(
      student.id,
      docName,
      approved ? 'Approved' : 'Rejected',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(approved ? '✅ Document Approved' : '❌ Document Rejected'),
          backgroundColor: approved ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _viewDocument(
      BuildContext context, String title, String? path) async {
    debugPrint('DEBUG: _viewDocument called for $title with path: $path');
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file path found for this document.')),
      );
      return;
    }

    try {
      // If path is a JSON string, try to extract filePath
      String actualPath = path;
      if (path.trim().startsWith('{')) {
        try {
          final data = jsonDecode(path);
          if (data is Map && data.containsKey('filePath')) {
            actualPath = data['filePath'];
          } else if (data is Map && data.containsKey('path')) {
            actualPath = data['path'];
          }
        } catch (e) {
          debugPrint('DEBUG: Failed to parse path as JSON: $e');
        }
      }

      if (actualPath.startsWith('http') || actualPath.startsWith('https')) {
        final uri = Uri.parse(actualPath);
        debugPrint('DEBUG: Launching Remote URI: $uri');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Could not open link. Check if a viewer is installed.')),
            );
          }
        }
      } else {
        debugPrint('DEBUG: Opening Local File path: $actualPath');
        final result = await OpenFile.open(actualPath);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      }
    } catch (e) {
      debugPrint('DEBUG ERROR in _viewDocument: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Common Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F7),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'APPROVALS'),
                  Tab(text: 'REQUESTS'),
                  Tab(text: 'HISTORY'),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black38,
                indicatorColor: Colors.black,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApprovalsTab(const ['Pending Approval']),
          _buildRequestsTab(const ['Pending', 'Uploaded']),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewRequestSheet(context),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.note_add_rounded, color: Colors.white),
        label: const Text(
          'NEW REQUEST',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildApprovalsTab(List<String> statusFilters, {bool isHistory = false}) {
    return Consumer<MentorProvider>(
      builder: (context, mentorProvider, child) {
        // Build flat list of docs matching status filters
        final List<Map<String, dynamic>> flatDocs = [];
        for (var student in mentorProvider.assignedStudents) {
          student.documentStatuses.forEach((docName, status) {
            if (statusFilters.contains(status)) {
              flatDocs.add({
                'student': student,
                'docName': docName,
                'status': status,
                'studentName': student.fullName,
                'studentId': student.studentId,
              });
            }
          });
        }

        // Apply search filter
        final filteredDocs = _searchQuery.isEmpty
            ? flatDocs
            : flatDocs.where((doc) {
                final name = (doc['studentName'] as String).toLowerCase();
                final id = (doc['studentId'] as String).toLowerCase();
                final docName = (doc['docName'] as String).toLowerCase();
                final query = _searchQuery.toLowerCase();
                return name.contains(query) ||
                    id.contains(query) ||
                    docName.contains(query);
              }).toList();

        if (filteredDocs.isEmpty) {
          if (isHistory) return const SizedBox.shrink();
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'All caught up!'
                      : 'No matching documents',
                  style: TextStyle(
                      color: Colors.grey[400], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: isHistory,
          physics: isHistory ? const NeverScrollableScrollPhysics() : null,
          padding: isHistory ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final student = doc['student'] as StudentModel;
            final bool isPending = doc['status'] == 'Pending Approval';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.description_outlined,
                            color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    doc['docName'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16),
                                  ),
                                ),
                                if (!isPending)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: doc['status'] == 'Approved'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      (doc['status'] as String).toUpperCase(),
                                      style: TextStyle(
                                        color: doc['status'] == 'Approved'
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              'FROM ${(doc['studentName'] as String).toUpperCase()}',
                              style: const TextStyle(
                                  color: Colors.black38,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (isPending) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleApproval(
                                context, student, doc['docName'], false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('REJECT',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleApproval(
                                context, student, doc['docName'], true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('APPROVE',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _viewDocument(
                              context,
                              doc['docName'],
                              student.documentFilePaths[doc['docName']]),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('VIEW',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.history, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(
                  'PAST APPROVALS & REQUESTS',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // History of autonomous approvals
          _buildApprovalsTab(const ['Approved', 'Rejected'], isHistory: true),
          // History of mentor requests
          _buildRequestsTab(const ['Approved', 'Rejected'], isHistory: true),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(List<String> statusFilters, {bool isHistory = false}) {
    return Consumer<MentorProvider>(
      builder: (context, mentorProvider, child) {
        final requests = mentorProvider.documentRequests
            .where((req) => statusFilters.contains(req.status))
            .toList();

        // Apply search
        final filtered = _searchQuery.isEmpty
            ? requests
            : requests.where((req) {
                final title = req.title.toLowerCase();
                final query = _searchQuery.toLowerCase();
                final student = mentorProvider.assignedStudents.firstWhere(
                    (s) => s.id == req.studentId,
                    orElse: () => StudentModel(
                        id: '',
                        email: '',
                        fullName: '',
                        studentId: '',
                        department: '',
                        admissionType: '',
                        dateOfBirth: DateTime.now(),
                        dateOfJoining: DateTime.now()));
                return title.contains(query) ||
                    student.fullName.toLowerCase().contains(query);
              }).toList();

        if (filtered.isEmpty) {
          if (isHistory) return const SizedBox.shrink();
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No document requests sent.'
                      : 'No matching requests.',
                  style: TextStyle(
                      color: Colors.grey[400], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: isHistory,
          physics: isHistory ? const NeverScrollableScrollPhysics() : null,
          padding: isHistory ? EdgeInsets.zero : const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final req = filtered[index];
            final student = mentorProvider.assignedStudents.firstWhere(
              (s) => s.id == req.studentId,
              orElse: () => StudentModel(
                  id: '',
                  email: '',
                  fullName: 'Unknown',
                  studentId: '',
                  department: '',
                  admissionType: '',
                  dateOfBirth: DateTime.now(),
                  dateOfJoining: DateTime.now()),
            );

            Color statusColor = Colors.orange;
            String statusText = req.status.toUpperCase();
            if (req.status == 'Approved') statusColor = Colors.green;
            if (req.status == 'Rejected') statusColor = Colors.red;
            if (req.status == 'Uploaded') {
              statusColor = Colors.blue;
              statusText = 'SUBMITTED / DONE';
            }

            return Container(
              margin: isHistory ? const EdgeInsets.fromLTRB(16, 0, 16, 16) : const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                         child: Text(
                          statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(req.createdAt),
                        style: const TextStyle(
                            color: Colors.black26,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(req.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    'FOR ${student.fullName.toUpperCase()}',
                    style: const TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5),
                  ),
                  if (req.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(req.description,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13, height: 1.4)),
                  ],
                  if (req.filePath != null && req.filePath!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _viewDocument(context, req.title, req.filePath),
                        icon:
                            const Icon(Icons.remove_red_eye_outlined, size: 16),
                        label: const Text('VIEW DOCUMENT',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNewRequestSheet(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context, listen: false);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedStudentId;
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              0, 0, 0, MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NEW DOC REQUEST',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recipient dropdown
                  const Text('RECIPIENT',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: Colors.black45,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedStudentId,
                        hint: const Text('Select a student'),
                        items: mentorProvider.assignedStudents
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.fullName),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedStudentId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Document title
                  const Text('DOCUMENT TITLE',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: Colors.black45,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. SEM 3 Marksheet',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Instructions
                  const Text('INSTRUCTIONS (OPTIONAL)',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: Colors.black45,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Detailed requirements...',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Send button — full width, no overflow
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              if (selectedStudentId == null) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please select a student')),
                                );
                                return;
                              }
                              if (titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please enter a document title')),
                                );
                                return;
                              }
                              setModalState(() => isSending = true);
                              try {
                                await mentorProvider.createDocumentRequest(
                                  studentId: selectedStudentId!,
                                  title: titleController.text.trim(),
                                  description: descController.text.trim(),
                                  type: 'Document',
                                );
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Request sent successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSending = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Failed to send request: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.black45,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isSending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'SEND REQUEST',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
