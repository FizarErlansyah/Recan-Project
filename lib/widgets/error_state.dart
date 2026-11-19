import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class ErrorState extends StatelessWidget {
  const new({
    required this.message,
    required this.onRetry,
    super.key,
    this.actionLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String? actionLabel;

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
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: HugeIcon(
                  icon: AppIcons.offline,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tr('Ups, ada masalah', 'Oops, something went wrong'),
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const HugeIcon(icon: AppIcons.refresh, size: 20),
              label: Text(actionLabel ?? tr('Coba Lagi', 'Try Again')),
            ),
          ],
        ),
      ),
    );
  }
}
