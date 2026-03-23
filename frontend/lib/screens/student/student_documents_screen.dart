import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../providers/student_provider.dart';

class StudentDocumentsScreen extends StatefulWidget {
  const StudentDocumentsScreen({super.key});

  @override
  State<StudentDocumentsScreen> createState() => _StudentDocumentsScreenState();
}

class _StudentDocumentsScreenState extends State<StudentDocumentsScreen> {
  final List<String> _requiredDocs = [
    'Resume',
    'ID Proof',
    '10th Marksheet',
    '12th Marksheet / Diploma',
    'Internship Certificate',
  ];

  Future<void> _uploadDocument(BuildContext context, String title) async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        String? path = result.files.single.path;
        // Simulate upload to provider with path
        await provider.updateDocumentStatus(title, 'Pending Approval',
            filePath: path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('${result.files.single.name} uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
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
              SnackBar(
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

  Future<void> _uploadDocumentForRequest(
      BuildContext context, dynamic request) async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        String? path = result.files.single.path;
        await provider.uploadDocumentForRequest(request.id, path ?? '');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${result.files.single.name} uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          final student = provider.currentStudent;
          if (student == null) return const SizedBox();

          final docStatuses = student.documentStatuses;
          double completion = student.documentCompletion;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Mentor Requests Section
                if (provider.documentRequests.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notification_important_outlined,
                                color: Colors.black87),
                            const SizedBox(width: 12),
                            const Text(
                              'PENDING REQUESTS',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${provider.pendingRequestsCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...provider.documentRequests.take(3).map((request) {
                          final isPending = request.status == 'Pending';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.05)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              leading: Icon(
                                request.type == 'Certification'
                                    ? Icons.verified_outlined
                                    : Icons.description_outlined,
                                color: isPending
                                    ? Colors.black87
                                    : Colors.green.shade700,
                              ),
                              title: Text(
                                request.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (request.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      request.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 13),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      request.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isPending
                                            ? Colors.orange.shade800
                                            : Colors.green.shade800,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isPending
                                  ? TextButton(
                                      onPressed: () =>
                                          _uploadDocumentForRequest(
                                              context, request),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      child: const Text('UPLOAD',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11,
                                              letterSpacing: 1.0)),
                                    )
                                  : Icon(Icons.check_circle,
                                      color: Colors.green.shade700),
                              isThreeLine: true,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Completion Bar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DOCUMENT PROFILE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.5,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${completion.toInt()}% COMPLETE',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: completion / 100,
                        backgroundColor: Colors.white,
                        color: Colors.black,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      if (completion <= 50) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange.shade800, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please upload your core documents to avoid verification delays.',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: _requiredDocs.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final title = _requiredDocs[index];
                      final status = docStatuses[title] ?? 'Missing';
                      final isUploaded = status != 'Missing';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUploaded
                                  ? Colors.green.withOpacity(0.1)
                                  : const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isUploaded
                                  ? Icons.verified_outlined
                                  : Icons.upload_file_outlined,
                              color: isUploaded
                                  ? Colors.green.shade700
                                  : Colors.black45,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'Approved'
                                        ? Colors.green.withOpacity(0.1)
                                        : status == 'Missing'
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: status == 'Approved'
                                          ? Colors.green.shade800
                                          : status == 'Missing'
                                              ? Colors.red.shade800
                                              : Colors.orange.shade800,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: isUploaded
                              ? IconButton(
                                  icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.black87),
                                  onPressed: () => _viewDocument(context, title,
                                      student.documentFilePaths[title]),
                                )
                              : TextButton(
                                  onPressed: () =>
                                      _uploadDocument(context, title),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text(
                                    'UPLOAD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
