import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';

import 'support/screen.dart';

void main() {
  tearDown(MockStore.resetDemoState);

  /// Scrolls the visible list to its end and returns its lowest line of text.
  Future<double> lowestText(WidgetTester tester) async {
    final list = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .first;
    // Several times: a lazy list only learns its length while it scrolls.
    for (var i = 0; i < 4; i++) {
      final position = tester.state<ScrollableState>(list).position;
      position.jumpTo(position.maxScrollExtent);
      await pumpFrames(tester, 5);
    }
    final texts = find.descendant(of: list, matching: find.byType(Text));
    return [
      for (var i = 0; i < texts.evaluate().length; i++)
        tester.getRect(texts.at(i)).bottom,
    ].reduce((a, b) => a > b ? a : b);
  }

  Future<void> open(WidgetTester tester, String tab) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(411, 760);
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);
    for (var i = 0; i < 8; i++) {
      MockStore.recordDeposit(i + 1);
    }
    await tester.pumpWidget(testApp(const HomePage()));
    await pumpFrames(tester);
    await tester.tap(find.text(tab).last);
    await pumpFrames(tester);
  }

  Future<void> expectClear(WidgetTester tester) async {
    final bottom = await lowestText(tester);
    final bar = tester.getRect(find.byType(MainNavBar));

    expect(bottom, lessThanOrEqualTo(bar.top));
  }

  for (final tab in ['Beranda', 'Katalog', 'Aktivitas', 'Profil']) {
    testWidgets('$tab scrolls its last line clear of the bubble', (
      tester,
    ) async {
      await open(tester, tab);
      await expectClear(tester);
    });
  }

  for (final section in ['E-Wallet', 'Voucher']) {
    testWidgets('Katalog $section clears the bubble too', (tester) async {
      await open(tester, 'Katalog');
      await tester.tap(find.text(section));
      await pumpFrames(tester);
      await expectClear(tester);
    });
  }

  testWidgets('content runs under the notch', (tester) async {
    await open(tester, 'Beranda');

    final shell = tester.widget<Scaffold>(
      find.ancestor(
        of: find.byType(MainNavBar),
        matching: find.byType(Scaffold),
      ),
    );
    expect(shell.extendBody, isTrue);
  });
}
