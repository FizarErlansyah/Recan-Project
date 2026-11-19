import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/pages/about_recan_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';

void main() {
  tearDown(MockStore.resetDemoState);

  test('granting demo points adds the fixed amount to the profile', () {
    final before = MockStore.profile.points;

    MockStore.grantDemoPoints();

    expect(MockStore.profile.points, before + MockStore.demoPointsGrant);
  });

  test(
    'reset returns points, history and vouchers to the zero state',
    () async {
      MockStore.grantDemoPoints();
      await TransactionService.redeemVoucher(MockStore.vouchers.first);
      expect(MockStore.activities, isNotEmpty);
      expect(MockStore.ownedVouchers, isNotEmpty);

      MockStore.resetDemoState();

      expect(MockStore.points, 0);
      expect(MockStore.activities, isEmpty);
      expect(MockStore.ownedVouchers, isEmpty);
      expect(MockStore.userTotalCans, 0);
    },
  );

  group('About page', () {
    Future<void> openTools(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AboutRecanPage()));
      await tester.longPress(find.textContaining('Versi'));
      await tester.pumpAndSettle();
    }

    testWidgets('a normal tap on the version chip shows nothing hidden', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AboutRecanPage()));
      await tester.tap(find.textContaining('Versi'));
      await tester.pumpAndSettle();

      expect(find.text('Alat Demo'), findsNothing);
    });

    testWidgets('long-pressing the chip adds demo points', (tester) async {
      await openTools(tester);
      expect(find.text('Alat Demo'), findsOneWidget);

      await tester.tap(find.textContaining('Tambah +'));
      await tester.pumpAndSettle();

      expect(MockStore.points, MockStore.demoPointsGrant);
      expect(find.text('Alat Demo'), findsNothing);
    });

    testWidgets('long-pressing the chip can reset back to zero', (
      tester,
    ) async {
      MockStore.grantDemoPoints();
      await openTools(tester);

      await tester.tap(find.text('Reset ke 0'));
      await tester.pumpAndSettle();

      expect(MockStore.points, 0);
    });
  });
}
