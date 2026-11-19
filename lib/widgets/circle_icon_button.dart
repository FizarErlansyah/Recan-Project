import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

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
        color: context.palette.surface.withValues(alpha: 0.92),
        shape: CircleBorder(side: BorderSide(color: context.palette.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(child: icon(color: context.palette.accent, size: 22)),
          ),
        ),
      ),
    );
  }
}
