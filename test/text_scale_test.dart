import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/category_menu.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';

Widget _scaled(
  Widget child, {
  required double scale,
  required ThemeData theme,
}) {
  return MaterialApp(
    theme: theme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  const scales = [1.0, 1.3, 2.0];

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final scale in scales) {
      final mode = theme.brightness.name;

      testWidgets('ProductCard has no overflow at ${scale}x ($mode)', (
        tester,
      ) async {
        final product = MockStore.products.first;
        await tester.pumpWidget(
          _scaled(
            Builder(
              builder: (context) => SizedBox(
                width: ProductCard.width,
                height: ProductCard.heightOf(context),
                child: ProductCard(product: product, onTap: () {}),
              ),
            ),
            scale: scale,
            theme: theme,
          ),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'CategoryMenu keeps long labels visible at ${scale}x ($mode)',
        (tester) async {
          await tester.pumpWidget(
            _scaled(
              CategoryMenu(
                entries: [
                  for (final label in [
                    'Tukar Poin',
                    'Misi & Hadiah',
                    'Drop Station',
                    'Edukasi',
                  ])
                    CategoryMenuEntry(
                      icon: hugeIcon(AppIcons.gift),
                      label: label,
                      onTap: () {},
                    ),
                ],
              ),
              scale: scale,
              theme: theme,
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.text('Misi & Hadiah'), findsOneWidget);
        },
      );
    }
  }
}
