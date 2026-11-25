import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/pages/checkout_page.dart';
import 'package:mobile_apps_recan/pages/edit_profil_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/activity_detail_sheet.dart';

import 'support/screen.dart';

/// The colour a label is actually painted with, theme defaults included.
Color? _painted(WidgetTester tester, String label) => tester
    .widget<RichText>(
      find.descendant(of: find.text(label), matching: find.byType(RichText)),
    )
    .text
    .style
    ?.color;

void main() {
  tearDown(MockStore.resetDemoState);

  // Dark primary fills are pale aqua, so a hard-coded white label vanishes.
  Future<void> expectsReadableLabel(
    WidgetTester tester,
    Widget screen,
    String label,
  ) async {
    useTallPhone(tester);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.dark, home: screen));
    await tester.pumpAndSettle();

    expect(_painted(tester, label), AppPalette.dark.onPrimary);
  }

  testWidgets('the activity sheet close button', (tester) async {
    await expectsReadableLabel(
      tester,
      Scaffold(
        body: ActivityDetailSheet(
          transaction: ActivityTransaction(
            transactionId: 'REC-1',
            type: ActivityType.deposit,
            title: 't',
            titleEn: 't',
            timestamp: DateTime(2026, 11, 25),
            points: 25,
            weightKg: 0,
          ),
        ),
      ),
      'Tutup',
    );
  });

  testWidgets('the save profile button', (tester) async {
    await expectsReadableLabel(
      tester,
      EditProfilPage(profile: MockStore.profile),
      'Simpan Perubahan',
    );
  });

  testWidgets('the checkout confirm button', (tester) async {
    MockStore.points = 1000000;
    useTallPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: CheckoutPage(product: MockStore.products.first),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'Jalan Bintaro Utama nomor 1, Tangerang Selatan',
    );
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('checkout-confirm')),
        matching: find.byType(Text),
      ),
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('checkout-confirm')),
    );

    expect(button.onPressed, isNotNull);
    expect(label.style!.color, AppPalette.dark.onPrimary);
  });
}
