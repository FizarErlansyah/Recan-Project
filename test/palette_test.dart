import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/services/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('brand tokens match the official team palette', () {
    expect(AppColors.primary, const Color(0xFF284B63));
    expect(AppColors.primaryDark, const Color(0xFF1B3547));
    expect(AppColors.primaryDeep, const Color(0xFF162B3A));
    expect(AppColors.primarySoft, const Color(0xFFC9EDDC));
    expect(AppColors.textPrimary, const Color(0xFF353535));
    expect(AppColors.textSecondary, const Color(0xFF6A706E));
    expect(AppColors.gold, const Color(0xFFC8A252));
  });

  test('light palette maps the semantic colour tokens', () {
    const light = AppPalette.light;

    expect(light.background, AppColors.background);
    expect(light.surface, AppColors.surface);
    expect(light.surfaceMuted, AppColors.surfaceMuted);
    expect(light.border, AppColors.border);
    expect(light.textPrimary, AppColors.textPrimary);
    expect(light.textSecondary, AppColors.textSecondary);
    expect(light.textTertiary, AppColors.textTertiary);
    expect(light.background, const Color(0xFFF5F8FA));
    expect(light.border, const Color(0xFFD6DFE5));
    expect(light.accent, AppColors.primary);
    expect(light.tint, AppColors.primarySoft);
  });

  test('light text, accent and status roles clear 4.5:1', () {
    const light = AppPalette.light;
    final grounds = [light.surface, light.background, light.surfaceMuted];

    for (final ground in grounds) {
      for (final color in [
        light.textPrimary,
        light.textSecondary,
        light.textTertiary,
        light.accent,
      ]) {
        expect(contrast(color, ground), greaterThanOrEqualTo(4.5));
      }
    }
    expect(contrast(light.success, light.surface), greaterThanOrEqualTo(4.5));
    expect(contrast(light.danger, light.surface), greaterThanOrEqualTo(4.5));
    expect(
      contrast(light.success, light.successSoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(contrast(light.danger, light.dangerSoft), greaterThanOrEqualTo(4.5));
    expect(contrast(light.goldText, light.surface), greaterThanOrEqualTo(4.5));
  });

  test('Yale Blue and Pearl Aqua keep a readable pairing', () {
    expect(
      contrast(AppColors.white, AppColors.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.primarySoft, AppColors.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.primarySoft, AppColors.primaryDark),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.primary, AppColors.primarySoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.textPrimary, AppColors.primarySoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.white, AppColors.success),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.white, AppColors.danger),
      greaterThanOrEqualTo(4.5),
    );
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

    test('body text, accent and status roles clear 4.5:1 on dark grounds', () {
      const dark = AppPalette.dark;
      final grounds = [dark.surface, dark.background, dark.surfaceMuted];

      for (final ground in grounds) {
        for (final color in [
          dark.textPrimary,
          dark.textSecondary,
          dark.textTertiary,
          dark.accent,
          dark.goldText,
          dark.success,
          dark.danger,
        ]) {
          expect(contrast(color, ground), greaterThanOrEqualTo(4.5));
        }
      }
      expect(contrast(dark.accent, dark.tint), greaterThanOrEqualTo(4.5));
      expect(
        contrast(dark.textSecondary, dark.tint),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(dark.success, dark.successSoft),
        greaterThanOrEqualTo(4.5),
      );
      expect(contrast(dark.danger, dark.dangerSoft), greaterThanOrEqualTo(4.5));
      expect(contrast(dark.goldText, dark.goldSoft), greaterThanOrEqualTo(4.5));
    });

    test('Pearl Aqua is the dark accent', () {
      expect(AppPalette.dark.accent, const Color(0xFFC9EDDC));
      expect(AppPalette.dark.background, const Color(0xFF0D161D));
      expect(AppPalette.dark.surface, const Color(0xFF15222C));
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
