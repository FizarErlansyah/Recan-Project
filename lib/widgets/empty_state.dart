import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
