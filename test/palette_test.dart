import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/services/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('light palette keeps the pre-palette colours', () {
    const light = AppPalette.light;

    expect(light.background, AppColors.background);
    expect(light.surface, AppColors.surface);
    expect(light.surfaceMuted, AppColors.surfaceMuted);
    expect(light.border, AppColors.border);
    expect(light.textPrimary, AppColors.textPrimary);
    expect(light.textSecondary, AppColors.textSecondary);
    expect(light.textTertiary, AppColors.textTertiary);
  });

  test('light theme registers the palette and themes scaffold and text', () {
    final theme = AppTheme.light;

    expect(theme.extension<AppPalette>(), AppPalette.light);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.textTheme.bodyMedium?.color, AppColors.textPrimary);
    expect(theme.textTheme.bodySmall?.color, AppColors.textSecondary);
  });

  test('lerp blends every role and copyWith swaps a single one', () {
    final other = AppPalette.light.copyWith(surface: const Color(0xFF000000));

    expect(other.border, AppPalette.light.border);
    final mid = AppPalette.light.lerp(other, 0.5);
    expect(
      mid.surface,
      Color.lerp(AppColors.surface, const Color(0xFF000000), 0.5),
    );
    expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
  });

  testWidgets('context.palette falls back to light without a theme extension', (
    tester,
  ) async {
    late AppPalette seen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(seen, AppPalette.light);
  });

  group('dark theme', () {
    test('registers the dark palette and themes scaffold and text', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.extension<AppPalette>(), AppPalette.dark);
      expect(theme.scaffoldBackgroundColor, AppPalette.dark.background);
      expect(theme.textTheme.bodyMedium?.color, AppPalette.dark.textPrimary);
      expect(theme.textTheme.bodySmall?.color, AppPalette.dark.textSecondary);
    });

    test('body text and accent clear 4.5:1 on the dark surface', () {
      double luminance(Color c) => c.computeLuminance();
      double contrast(Color a, Color b) {
        final hi = luminance(a) > luminance(b) ? a : b;
        final lo = hi == a ? b : a;
        return (luminance(hi) + 0.05) / (luminance(lo) + 0.05);
      }

      const dark = AppPalette.dark;
      for (final color in [
        dark.textPrimary,
        dark.textSecondary,
        dark.textTertiary,
        dark.accent,
        dark.goldText,
      ]) {
        expect(contrast(color, dark.surface), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('ThemePreference', () {
    tearDown(() => ThemePreference.mode.value = ThemeMode.system);

    test('defaults to following the system', () async {
      SharedPreferences.setMockInitialValues({});
      await ThemePreference.load();

      expect(ThemePreference.mode.value, ThemeMode.system);
    });

    test('persists a choice and restores it on load', () async {
      SharedPreferences.setMockInitialValues({});
      await ThemePreference.select(ThemeMode.dark);
      ThemePreference.mode.value = ThemeMode.system;

      await ThemePreference.load();

      expect(ThemePreference.mode.value, ThemeMode.dark);
    });

    test('ignores an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
      await ThemePreference.load();

      expect(ThemePreference.mode.value, ThemeMode.system);
    });

    testWidgets('the app follows the stored mode and keeps both extensions', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      ThemePreference.mode.value = ThemeMode.dark;

      await tester.pumpWidget(const ReCanApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(app.themeMode, ThemeMode.dark);
      expect(app.darkTheme?.extension<AppPalette>(), AppPalette.dark);
      expect(app.theme?.extension<AppPalette>(), AppPalette.light);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
