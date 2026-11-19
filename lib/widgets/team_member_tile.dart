import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

class TeamMemberTile extends StatelessWidget {
  const new({
    required this.name,
    required this.role,
    super.key,
    this.highlighted = false,
    this.initials,
  });

  final String name;
  final String role;
  final bool highlighted;
  final String? initials;

  String get _initials {
    final override = initials;
    if (override != null) return override;
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words
        .where((w) => !w.endsWith('.') && !w.endsWith(','))
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted ? AppColors.primary : context.palette.tint,
            ),
            child: Text(
              _initials,
              style: textTheme.labelLarge?.copyWith(
                color: highlighted ? AppColors.white : context.palette.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(role, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
