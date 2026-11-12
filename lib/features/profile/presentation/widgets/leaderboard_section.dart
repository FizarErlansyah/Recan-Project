import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/leaderboard_tile.dart';

class LeaderboardSection extends StatelessWidget {
  const new({required this.entries, super.key});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Papan Peringkat Kampus', 'Campus Leaderboard'),
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          tr('Top Pahlawan Lingkungan', 'Top Environmental Heroes'),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final entry in entries) LeaderboardTile(entry: entry),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
