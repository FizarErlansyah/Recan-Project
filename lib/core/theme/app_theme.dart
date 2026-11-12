import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_text_styles.dart';

class AppTheme {
  const new _();

  static const double radius = 16;
  static const double controlRadius = 12;
  static const double fieldRadius = 16;

  static ThemeData get theme {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDeep,
      secondary: AppColors.sage,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.primarySoft,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.clay,
      onTertiary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerHighest: AppColors.surfaceMuted,
      error: AppColors.danger,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      shadow: AppColors.shadowStrong,
      // Disables M3 tonal tint so surfaces stay pure white at any elevation.
      surfaceTint: AppColors.transparent,
    );

    final textTheme = AppTextStyles.textTheme;
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
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textTertiary,
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
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          padding: buttonPadding,
          shape: controlShape,
          side: const BorderSide(color: AppColors.border),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: fieldBorder(),
        enabledBorder: fieldBorder(),
        disabledBorder: fieldBorder(),
        focusedBorder: fieldBorder(
          const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: fieldBorder(
          const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: fieldBorder(
          const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        side: const BorderSide(color: AppColors.border),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySoft,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.scrim,
        elevation: 0,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
    );
  }
}
