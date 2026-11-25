import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';

/// Theme-dependent colour roles. [AppColors] keeps the fixed brand values
/// (Yale Blue hero and fills, silver hairlines on dark chrome, gold gradients);
/// everything that must change between light and dark is read from the active
/// palette so a theme swap needs no feature-level changes.
///
/// `accent` is the brand colour used as text or an icon on a surface, `primary`
/// the fill of the main action: Yale Blue on light, aqua on dark, where a Yale
/// Blue button would sink into the card.
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
    required this.primary,
    required this.onPrimary,
    required this.warm,
    required this.onWarm,
    required this.shadow,
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
    tint: Color(0xFFDDF3E8),
    goldSoft: AppColors.warmSoft,
    goldText: AppColors.goldDeep,
    successSoft: AppColors.successSoft,
    dangerSoft: AppColors.dangerSoft,
    danger: AppColors.danger,
    success: AppColors.success,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    warm: AppColors.warm,
    onWarm: AppColors.onWarm,
    shadow: AppColors.shadowSoft,
  );

  // Deep navy instead of pure black, so Yale Blue still reads as the same
  // family; depth comes from lighter surfaces because shadows vanish here.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0A131A),
    surface: Color(0xFF14222D),
    surfaceMuted: Color(0xFF1A2C39),
    border: Color(0xFF294353),
    textPrimary: Color(0xFFEAF2F6),
    textSecondary: Color(0xFFA6B8C4),
    textTertiary: Color(0xFFA6B8C4),
    accent: Color(0xFFA8E6CF),
    tint: Color(0xFF1D3544),
    goldSoft: Color(0xFF33280F),
    goldText: Color(0xFFFFC857),
    successSoft: Color(0xFF123A30),
    dangerSoft: Color(0xFF3D2224),
    danger: Color(0xFFFF8A7D),
    success: Color(0xFF5ED3A8),
    primary: Color(0xFFA8E6CF),
    onPrimary: Color(0xFF0B2231),
    warm: Color(0xFFFFC857),
    onWarm: AppColors.onWarm,
    shadow: AppColors.transparent,
  );

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Brand colour as text or icon on a surface.
  final Color accent;

  /// Soft fill behind icons and selected chips: pale aqua on light, deep
  /// Yale Blue on dark.
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

  /// Fill of the main action and the label on it.
  final Color primary;
  final Color onPrimary;

  /// Reward fill (points, streaks, claims) and the label on it.
  final Color warm;
  final Color onWarm;
  final Color shadow;

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
    Color? primary,
    Color? onPrimary,
    Color? warm,
    Color? onWarm,
    Color? shadow,
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
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      warm: warm ?? this.warm,
      onWarm: onWarm ?? this.onWarm,
      shadow: shadow ?? this.shadow,
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
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      warm: Color.lerp(warm, other.warm, t)!,
      onWarm: Color.lerp(onWarm, other.onWarm, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
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
