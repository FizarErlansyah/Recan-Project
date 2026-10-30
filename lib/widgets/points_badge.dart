import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class PointsBadge extends StatelessWidget {
  const new({required this.points, super.key});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.toll_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              tr(
                '${PointsHeader.formatNumber(points)} poin',
                '${PointsHeader.formatNumber(points)} points',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
