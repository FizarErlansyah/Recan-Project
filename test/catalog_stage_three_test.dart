import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/checkout_page.dart';
import 'package:mobile_apps_recan/pages/katalog_page.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/can_placeholder.dart';
import 'package:mobile_apps_recan/widgets/cover_image.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_amount.dart';
import 'package:mobile_apps_recan/widgets/product_card.dart';
import 'package:mobile_apps_recan/widgets/sliding_segments.dart';

import 'support/screen.dart';

void main() {
  tearDown(MockStore.resetDemoState);

  group('stock badge', () {
    Future<void> show(WidgetTester tester, int stock) => tester.pumpWidget(
      testApp(
        Scaffold(
          body: Center(
            child: ProductCard(
              product: MockStore.products.first.withStock(stock),
            ),
          ),
        ),
      ),
    );

    testWidgets('stays away while there is plenty', (tester) async {
      await show(tester, 6);

      expect(find.byKey(const ValueKey('stock-badge')), findsNothing);
    });

    testWidgets('warns at five or fewer', (tester) async {
      await show(tester, 5);

      expect(find.text('Sisa 5'), findsOneWidget);
    });

    testWidgets('says when it is sold out', (tester) async {
      await show(tester, 0);

      expect(find.text('Habis'), findsOneWidget);
    });
  });

  testWidgets('grid photos are square', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(411, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(Scaffold(body: KatalogPage(onLogout: () {}))),
    );
    await tester.pumpAndSettle();

    final photo = tester.getSize(find.byType(CoverImage).first);

    expect(photo.width, greaterThan(150));
    expect(photo.height, closeTo(photo.width, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the detail photo is four by three', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(ProductDetailPage(product: MockStore.products.first)),
    );
    await tester.pumpAndSettle();

    final photo = tester.getSize(find.byType(CoverImage));

    expect(photo.width / photo.height, closeTo(4 / 3, 0.02));
  });

  group('placeholder art', () {
    test('gives every seeded craft its own drawing', () {
      final drawings = [
        for (final product in MockStore.products)
          ProductArt.of(product.category, product.id),
      ];

      expect(drawings.toSet(), hasLength(MockStore.products.length));
    });

    test('keeps toys and decor apart', () {
      expect(ProductArt.of(ProductCategory.toy, 1), ProductArt.raceCar);
      expect(ProductArt.of(ProductCategory.decor, 5), ProductArt.vase);
    });

    testWidgets('paints each drawing without errors', (tester) async {
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: Wrap(
              children: [
                for (final art in ProductArt.values)
                  SizedBox.square(
                    dimension: 120,
                    child: CanPlaceholder(seed: art.index, art: art),
                  ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('sliding filter', () {
    Widget host(ValueChanged<int> onSelected, int selected) => testApp(
      Scaffold(
        body: SlidingSegments(
          labels: const ['Semua', 'Mainan', 'Hiasan'],
          selectedIndex: selected,
          onSelected: onSelected,
        ),
      ),
    );

    double thumb(WidgetTester tester) =>
        tester.getTopLeft(find.byKey(const ValueKey('segment-thumb'))).dx;

    testWidgets('slides to the new choice instead of jumping', (tester) async {
      var chosen = 0;
      await tester.pumpWidget(host((value) => chosen = value, 0));
      final start = thumb(tester);
      await tester.tap(find.text('Hiasan'));
      expect(chosen, 2);

      await tester.pumpWidget(host((_) {}, 2));
      await tester.pump(const Duration(milliseconds: 100));
      final midway = thumb(tester);
      await tester.pumpAndSettle();

      expect(midway, inExclusiveRange(start, thumb(tester)));
    });

    testWidgets('narrows the craft grid', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(Scaffold(body: KatalogPage(onLogout: () {}))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsNWidgets(6));

      await tester.tap(find.text('Hiasan'));
      await tester.pumpAndSettle();

      expect(find.byType(ProductCard), findsNWidgets(3));
    });
  });

  group('animated amount', () {
    Widget host(int value, {bool still = false}) => testApp(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: still),
          child: AnimatedAmount(value: value, format: (v) => 'Rp $v'),
        ),
      ),
    );

    testWidgets('opens on the value and glides to a new one', (tester) async {
      await tester.pumpWidget(host(100));
      expect(find.text('Rp 100'), findsOneWidget);

      await tester.pumpWidget(host(900));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Rp 900'), findsNothing);
      await tester.pumpAndSettle();

      expect(find.text('Rp 900'), findsOneWidget);
    });

    testWidgets('jumps under reduced motion', (tester) async {
      await tester.pumpWidget(host(100, still: true));
      await tester.pumpWidget(host(900, still: true));

      expect(find.text('Rp 900'), findsOneWidget);
    });

    testWidgets('drives the checkout breakdown', (tester) async {
      MockStore.points = 50000;
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(CheckoutPage(product: MockStore.products.first)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedAmount), findsAtLeastNWidgets(3));
    });
  });
}
