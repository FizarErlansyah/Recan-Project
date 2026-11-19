import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class InsightBox extends StatelessWidget {
  const new({required this.text, required this.accent, super.key});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(icon: AppIcons.idea, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                tr('Wawasan Interaktif', 'Interactive Insight'),
                style: textTheme.labelLarge?.copyWith(
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
