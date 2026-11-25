import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';

/// Three depths: the canvas, cards lifted by a soft shadow (by a lighter
/// surface in dark mode) and the navy hero. Nothing else invents its own.
class AppDecorations {
  const new _();

  static const double controlRadius = 12;
  static const double radius = 20;
  static const double heroRadius = 28;

  static BoxDecoration card(
    BuildContext context, {
    Color? color,
    double radius = AppDecorations.radius,
  }) {
    final palette = context.palette;
    return BoxDecoration(
      color: color ?? palette.surface,
      borderRadius: BorderRadius.circular(radius),
      border: context.isDark
          ? Border.all(color: palette.border.withValues(alpha: 0.5))
          : null,
      boxShadow: softShadow(context),
    );
  }

  static List<BoxShadow> softShadow(BuildContext context) => [
    BoxShadow(
      color: context.palette.shadow,
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Secondary block inside a screen: a flat tint, no lift.
  static BoxDecoration tinted(
    BuildContext context, {
    double radius = AppDecorations.radius,
  }) => BoxDecoration(
    color: context.palette.tint,
    borderRadius: BorderRadius.circular(radius),
  );

  static BoxDecoration hero({double radius = AppDecorations.heroRadius}) =>
      BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(radius),
      );
}
