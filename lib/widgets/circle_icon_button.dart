import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';

class CircleIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    super.key,
  });

  final AppIconBuilder icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.scrim.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: icon(color: AppColors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
