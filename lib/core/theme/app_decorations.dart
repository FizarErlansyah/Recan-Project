import 'package:flutter/material.dart';

import 'package:mobile_apps_recan/core/theme/app_palette.dart';

/// Flat surfaces: structure comes from a 1px brushed-silver border, never from
/// shadow, so every card reads as machined metal rather than floating paper.
class AppDecorations {
  const new _();

  static const double radius = 16;

  static BoxDecoration card(
    BuildContext context, {
    Color? color,
    double radius = AppDecorations.radius,
  }) {
    final palette = context.palette;
    return BoxDecoration(
      color: color ?? palette.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: palette.border),
    );
  }
}
