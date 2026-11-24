import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// Frosted panel for chrome that floats over the live camera feed.
///
/// Glass only reads well on top of imagery, so this is used on the scan screen
/// alone; on the light app background it would look washed out.
class FrostedGlass extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.radius = 16,
    this.blur = 18,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: shape,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.28)),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    super.key,
    this.active = false,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: FrostedGlass(
        radius: 24,
        child: Material(
          color: active
              ? AppColors.primarySoft.withValues(alpha: 0.32)
              : AppColors.transparent,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(width: 48, height: 48, child: Center(child: icon)),
          ),
        ),
      ),
    );
  }
}
