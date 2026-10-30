import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class LeaderboardTile extends StatelessWidget {
  const new({required this.entry, super.key});

  final LeaderboardEntry entry;

  Color? get _medalColor {
    switch (entry.rank) {
      case 1:
        return AppColors.goldDeep;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final highlighted = entry.isCurrentUser;

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _RankBadge(rank: entry.rank, medalColor: _medalColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              highlighted
                  ? tr('${entry.name} (Kamu)', '${entry.name} (You)')
                  : entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: highlighted ? textTheme.titleSmall : textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.totalKg.toStringAsFixed(1)} kg',
            style: textTheme.titleSmall?.copyWith(
              color: highlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const new({required this.rank, required this.medalColor});

  final int rank;
  final Color? medalColor;

  @override
  Widget build(BuildContext context) {
    final color = medalColor;

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? AppColors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$rank',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color == null ? AppColors.textSecondary : AppColors.white,
        ),
      ),
    );
  }
}
