import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/models/carbon_impact.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/carbon_line_chart.dart';
import 'package:mobile_apps_recan/widgets/points_header.dart';

/// Bento layout: one wide tile for the headline metric, two half tiles for
/// supporting metrics. All tiles share padding, radius and border.
class CarbonMetricCards extends StatelessWidget {
  const new({required this.impact, super.key});

  static const double _gap = 12;

  final CarbonImpact impact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricTile(
          icon: hugeIcon(HugeIcons.strokeRoundedLeaf01),
          value: CarbonLineChart.formatNumber(impact.totalCarbonKg),
          label: tr('Karbon Diselamatkan (kg CO₂e)', 'Carbon Saved (kg CO₂e)'),
          emphasis: true,
        ),
        const SizedBox(height: _gap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MetricTile(
                  icon: hugeIcon(HugeIcons.strokeRoundedRecycle01),
                  value: PointsHeader.formatNumber(impact.totalCans),
                  label: tr('Kaleng Terkumpul', 'Cans Collected'),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _MetricTile(
                  icon: hugeIcon(HugeIcons.strokeRoundedTarget01),
                  value: '${impact.targetPercent}%',
                  label: tr(
                    'Target Kampus Hijau UPJ',
                    'UPJ Green Campus Target',
                  ),
                  progress: impact.targetPercent / 100,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.value,
    required this.label,
    this.emphasis = false,
    this.progress,
  });

  final AppIconBuilder icon;
  final String value;
  final String label;
  final bool emphasis;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = _TileText(
      value: value,
      label: label,
      valueStyle: emphasis ? textTheme.headlineMedium : textTheme.titleLarge,
      progress: progress,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(),
      child: emphasis
          ? Row(
              children: [
                _IconChip(icon: icon, size: 40),
                const SizedBox(width: 12),
                Expanded(child: text),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconChip(icon: icon, size: 32),
                const SizedBox(height: 12),
                text,
              ],
            ),
    );
  }
}

class _TileText extends StatelessWidget {
  const new({
    required this.value,
    required this.label,
    required this.valueStyle,
    required this.progress,
  });

  final String value;
  final String label;
  final TextStyle? valueStyle;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final fill = progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: FittedBox(
            key: ValueKey(value),
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: valueStyle?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (fill != null) ...[
          const SizedBox(height: 8),
          _TargetBar(fill: fill),
        ],
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  const new({required this.icon, required this.size});

  final AppIconBuilder icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: icon(color: AppColors.primary, size: size * 0.5),
    );
  }
}

class _TargetBar extends StatelessWidget {
  const new({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fill),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 4,
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceMuted,
        ),
      ),
    );
  }
}
