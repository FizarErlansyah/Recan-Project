import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';

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
}
