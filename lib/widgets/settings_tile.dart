import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: destructive ? AppColors.danger : AppColors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: color),
                ),
              ),
              if (!destructive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
