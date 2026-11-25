import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/activity/domain/month_summary.dart';
import 'package:mobile_apps_recan/utils/indonesian_date.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';

class MonthSummaryCard extends StatelessWidget {
  const new({required this.summary, required this.month, super.key});

  final MonthSummary summary;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final name = IndonesianDate.monthName(month);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Ringkasan $name', '$name summary'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _Figures(summary: summary),
        ],
      ),
    );
  }
}

class _Figures extends StatelessWidget {
  const new({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Figure(
          label: tr('Poin masuk', 'Points in'),
          value: summary.pointsIn,
          color: palette.success,
        ),
        _Figure(
          label: tr('Poin keluar', 'Points out'),
          value: summary.pointsOut,
          color: palette.danger,
        ),
        _Figure(
          label: tr('Kaleng', 'Cans'),
          value: summary.cans,
          color: palette.textPrimary,
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const new({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedCountUp(
              value: value,
              style: textTheme.titleLarge?.copyWith(color: color),
            ),
          ),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
