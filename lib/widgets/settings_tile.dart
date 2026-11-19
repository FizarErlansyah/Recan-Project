import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

class SettingsTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.destructive = false,
  });

  final IconGlyph icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : context.palette.textPrimary;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              HugeIcon(
                icon: icon,
                size: 22,
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
                HugeIcon(
                  icon: AppIcons.chevronRight,
                  size: 20,
                  color: context.palette.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
