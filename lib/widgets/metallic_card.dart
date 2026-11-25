import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_decorations.dart';
import 'package:mobile_apps_recan/widgets/metal_reflection.dart';
import 'package:mobile_apps_recan/widgets/pressable.dart';

/// Membership-card surface: the hero navy gradient, a deep shadow and a faint
/// Pearl Aqua diagonal sheen. Shared by the balance card and the tier card so
/// both read as one metal-card family.
class MetallicCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppDecorations.radius,
    this.colors = AppColors.heroGradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      enabled: onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: _Face(onTap: onTap, padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The tappable surface with its sheen.
class _Face extends StatelessWidget {
  const new({required this.onTap, required this.padding, required this.child});

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: CustomPaint(
          painter: MetalReflectionPainter.onNavy(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
