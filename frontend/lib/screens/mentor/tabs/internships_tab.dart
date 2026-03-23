import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mentor_provider.dart';

class InternshipsTab extends StatelessWidget {
  final String studentId;

  const InternshipsTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = Provider.of<MentorProvider>(context);
    // Note: You'll need to add getInternshipsByStudent to MentorProvider
    // For now, this is a placeholder

    return const Center(
      child: Text('Internships tab - Load internships from provider'),
    );
  }
}
