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

  Future<void> _provideLink(BuildContext context, String title) async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Provide link for $title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://drive.google.com/...',
            labelText: 'Google Drive Link',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Pass the link as the filePath
      await provider.updateDocumentStatus(title, 'Pending Approval',
          filePath: result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Document link submitted successfully!')),
        );
      }
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

  Future<void> _provideLinkForRequest(
      BuildContext context, dynamic request) async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Provide link for ${request.title}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://drive.google.com/...',
            labelText: 'Google Drive Link',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await provider.uploadDocumentForRequest(request.id, result);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document link submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showAddCustomDocDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final linkController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ADD EXTRA DOCUMENT',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Document Title',
                hintText: 'e.g. Letter of Recommendation',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'Google Drive Link',
                hintText: 'https://drive.google.com/...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  linkController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              Navigator.pop(context, {
                'title': titleController.text.trim(),
                'link': linkController.text.trim(),
              });
            },
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );

    if (result != null) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      try {
        await provider.updateDocumentStatus(
            result['title']!, 'Pending Approval',
            filePath: result['link']);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result['title']} submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MY DOCUMENTS',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          final student = provider.currentStudent;
          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final docStatuses = student.documentStatuses;
          double completion = student.documentCompletion;
          final requests = provider.documentRequests
              .where((req) => req.status == 'Pending' || req.status == 'Rejected')
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Completion Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(24),
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
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '${completion.toInt()}% COMPLETE',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
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
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'CORE DOCUMENTS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_requiredDocs.length, (index) {
                final title = _requiredDocs[index];
                final dbStatus = docStatuses[title] ?? 'Missing';
                final status = dbStatus == 'Pending' ? 'Missing' : dbStatus;
                final isUploaded = status != 'Missing';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDocCard(context, title, status, isUploaded,
                      student.documentFilePaths[title]),
                );
              }),

              if (requests.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'MENTOR REQUESTS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 16),
                ...requests.map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRequestCard(context, req),
                    )),
              ],
              const SizedBox(height: 100), // Space for FAB
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomDocDialog(context),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 10,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'ADD DOCUMENT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, String title, String status,
      bool isUploaded, String? path) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUploaded
                ? Colors.green.withOpacity(0.08)
                : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            isUploaded ? Icons.link_rounded : Icons.add_link_outlined,
            color: isUploaded ? Colors.green.shade700 : Colors.black38,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.2),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.w900,
                fontSize: 9,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        trailing: isUploaded
            ? IconButton(
                icon: const Icon(Icons.remove_red_eye_rounded,
                    color: Colors.black87),
                onPressed: () => _viewDocument(context, title, path),
              )
            : TextButton(
                onPressed: () => _provideLink(context, title),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('ADD LINK',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
              ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, dynamic request) {
    final isRejected = request.status == 'Rejected';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isRejected
                ? Colors.red.withOpacity(0.2)
                : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(Icons.assignment_late_rounded,
            color: isRejected ? Colors.red : Colors.orange),
        title: Text(
          request.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(request.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
            if (isRejected && request.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Text('REASON: ${request.rejectionReason}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        trailing: FilledButton(
          onPressed: () => _provideLinkForRequest(context, request),
          style: FilledButton.styleFrom(
            backgroundColor: isRejected ? Colors.red : Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(isRejected ? 'RE-SUBMIT' : 'UPLOAD',
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Verified':
        return Colors.green.shade700;
      case 'Missing':
        return Colors.red.shade700;
      case 'Rejected':
        return Colors.red.shade900;
      default:
        return Colors.orange.shade800;
    }
  }

}
