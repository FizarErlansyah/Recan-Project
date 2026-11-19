import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/pages/beranda_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/promo_banner_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Login leads to Beranda without hanging', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    addTearDown(() => MockStore.isEnglish.value = false);

    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Tester');
    await tester.enterText(fields.at(1), 'tester@upj.ac.id');
    await tester.enterText(fields.at(2), 'secret');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));

    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(tester.takeException(), isNull);
    expect(find.byType(BerandaPage), findsOneWidget);
    expect(find.byType(PromoBannerCarousel), findsOneWidget);
    expect(find.text('Hai Tester'), findsOneWidget);

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
