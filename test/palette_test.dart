import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_text_styles.dart';
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
  test('brand tokens keep the official team palette', () {
    expect(AppColors.primary, const Color(0xFF284B63));
    expect(AppColors.primaryDark, const Color(0xFF1B3547));
    expect(AppColors.primaryDeep, const Color(0xFF162B3A));
    expect(AppColors.primarySoft, const Color(0xFFC9EDDC));
    expect(AppColors.gold, const Color(0xFFC8A252));
    expect(AppColors.warm, const Color(0xFFFFC247));
  });

  test('light palette follows the Aluminium Fintech sheet', () {
    const light = AppPalette.light;

    expect(light.background, const Color(0xFFEEF3F6));
    expect(light.surface, const Color(0xFFFFFFFF));
    expect(light.tint, const Color(0xFFDDF3E8));
    expect(light.border, const Color(0xFFD5E0E7));
    expect(light.textPrimary, const Color(0xFF14232E));
    expect(light.textSecondary, const Color(0xFF4F606C));
    expect(light.primary, AppColors.primary);
    expect(light.onPrimary, AppColors.white);
    expect(light.warm, AppColors.warm);
    expect(light.goldText, const Color(0xFF835500));
  });

  for (final (name, palette) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    test('$name fills carry readable labels', () {
      for (final (label, fill) in [
        (palette.onPrimary, palette.primary),
        (palette.onWarm, palette.warm),
        (palette.accent, palette.tint),
        (palette.textSecondary, palette.tint),
      ]) {
        expect(contrast(label, fill), greaterThanOrEqualTo(4.5));
      }
    });

    test('$name buttons stand out from the card they sit on', () {
      expect(
        contrast(palette.primary, palette.surface),
        greaterThanOrEqualTo(3),
      );
    });
  }

  test('themed buttons use the primary of their own mode', () {
    for (final (theme, palette) in [
      (AppTheme.light, AppPalette.light),
      (AppTheme.dark, AppPalette.dark),
    ]) {
      final style = theme.filledButtonTheme.style!;
      expect(style.backgroundColor!.resolve({}), palette.primary);
      expect(style.foregroundColor!.resolve({}), palette.onPrimary);
    }
  });

  test('the type scale separates balance, page, section, card and body', () {
    final text = AppTheme.light.textTheme;

    expect(
      [
        text.displayMedium,
        text.headlineSmall,
        text.titleLarge,
        text.titleMedium,
        text.bodyMedium,
        text.bodySmall,
      ].map((style) => style!.fontSize),
      [40, 24, 18, 15, 14, 12],
    );
  });

  test('tabular figures give every digit the same width', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final bytes = File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync();
    final loader = FontLoader(AppTextStyles.fontFamily)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();

    double width(String digits, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: digits, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }

    final plain = AppTheme.light.textTheme.displayMedium!;
    final tabular = AppTextStyles.tabular(plain);

    expect(width('1111', plain), isNot(closeTo(width('0000', plain), 0.5)));
    expect(width('1111', tabular), closeTo(width('0000', tabular), 0.5));
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

  test('the native splash colour matches the middle of the Flutter one', () {
    final middle = Color.lerp(
      AppColors.heroGradient.first,
      AppColors.heroGradient.last,
      0.5,
    )!;
    final hex = (middle.toARGB32() & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    final colors = File('android/app/src/main/res/values/colors.xml')
        .readAsStringSync();

    expect(colors, contains('<color name="splash_background">#$hex</color>'));
  });

  test('hero surfaces keep their text readable', () {
    for (final ground in AppColors.heroGradient) {
      for (final text in [
        AppColors.white,
        AppColors.primarySoft,
        AppColors.warm,
      ]) {
        expect(contrast(text, ground), greaterThanOrEqualTo(4.5));
      }
    }
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

    test('aqua leads on a deep navy ground', () {
      expect(AppPalette.dark.accent, const Color(0xFFA8E6CF));
      expect(AppPalette.dark.primary, const Color(0xFFA8E6CF));
      expect(AppPalette.dark.background, const Color(0xFF0A131A));
      expect(AppPalette.dark.surface, const Color(0xFF14222D));
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
