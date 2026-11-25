import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/payment_methods_section.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_catalog_view.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/about_recan_page.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/activity_tile.dart';
import 'package:mobile_apps_recan/widgets/ewallet_catalog_view.dart';
import 'package:mobile_apps_recan/widgets/quest_card.dart';
import 'package:mobile_apps_recan/widgets/settings_sheets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/screen.dart';

ActivityTransaction _order({
  required int points,
  required int cash,
  required bool simulated,
}) => ActivityTransaction(
  transactionId: 'REC-ROW01',
  type: ActivityType.redeem,
  title: 'Pesanan',
  titleEn: 'Order',
  timestamp: DateTime(2026, 11, 25),
  points: -points,
  weightKg: 0,
  payment: PurchaseReceipt(
    reference: 'REC-ROW01',
    pointsUsed: points,
    cashPaid: cash,
    simulated: simulated,
  ),
);

void main() {
  tearDown(() {
    MockStore.resetDemoState();
    MockStore.isEnglish.value = false;
  });

  group('redeem confirmation', () {
    final confirm = find.byKey(const ValueKey('redeem-confirm'));

    for (final (name, view, points) in [
      ('voucher', VoucherCatalogView(onLogout: () {}), 500),
      ('e-wallet', EWalletCatalogView(onLogout: () {}), 20000),
    ]) {
      Future<Finder> open(WidgetTester tester, {required int balance}) async {
        MockStore.points = balance;
        useTallPhone(tester);
        await tester.pumpWidget(testApp(Scaffold(body: view)));
        await tester.pumpAndSettle();
        // Vouchers are redeemed from their detail screen, e-wallets in place.
        if (name == 'voucher') {
          await tester.tap(find.text('Diskon Kuliner 20%'));
          await tester.pumpAndSettle();
        }
        return find.widgetWithText(FilledButton, 'Tukar').first;
      }

      testWidgets('$name: a tap asks first and cancel spends nothing', (
        tester,
      ) async {
        final redeem = await open(tester, balance: points);

        await tester.tap(redeem);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(MockStore.points, points);

        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(MockStore.points, points);
        expect(MockStore.activities, isEmpty);
      });

      testWidgets('$name: confirming redeems exactly once', (tester) async {
        final redeem = await open(tester, balance: points);

        await tester.tap(redeem);
        await tester.tap(redeem, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(confirm);
        await tester.pumpAndSettle();

        expect(MockStore.activities, hasLength(1));
        expect(MockStore.points, 0);
        expect(find.byType(CheckoutSuccessPage), findsOneWidget);
      });

      testWidgets('$name: a short balance is told so without a dialog', (
        tester,
      ) async {
        final redeem = await open(tester, balance: 1);

        await tester.tap(redeem);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Poin kamu tidak cukup.'), findsOneWidget);
        expect(MockStore.activities, isEmpty);
      });
    }
  });

  testWidgets('the receipt copies the transaction code', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    useTallPhone(tester);
    await tester.pumpWidget(
      testApp(
        const CheckoutSuccessPage(
          productName: 'Vas',
          receipt: PurchaseReceipt(
            reference: 'REC-COPY1',
            pointsUsed: 5,
            cashPaid: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Simpan'), findsNothing);

    await tester.tap(find.text('Salin Kode Transaksi'));
    await tester.pumpAndSettle();

    expect(copied, 'REC-COPY1');
    expect(find.text('Kode transaksi REC-COPY1 disalin'), findsOneWidget);
  });

  group('history rows', () {
    final badge = find.byKey(const ValueKey('simulated-badge'));

    Future<void> show(WidgetTester tester, ActivityTransaction row) =>
        tester.pumpWidget(
          testApp(Scaffold(body: ActivityTile(transaction: row, isLast: true))),
        );

    testWidgets('hybrid and cash orders carry the simulated badge', (
      tester,
    ) async {
      await show(tester, _order(points: 16, cash: 89840, simulated: true));
      expect(badge, findsOneWidget);
      expect(find.text('+ Rp 89.840'), findsOneWidget);

      await show(tester, _order(points: 0, cash: 90000, simulated: true));
      expect(badge, findsOneWidget);
      expect(find.text('Simulasi'), findsOneWidget);
    });

    testWidgets('a points order carries none', (tester) async {
      await show(tester, _order(points: 300, cash: 0, simulated: false));

      expect(badge, findsNothing);
      expect(find.text('Berhasil'), findsOneWidget);
    });

    test('the badge follows the server payment status', () {
      ActivityTransaction row(String status) => ActivityTransaction.fromJson({
        'reference': 'REC-1',
        'type': 'redeem',
        'title': 't',
        'title_en': 't',
        'created_at': '2026-11-25T03:00:00+00:00',
        'points_delta': 0,
        'weight_kg': 0,
        'payment_method': 'cash',
        'points_used': 0,
        'cash_paid': 90000,
        'payment_status': status,
      });

      expect(row('simulated').payment?.simulated, isTrue);
      expect(row('paid').payment?.simulated, isFalse);
    });
  });

  testWidgets('the profile balance is in points, never in rupiah', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: PaymentMethodsSection(
            points: 1400,
            gopayConnected: false,
            onConnectGoPay: () async {},
          ),
        ),
      ),
    );

    expect(find.text('1.400 Poin'), findsOneWidget);
    expect(find.textContaining('Rp'), findsNothing);
  });

  testWidgets('a four digit reward has a thousands separator', (tester) async {
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: QuestCard(
            quest: const DailyQuest(
              id: 9,
              title: 'Setor 100',
              progress: 0,
              target: 100,
              unit: 'Kaleng',
              rewardPoints: 1500,
              isClaimed: false,
            ),
            onClaim: () async => false,
          ),
        ),
      ),
    );

    expect(find.text('+1.500 Poin'), findsOneWidget);
  });

  group('version', () {
    test('matches pubspec.yaml', () {
      final declared = RegExp(
        r'^version: (.+)$',
        multiLine: true,
      ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!.trim();

      expect(
        '${SettingsSheets.appVersion}+${SettingsSheets.appBuild}',
        declared,
      );
    });

    testWidgets('About shows version and build', (tester) async {
      await tester.pumpWidget(testApp(const AboutRecanPage()));

      expect(find.text('Versi 2.1.0 (build 3)'), findsOneWidget);
    });
  });

  testWidgets('the system back button speaks the app language', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push<void>(
          MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar())),
        )
        .ignore();
    await tester.pumpAndSettle();

    expect(find.byTooltip('Kembali'), findsOneWidget);

    MockStore.isEnglish.value = true;
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back'), findsOneWidget);
  });
}
