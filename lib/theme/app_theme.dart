import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_apps_recan/theme/app_colors.dart';

class AppTheme {
  const new _();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.yaleBlue,
      secondary: AppColors.pearlAqua,
      onSecondary: AppColors.graphite,
      onSurface: AppColors.graphite,
      error: AppColors.danger,
      outline: AppColors.divider,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    final body = GoogleFonts.monaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.graphite, displayColor: AppColors.graphite);
    TextStyle heading(double size, {Color color = AppColors.graphite}) =>
        GoogleFonts.raleway(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.25,
        );

    final textTheme = body.copyWith(
      displaySmall: heading(28),
      headlineMedium: heading(24),
      headlineSmall: heading(20),
      titleLarge: heading(16),
      titleMedium: heading(14),
      titleSmall: heading(13),
      labelLarge: heading(12),
      labelMedium: heading(11),
      labelSmall: heading(10),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 13),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 11,
        color: AppColors.dimGrey,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.yaleBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.pearlAqua,
        surfaceTintColor: AppColors.white,
        elevation: 8,
        shadowColor: AppColors.shadow,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.yaleBlue
                : AppColors.dimGrey,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.yaleBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yaleBlue, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.graphite,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
