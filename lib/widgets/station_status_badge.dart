import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class StationStatusBadge extends StatelessWidget {
  const new({required this.full, super.key});

  final bool full;

  @override
  Widget build(BuildContext context) {
    final color = full ? context.palette.danger : context.palette.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (full
            ? context.palette.dangerSoft
            : context.palette.successSoft),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        full ? tr('🔴 Penuh', '🔴 Full') : tr('● Beroperasi', '● Operational'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
