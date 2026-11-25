import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/pages/beranda_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/promo_banner_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Login leads to Beranda without hanging', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    addTearDown(() => MockStore.isEnglish.value = false);

    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'tester@mail.com');
    await tester.enterText(fields.at(1), 'secret');
    final submit = find.byKey(const ValueKey('auth-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);

    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(tester.takeException(), isNull);
    expect(find.byType(BerandaPage), findsOneWidget);
    expect(find.text('Hai Tester'), findsOneWidget);

    // The carousel sits below the personal sections, so it is built on scroll.
    await tester.scrollUntilVisible(
      find.byType(PromoBannerCarousel),
      300,
      scrollable: find
          .descendant(
            of: find.byType(BerandaPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );

    for (var cycle = 0; cycle < 20; cycle++) {
      for (var i = 0; i < 42; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
    }

    expect(find.byType(PromoBannerCarousel), findsOneWidget);
    semantics.dispose();
  });
}
