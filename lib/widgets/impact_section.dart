import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_card.dart';

class ImpactSection extends StatelessWidget {
  const new({required this.stats, required this.userName, super.key});

  final ImpactStats stats;
  final String userName;

  static String _format(double value) {
    final fixed = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    final parts = fixed.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = userName.trim().split(' ').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Dampak Bersama & Kamu', 'Our Impact Together & You'),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            tr('Kontribusi komunitas ReCan', 'ReCan community contribution'),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: tr('Total Kaleng Terkumpul', 'Total Cans Collected'),
                  value: '${_format(stats.totalKg)} kg 🌍',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: tr('Dampak Karbon', 'Carbon Impact'),
                  value: '-${_format(stats.carbonKg)} kg CO2 🍃',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tr(
                'Selamat, $firstName! Setoran ${_format(stats.userKg)} kg '
                    'kalengmu telah mencegah bahaya logam & emisi karbon di '
                    'kampus. 🌱',
                'Congratulations, $firstName! Your ${_format(stats.userKg)} '
                    'kg of deposited cans have prevented metal hazards & carbon '
                    'emissions on campus. 🌱',
              ),
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ReCanCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, maxLines: 1, style: textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
