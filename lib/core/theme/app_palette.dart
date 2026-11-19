import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// Theme-dependent colour roles. [AppColors] keeps the fixed brand values
/// (emerald hero and fills, silver hairlines on dark chrome, gold gradients);
/// everything that must change between light and dark is read from the active
/// palette so a theme swap needs no feature-level changes.
///
/// `accent` is brand emerald used as text or an icon on a surface; fills keep
/// the fixed [AppColors.primary] so buttons look the same in both themes.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const new({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.tint,
    required this.goldSoft,
    required this.goldText,
    required this.successSoft,
    required this.dangerSoft,
    required this.danger,
    required this.success,
  });

  static const AppPalette light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceMuted: AppColors.surfaceMuted,
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    accent: AppColors.primary,
    tint: AppColors.primarySoft,
    goldSoft: AppColors.goldSoft,
    goldText: AppColors.goldDeep,
    successSoft: AppColors.successSoft,
    dangerSoft: AppColors.dangerSoft,
    danger: AppColors.danger,
    success: AppColors.success,
  );

  // Graphite with a green undertone instead of pure black, so the emerald
  // brand still reads as the same family; Pearl Aqua carries accents.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0B1210),
    surface: Color(0xFF121C19),
    surfaceMuted: Color(0xFF18241F),
    border: Color(0xFF2B3934),
    textPrimary: Color(0xFFE8EEEC),
    textSecondary: Color(0xFFA3B1AC),
    textTertiary: Color(0xFF8A9A94),
    accent: Color(0xFF6FD3B8),
    tint: Color(0xFF143329),
    goldSoft: Color(0xFF2A2412),
    goldText: Color(0xFFD4B06A),
    successSoft: Color(0xFF14352A),
    dangerSoft: Color(0xFF3A1E1B),
    danger: Color(0xFFE57D72),
    success: Color(0xFF5CC7A0),
  );

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Brand emerald as text or icon on a surface.
  final Color accent;

  /// Soft emerald fill behind icons and selected chips.
  final Color tint;
  final Color goldSoft;

  /// Gold dark enough for text on light, bright enough for text on dark.
  final Color goldText;
  final Color successSoft;
  final Color dangerSoft;

  /// Error red for text and icons; fills use the fixed [AppColors.danger].
  final Color danger;

  /// Confirmation green for text and icons.
  final Color success;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? tint,
    Color? goldSoft,
    Color? goldText,
    Color? successSoft,
    Color? dangerSoft,
    Color? danger,
    Color? success,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      tint: tint ?? this.tint,
      goldSoft: goldSoft ?? this.goldSoft,
      goldText: goldText ?? this.goldText,
      successSoft: successSoft ?? this.successSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      goldText: Color.lerp(goldText, other.goldText, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  /// Falls back to the light palette so widgets still build under a bare
  /// `MaterialApp` (tests, previews) that never registered the extension.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
