import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const new({
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final action = actionLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: AppColors.primary,
              ),
              child: Text(action, style: textTheme.labelLarge),
            ),
        ],
      ),
    );
  }
}
