import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/map_station.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/capsule_progress_bar.dart';

class StationBottomSheet extends StatelessWidget {
  const new({required this.station, required this.onDeposit, super.key});

  final MapStation station;
  final VoidCallback onDeposit;

  static Future<void> show(
    BuildContext context, {
    required MapStation station,
    required VoidCallback onDeposit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          StationBottomSheet(station: station, onDeposit: onDeposit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final almostFull = station.isAlmostFull;
    final barColors = almostFull
        ? const [AppColors.danger, AppColors.danger]
        : const [AppColors.primarySoft, AppColors.sage];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              station.name,
              style: textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    tr('Kapasitas terisi', 'Capacity filled'),
                    style: textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${station.capacityPercent}%',
                  style: textTheme.titleMedium?.copyWith(
                    color: almostFull
                        ? AppColors.danger
                        : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CapsuleProgressBar(
              value: station.capacityPercent / 100,
              colors: barColors,
              trackColor: AppColors.border,
            ),
            if (almostFull) ...[
              const SizedBox(height: 8),
              Text(
                tr(
                  'Hampir penuh, pertimbangkan station lain.',
                  'Almost full, consider another station.',
                ),
                style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDeposit,
                icon: const HugeIcon(icon: AppIcons.recycle, size: 20),
                label: Text(
                  tr('Setor di Station Ini', 'Deposit at This Station'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
