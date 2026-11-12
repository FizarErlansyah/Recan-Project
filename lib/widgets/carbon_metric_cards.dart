import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_shadows.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/carbon_line_chart.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

class CarbonMetricCards extends StatelessWidget {
  const new({required this.impact, super.key});

  final CarbonImpact impact;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MetricCard(
              icon: Icons.recycling_rounded,
              value: PointsHeader.formatNumber(impact.totalCans),
              label: tr('Kaleng Terkumpul', 'Cans Collected'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              icon: Icons.eco_rounded,
              value: CarbonLineChart.formatNumber(impact.totalCarbonKg),
              label: tr(
                'Karbon Diselamatkan (kg CO₂e)',
                'Carbon Saved (kg CO₂e)',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              icon: Icons.school_rounded,
              value: '${impact.targetPercent}%',
              label: tr('Target Kampus Hijau UPJ', 'UPJ Green Campus Target'),
              progress: impact.targetPercent / 100,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const new({
    required this.icon,
    required this.value,
    required this.label,
    this.progress,
  });

  final IconData icon;
  final String value;
  final String label;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fill = progress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: FittedBox(
              key: ValueKey(value),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: textTheme.titleLarge),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: textTheme.bodySmall),
          if (fill != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fill),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  color: AppColors.sage,
                  backgroundColor: AppColors.successSoft,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
