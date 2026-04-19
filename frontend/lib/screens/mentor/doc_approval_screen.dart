import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import '../../providers/mentor_provider.dart';
import '../../models/student_model.dart';

class DocApprovalScreen extends StatefulWidget {
  final String? studentId;
  const DocApprovalScreen({super.key, this.studentId});

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Approve OR reject a pending document.
  Future<void> _handleApproval(BuildContext context, StudentModel student,
      String docName, bool approved,
      {String? requestId}) async {
    final mentorProvider = Provider.of<MentorProvider>(context, listen: false);

    if (requestId != null) {
      if (approved) {
        await mentorProvider.approveDocumentRequest(requestId);
      } else {
        await mentorProvider.rejectDocumentRequest(
            requestId, 'Rejected by mentor');
      }
    } else {
      await mentorProvider.updateStudentDocumentStatus(
        student.id,
        docName,
        approved ? 'Approved' : 'Rejected',
      );
    } 

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
        title: widget.studentId != null 
            ? Consumer<MentorProvider>(
                builder: (context, mp, _) {
                  final s = mp.assignedStudents.firstWhere((s) => s.id == widget.studentId, orElse: () => mp.selectedStudent!);
                  return Text('Documents: ${s.fullName}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18));
                }
              )
            : null,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(85),
          child: Column(
            children: [
              // Common Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  Tab(text: 'PENDING'),
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
          _buildApprovalsTab(const ['Pending Approval', 'Uploaded']),
          _buildHistoryTab(),
        ],
      ),
      // Removed NEW REQUEST button as per requirements
    );
  }

  Widget _buildApprovalsTab(List<String> statusFilters, {bool isHistory = false}) {
    return Consumer<MentorProvider>(
      builder: (context, mentorProvider, child) {
        // Build flat list of docs matching status filters
        final List<Map<String, dynamic>> flatDocs = [];

        // 1. Check general document statuses from student models
        final targetStudents = widget.studentId != null 
            ? mentorProvider.assignedStudents.where((s) => s.id == widget.studentId)
            : mentorProvider.assignedStudents;

        for (var student in targetStudents) {
          student.documentStatuses.forEach((docName, status) {
            if (statusFilters.contains(status)) {
              flatDocs.add({
                'student': student,
                'docName': docName,
                'status': status,
                'studentName': student.fullName,
                'studentId': student.studentId,
                'requestId': null, // General document
                'filePath': student.documentFilePaths[docName],
              });
            }
          });
        }

        // 2. Check mentor-initiated document requests (Filtered by studentId if needed)
        final targetRequests = mentorProvider.documentRequests
            .where((r) => widget.studentId == null || r.studentId == widget.studentId)
            .where((r) => statusFilters.contains(r.status));

        for (var req in targetRequests) {
          // Need to find the student model
          final student = mentorProvider.assignedStudents.firstWhere(
            (s) => s.id == req.studentId,
            orElse: () => StudentModel(
                id: req.studentId,
                email: '',
                fullName: 'Unknown',
                studentId: '',
                department: '',
                admissionType: '',
                dateOfBirth: DateTime.now(),
                dateOfJoining: DateTime.now()),
          );

          flatDocs.add({
            'student': student,
            'docName': req.title,
            'status': req.status,
            'studentName': student.fullName,
            'studentId': student.studentId,
            'requestId': req.id,
            'filePath': req.filePath,
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
            final bool isPending =
                doc['status'] == 'Pending Approval' || doc['status'] == 'Uploaded';

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
                            const SizedBox(height: 6),
                            // Show URL Link
                            GestureDetector(
                              onTap: () => _viewDocument(context, doc['docName'], doc['filePath']),
                              child: Text(
                                doc['filePath'] ?? 'No link provided',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                                context, student, doc['docName'], false,
                                requestId: doc['requestId']),
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
                                context, student, doc['docName'], true,
                                requestId: doc['requestId']),
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
                              context, doc['docName'], doc['filePath']),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('OPEN LINK',
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
          // Unified history of all approvals (General + Mentor-initiated)
          _buildApprovalsTab(const ['Approved', 'Rejected'], isHistory: true),
        ],
      ),
    );
  }

  // _showNewRequestSheet and _buildRequestsTab removed as per requirements
}
