import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class StationStatusBadge extends StatelessWidget {
  const new({required this.full, super.key});

  final bool full;

  @override
  Widget build(BuildContext context) {
    final color = full ? AppColors.danger : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (full ? AppColors.dangerSoft : AppColors.successSoft),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        full ? tr('🔴 Penuh', '🔴 Full') : tr('● Beroperasi', '● Operational'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
