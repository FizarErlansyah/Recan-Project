import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

class PaymentOptionTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final IconGlyph icon;
  final String title;
  final String subtitle;
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
                  ? context.palette.tint.withValues(alpha: 0.3)
                  : context.palette.surface)
            : context.palette.border,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? context.palette.accent : context.palette.border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: active ? AppIcons.checkCircle : AppIcons.radioOff,
                  color: active
                      ? context.palette.accent
                      : context.palette.textSecondary,
                ),
                const SizedBox(width: 12),
                HugeIcon(icon: icon, color: context.palette.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(subtitle, style: textTheme.bodySmall),
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
