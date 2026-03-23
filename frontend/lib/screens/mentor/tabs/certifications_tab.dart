import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mentor_provider.dart';
import '../../../models/certification_model.dart';
import '../sheets/request_document_sheet.dart';

class CertificationsTab extends StatelessWidget {
  final String studentId;

  const CertificationsTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    final certifications = mentorProvider.studentCertifications;

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: certifications.length,
        itemBuilder: (context, index) {
          final cert = certifications[index];
          return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.verified,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(cert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Issuer: ${cert.issuer}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip(cert.category, Colors.indigo),
                    const SizedBox(width: 4),
                    _buildChip(cert.type ?? 'Achievement', Colors.green),
                    const SizedBox(width: 4),
                    _buildChip(cert.level ?? 'L1', Colors.orange),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Points Assigned: ${cert.points}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.stars, color: Colors.amber),
              tooltip: 'Review & Score',
              onPressed: () {
                _showEditPointsDialog(context, cert);
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final student = mentorProvider.selectedStudent;
          if (student != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => RequestDocumentSheet(
                studentId: student.id,
                studentName: student.fullName,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Request Document'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showEditPointsDialog(BuildContext context, CertificationModel cert) {
    final pointsController = TextEditingController(text: cert.points.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Points - ${cert.title}'),
        content: TextField(
          controller: pointsController,
          decoration: const InputDecoration(labelText: 'Points'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updated = CertificationModel(
                id: cert.id,
                studentId: cert.studentId,
                title: cert.title,
                issuer: cert.issuer,
                date: cert.date,
                points: int.tryParse(pointsController.text) ?? cert.points,
                category: cert.category,
                certificateUrl: cert.certificateUrl,
                type: cert.type ?? 'Certificate',
                level: cert.level ?? 'Local',
              );
              Provider.of<MentorProvider>(context, listen: false)
                  .updateCertification(updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
