import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/utils/weight_format.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class DropEstimateCard extends StatelessWidget {
  const new({required this.summary, super.key});

  final DropSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          _EstimateRow(
            icon: AppIcons.coins,
            label: tr('Estimasi Poin Didapat', 'Estimated Points Earned'),
            value: '+${PointsHeader.formatNumber(summary.points)}',
          ),
          const SizedBox(height: 12),
          _EstimateRow(
            icon: AppIcons.weight,
            label: tr('Estimasi Berat Kaleng', 'Estimated Can Weight'),
            value: formatWeight(summary.grams),
          ),
          const SizedBox(height: 12),
          _EstimateRow(
            icon: AppIcons.eco,
            label: tr('Estimasi Karbon Diselamatkan', 'Estimated Carbon Saved'),
            value: '${summary.carbonKg.toStringAsFixed(2)} kg CO₂',
          ),
        ],
      ),
    );
  }
}

class _EstimateRow extends StatelessWidget {
  const new({required this.icon, required this.label, required this.value});

  final IconGlyph icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        HugeIcon(icon: icon, size: 20, color: AppColors.primarySoft),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primarySoft),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            value,
            key: ValueKey(value),
            style: textTheme.titleMedium?.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
