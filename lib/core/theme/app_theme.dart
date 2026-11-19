import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_text_styles.dart';

class AppTheme {
  const new _();

  static const double radius = 16;
  static const double controlRadius = 12;
  static const double fieldRadius = 16;

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final overlay = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    final makeScheme = isDark ? ColorScheme.dark : ColorScheme.light;
    final scheme = makeScheme(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      surface: palette.surface,
      primaryContainer: palette.tint,
      onPrimaryContainer: isDark ? palette.accent : AppColors.primaryDeep,
      secondary: AppColors.silver,
      onSecondary: AppColors.primaryDeep,
      secondaryContainer: palette.surfaceMuted,
      onSecondaryContainer: isDark
          ? palette.textSecondary
          : AppColors.slateDeep,
      tertiary: AppColors.gold,
      onTertiary: AppColors.primaryDeep,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerHighest: palette.surfaceMuted,
      error: palette.danger,
      outline: palette.border,
      outlineVariant: palette.border,
      shadow: AppColors.shadowStrong,
      // Disables M3 tonal tint so surfaces stay pure white at any elevation.
      surfaceTint: AppColors.transparent,
    );

    final textTheme = AppTextStyles.textThemeFor(palette);
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    final buttonText = textTheme.titleMedium;

    // Resting fields rely on the muted fill alone; an outline appears only for
    // focus and error so users always see which field is active or invalid.
    OutlineInputBorder fieldBorder([BorderSide side = BorderSide.none]) {
      return OutlineInputBorder(
        borderSide: side,
        borderRadius: BorderRadius.circular(fieldRadius),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [palette],
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.border,
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary),
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: overlay,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: palette.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: palette.surfaceMuted,
          disabledForegroundColor: palette.textTertiary,
          minimumSize: const Size(48, 48),
          padding: buttonPadding,
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(48, 48),
          padding: buttonPadding,
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accent,
          minimumSize: const Size(48, 48),
          padding: buttonPadding,
          shape: controlShape,
          side: BorderSide(color: palette.border),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accent,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textTertiary),
        labelStyle: textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: palette.accent,
        ),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
        border: fieldBorder(),
        enabledBorder: fieldBorder(),
        disabledBorder: fieldBorder(),
        focusedBorder: fieldBorder(
          BorderSide(color: palette.accent, width: 1.5),
        ),
        errorBorder: fieldBorder(
          const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: fieldBorder(
          const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: palette.accent,
        unselectedItemColor: palette.textTertiary,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.tint,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? palette.accent
                : palette.textTertiary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.accent
                : palette.textTertiary,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: palette.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.tint,
        side: BorderSide(color: palette.border),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearTrackColor: palette.surfaceMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? palette.surfaceMuted : AppColors.scrim,
        elevation: 0,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? palette.textPrimary : AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
    );
  }
}
