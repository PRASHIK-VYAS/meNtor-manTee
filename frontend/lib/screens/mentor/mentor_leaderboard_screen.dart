import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentor_provider.dart';
import '../../models/leaderboard_member.dart';

class MentorLeaderboardScreen extends StatefulWidget {
  const MentorLeaderboardScreen({super.key});

  @override
  State<MentorLeaderboardScreen> createState() =>
      _MentorLeaderboardScreenState();
}

class _MentorLeaderboardScreenState extends State<MentorLeaderboardScreen> {
  late Future<List<LeaderboardMember>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture =
        Provider.of<MentorProvider>(context, listen: false).getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaderboardMember>>(
      future: _leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final leaderboard = snapshot.data ?? [];
        if (leaderboard.isEmpty) {
          return const Center(
              child: Text('No students found for this leaderboard.'));
        }

        final top3 = leaderboard.take(3).toList();
        final remaining =
            leaderboard.length > 3 ? leaderboard.skip(3).toList() : [];

        return Column(
          children: [
            // Top 3 Podium
            if (top3.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16),
                      if (top3.length > 1)
                        _buildPodiumItem(context, 2, top3[1].fullName,
                            top3[1].totalScore, Colors.teal),
                      const SizedBox(width: 24),
                      if (top3.isNotEmpty)
                        _buildPodiumItem(context, 1, top3[0].fullName,
                            top3[0].totalScore, Colors.amber),
                      const SizedBox(width: 24),
                      if (top3.length > 2)
                        _buildPodiumItem(context, 3, top3[2].fullName,
                            top3[2].totalScore, Colors.orange),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: remaining.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final member = remaining[index];
                  final currentRank = index + 4;

                  return ListTile(
                    leading: Text(
                      '#$currentRank',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                    title: Text(member.fullName,
                        style: const TextStyle(fontWeight: FontWeight.normal)),
                    trailing: Text(
                      '${member.totalScore} pts',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodiumItem(
      BuildContext context, int rank, String name, double points, Color color) {
    final double height = rank == 1 ? 160 : (rank == 2 ? 130 : 110);
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Text(name[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                '$points',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
