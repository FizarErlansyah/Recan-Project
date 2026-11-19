import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';

class AppTextStyles {
  const new _();

  static const String fontFamily = 'PlusJakartaSans';

  static TextStyle _style(
    double size,
    FontWeight weight, {
    Color color = AppColors.textPrimary,
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    // The bundled font is a single variable file, so the weight must also be
    // sent as the wght axis or every style would render at the default weight.
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme get textTheme => TextTheme(
    displayLarge: _style(40, FontWeight.w800, height: 1.15, letterSpacing: -1),
    displayMedium: _style(
      34,
      FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.8,
    ),
    displaySmall: _style(28, FontWeight.w700, height: 1.2, letterSpacing: -0.5),
    headlineLarge: _style(
      26,
      FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.4,
    ),
    headlineMedium: _style(
      24,
      FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.3,
    ),
    headlineSmall: _style(
      20,
      FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.2,
    ),
    titleLarge: _style(16, FontWeight.w700, height: 1.35),
    titleMedium: _style(14, FontWeight.w600, height: 1.35),
    titleSmall: _style(13, FontWeight.w600, height: 1.35),
    bodyLarge: _style(15, FontWeight.w400, height: 1.5),
    bodyMedium: _style(13, FontWeight.w400, height: 1.5),
    bodySmall: _style(11, FontWeight.w400, color: AppColors.textSecondary),
    labelLarge: _style(12, FontWeight.w600, letterSpacing: 0.1),
    labelMedium: _style(11, FontWeight.w600, letterSpacing: 0.2),
    labelSmall: _style(10, FontWeight.w600, letterSpacing: 0.3),
  );
}
