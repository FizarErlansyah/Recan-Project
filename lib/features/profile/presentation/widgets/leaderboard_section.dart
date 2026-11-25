import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/leaderboard_podium.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/leaderboard_tile.dart';

class LeaderboardSection extends StatelessWidget {
  const new({required this.entries, super.key});

  final List<LeaderboardEntry> entries;

  static const int _podiumSize = 3;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // The server appends the caller's own row when they rank outside the top,
    // so the split goes by rank rather than by position in the list.
    final podium = entries.where((e) => e.rank <= _podiumSize).toList();
    final others = entries.where((e) => e.rank > _podiumSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('Papan Peringkat', 'Leaderboard'), style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          tr('Top Kontributor', 'Top Contributors'),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (podium.isEmpty)
          Text(
            tr('Belum ada kontributor.', 'No contributors yet.'),
            style: textTheme.bodyMedium,
          )
        else
          _Board(podium: podium, others: others),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  const new({required this.podium, required this.others});

  final List<LeaderboardEntry> podium;
  final List<LeaderboardEntry> others;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: AppDecorations.card(context),
      child: Column(
        children: [
          LeaderboardPodium(entries: podium),
          if (others.isNotEmpty) const SizedBox(height: 8),
          for (final entry in others) LeaderboardTile(entry: entry),
        ],
      ),
    );
  }
}
