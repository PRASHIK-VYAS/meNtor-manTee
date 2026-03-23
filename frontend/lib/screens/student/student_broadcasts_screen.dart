import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Added
import '../../providers/student_provider.dart';

class StudentBroadcastsScreen extends StatelessWidget {
  const StudentBroadcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          final broadcasts = provider.broadcasts;

          if (broadcasts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshBroadcasts(),
            color: Colors.black,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: broadcasts.length,
              itemBuilder: (context, index) {
                final broadcast = broadcasts[index];
                return _buildBroadcastCard(context, broadcast);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            'NO BROADCASTS YET',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastCard(BuildContext context, dynamic broadcast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (broadcast.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NORMAL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Text(
                  DateFormat('MMM dd').format(broadcast.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              broadcast.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              broadcast.message,
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 14, color: Colors.black),
                ),
                const SizedBox(width: 8),
                Text(
                  'FROM YOUR MENTOR',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
