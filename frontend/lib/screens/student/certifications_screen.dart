import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/certification_model.dart';
import 'add_certification_screen.dart';

class CertificationsScreen extends StatelessWidget {
  const CertificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentId = authProvider.userId ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              child: const TabBar(
                tabs: [
                  Tab(text: 'Internal (College)'),
                  Tab(text: 'External (Off-Campus)'),
                ],
              ),
            ),
            // Total Points Summary
            Consumer<StudentProvider>(
              builder: (context, provider, _) {
                final points =
                    provider.currentStudent?.certificationPoints ?? 0;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.black.withOpacity(0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_outlined,
                          color: Colors.black87, size: 24),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            const TextSpan(text: 'TOTAL SCORE: '),
                            TextSpan(
                              text: '$points / 10',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: Provider.of<StudentProvider>(context, listen: false)
                    .loadStudentData(studentId),
                builder: (context, snapshot) {
                  return Consumer<StudentProvider>(
                    builder: (context, studentProvider, child) {
                      final certifications = studentProvider.certifications;

                      return TabBarView(
                        children: [
                          _buildCategoryList(
                              context, certifications, 'Internal'),
                          _buildCategoryList(
                              context, certifications, 'External'),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddCertificationScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Achievement'),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<CertificationModel> certifications,
    String category,
  ) {
    final filtered =
        certifications.where((c) => c.category == category).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No $category certifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final cert = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_outlined, color: Colors.black87),
            ),
            title: Text(
              cert.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${cert.type.toUpperCase()} • ${cert.level.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cert.issuer} • ${DateFormat('yyyy-MM-dd').format(cert.date)}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cert.isVerified
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cert.isVerified ? 'APPROVED' : 'PENDING REVIEW',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: cert.isVerified
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                    if (cert.points > 0 && cert.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${cert.points} POINTS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    if (cert.certificateUrl != null &&
                        cert.certificateUrl!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_outlined,
                                color: Colors.blue.shade800, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'CERTIFICATE UPLOADED',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Colors.blue.shade800),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 22, color: Colors.black54),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddCertificationScreen(certification: cert),
                  ),
                );
              },
            ),
            isThreeLine: true,
            onTap: () {
              _showCertificationDetails(context, cert);
            },
          ),
        );
      },
    );
  }

  void _showCertificationDetails(
      BuildContext context, CertificationModel cert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cert.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(Icons.business_outlined, 'Issuer', cert.issuer),
              _detailRow(Icons.category_outlined, 'Category', cert.category),
              _detailRow(Icons.tips_and_updates_outlined, 'Type', cert.type),
              _detailRow(Icons.layers_outlined, 'Level', cert.level),
              _detailRow(Icons.calendar_today_outlined, 'Date',
                  DateFormat('MMMM dd, yyyy').format(cert.date)),
              if (cert.points > 0)
                _detailRow(
                    Icons.stars, 'Points Awarded', cert.points.toString()),
              if (cert.certificateUrl != null &&
                  cert.certificateUrl!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text('Certificate',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cert.certificateUrl!.split('/').last,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final url = cert.certificateUrl;
                          debugPrint('DEBUG: Viewing certification: $url');
                          if (url != null && url.isNotEmpty) {
                            try {
                              String actualPath = url;
                              if (url.trim().startsWith('{')) {
                                try {
                                  final data = jsonDecode(url);
                                  if (data is Map &&
                                      data.containsKey('filePath')) {
                                    actualPath = data['filePath'];
                                  } else if (data is Map &&
                                      data.containsKey('path')) {
                                    actualPath = data['path'];
                                  }
                                } catch (e) {
                                  debugPrint(
                                      'DEBUG: Failed to parse path as JSON: $e');
                                }
                              }

                              if (actualPath.startsWith('http') ||
                                  actualPath.startsWith('https')) {
                                final uri = Uri.parse(actualPath);
                                debugPrint('DEBUG: Launching Remote URI: $uri');

                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Could not open this certificate.')),
                                    );
                                  }
                                }
                              } else {
                                debugPrint(
                                    'DEBUG: Opening Local File path: $actualPath');
                                final result = await OpenFile.open(actualPath);
                                if (result.type != ResultType.done &&
                                    context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Could not open file: ${result.message}')),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                  'DEBUG ERROR in viewing certification: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error opening certificate: $e')),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('VIEW'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
