import 'package:flutter/material.dart';

class ActivitiesTab extends StatelessWidget {
  final String studentId;

  const ActivitiesTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Activities tab'),
    );
  }
}
