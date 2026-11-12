import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class PaymentOptionTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String hint;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final active = selected && enabled;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: enabled
            ? (active
                  ? AppColors.primarySoft.withValues(alpha: 0.3)
                  : AppColors.surface)
            : AppColors.border,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  active
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(subtitle, style: textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: textTheme.labelMedium?.copyWith(
                          color: enabled
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
