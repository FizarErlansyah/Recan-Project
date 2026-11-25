import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/checkout_page.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/backend/app_backend.dart';
import 'package:mobile_apps_recan/services/backend/mock_backend.dart';
import 'package:mobile_apps_recan/services/home_navigation.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:mobile_apps_recan/widgets/activity_detail_sheet.dart';
import 'package:mobile_apps_recan/widgets/activity_style.dart';
import 'package:mobile_apps_recan/widgets/single_flight.dart';

import 'support/screen.dart';

// Rp 150.000 or 15.000 points.
PaymentQuote _quote({
  required int balance,
  required int requested,
  int quantity = 1,
  int priceIdr = 150000,
  int pricePoints = 15000,
}) => PaymentQuote.of(
  unitPriceIdr: priceIdr,
  unitPricePoints: pricePoints,
  quantity: quantity,
  balance: balance,
  requestedPoints: requested,
);

void main() {
  late List<UpcycleProduct> products;
  late List<DailyQuest> quests;

  setUp(() {
    products = List.of(MockStore.products);
    quests = List.of(MockStore.quests);
  });

  tearDown(() {
    Backend.current = MockBackend();
    MockStore.products.setAll(0, products);
    MockStore.quests.setAll(0, quests);
    MockStore.resetDemoState();
    HomeNavigation.requestedTab.value = null;
  });

  group('quote', () {
    test('partial points reduce rupiah by the price ratio', () {
      final quote = _quote(balance: 5000, requested: 5000);

      expect(quote.mode, PaymentMode.hybrid);
      expect(quote.pointsUsed, 5000);
      expect(quote.discountIdr, 50000);
      expect(quote.cashDue, 100000);
    });

    test('no points means full cash', () {
      final quote = _quote(balance: 0, requested: 15000);

      expect(quote.mode, PaymentMode.cash);
      expect(quote.pointsUsed, 0);
      expect(quote.cashDue, 150000);
    });

    test('enough points can cover the whole price', () {
      final quote = _quote(balance: 20000, requested: 20000);

      expect(quote.mode, PaymentMode.points);
      expect(quote.pointsUsed, 15000);
      expect(quote.cashDue, 0);
    });

    test('points are clamped to the balance and never negative', () {
      expect(_quote(balance: 300, requested: 9000).pointsUsed, 300);
      expect(_quote(balance: 300, requested: -5).pointsUsed, 0);
    });

    test('quantity scales both prices', () {
      final quote = _quote(balance: 15000, requested: 15000, quantity: 2);

      expect(quote.grossIdr, 300000);
      expect(quote.fullPoints, 30000);
      expect(quote.cashDue, 150000);
    });

    test('the discount rounds down like the server', () {
      final quote = _quote(
        balance: 1,
        requested: 1,
        priceIdr: 100000,
        pricePoints: 30000,
      );

      expect(quote.discountIdr, 3);
      expect(quote.cashDue, 99997);
    });

    test('points that would buy no discount are not spent', () {
      final quote = _quote(
        balance: 1,
        requested: 1,
        priceIdr: 100,
        pricePoints: 1000,
      );

      expect(quote.pointsUsed, 0);
      expect(quote.mode, PaymentMode.cash);
    });
  });

  group('mock checkout', () {
    Future<PurchaseReceipt> buy(int points, PaymentChannel? channel) =>
        TransactionService.redeem(
          productId: 1,
          quantity: 1,
          shippingAddress: 'Jl. Mawar 1',
          pointsUsed: points,
          channel: channel,
        );

    test(
      'cash works with an empty balance and earns no redeem quest',
      () async {
        final receipt = await buy(0, PaymentChannel.qris);

        expect(receipt.mode, PaymentMode.cash);
        expect(receipt.cashPaid, 150000);
        expect(MockStore.points, 0);
        expect(MockStore.quests.firstWhere((q) => q.id == 8).progress, 0);
        expect(MockStore.activities.single.amountLabel, '-Rp 150.000');
      },
    );

    test('hybrid spends the chosen points', () async {
      MockStore.points = 6000;

      final receipt = await buy(5000, PaymentChannel.bankTransfer);

      expect(MockStore.points, 1000);
      expect(receipt.cashPaid, 100000);
      expect(MockStore.activities.single.points, -5000);
      expect(MockStore.activities.single.payment?.cashPaid, 100000);
    });

    test('refuses more points than the balance', () async {
      MockStore.points = 10;

      await expectLater(
        buy(5000, PaymentChannel.qris),
        throwsA(isA<ApiException>()),
      );
      expect(MockStore.points, 10);
    });

    test('a points-only order must cover the full price', () async {
      MockStore.points = 20000;

      await expectLater(buy(5000, null), throwsA(isA<ApiException>()));
    });
  });

  test('a server row carries the payment detail into history', () {
    final transaction = ActivityTransaction.fromJson(const {
      'reference': 'REC-PAY01',
      'type': 'redeem',
      'title': 'Beli Miniatur F1',
      'title_en': 'Bought F1 Miniature',
      'created_at': '2026-11-25T03:00:00+00:00',
      'points_delta': -5000,
      'weight_kg': 0,
      'payment_method': 'hybrid',
      'points_used': 5000,
      'cash_paid': 100000,
      'gross_idr': 150000,
      'payment_channel': 'bank_transfer',
    });

    expect(transaction.payment?.mode, PaymentMode.hybrid);
    expect(transaction.payment?.discountIdr, 50000);
    expect(transaction.payment?.channel, PaymentChannel.bankTransfer);
  });

  testWidgets('history details show method, discount and cash', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: ActivityDetailSheet(
            transaction: ActivityTransaction(
              transactionId: 'REC-PAY02',
              type: ActivityType.redeem,
              title: 'Beli',
              titleEn: 'Bought',
              timestamp: DateTime(2026, 11, 25),
              points: -5000,
              weightKg: 0,
              payment: const PurchaseReceipt(
                reference: 'REC-PAY02',
                pointsUsed: 5000,
                cashPaid: 100000,
                grossIdr: 150000,
                channel: PaymentChannel.qris,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Poin + Rupiah'), findsOneWidget);
    expect(find.text('Rp 150.000'), findsOneWidget);
    expect(find.text('-Rp 50.000'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('QRIS'), findsOneWidget);
  });

  group('checkout screen', () {
    final confirm = find.byKey(const ValueKey('checkout-confirm'));
    final usePoints = find.byType(Switch);

    Future<void> open(WidgetTester tester, {required int points}) async {
      MockStore.points = points;
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(CheckoutPage(product: MockStore.products.first)),
      );
      await tester.pumpAndSettle();
    }

    String due(WidgetTester tester) =>
        tester.widget<Text>(find.byKey(const ValueKey('checkout-total'))).data!;

    bool canConfirm(WidgetTester tester) =>
        tester.widget<FilledButton>(confirm).onPressed != null;

    testWidgets('a zero balance can still pay in rupiah', (tester) async {
      await open(tester, points: 0);

      expect(canConfirm(tester), isTrue);
      expect(due(tester), 'Rp 150.000');
      expect(tester.widget<Switch>(usePoints).onChanged, isNull);

      await tester.enterText(find.byType(TextField).first, 'Jl. Mawar 1');
      await tester.tap(find.text('Transfer Bank'));
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutSuccessPage), findsOneWidget);
      expect(find.text('Transfer Bank'), findsOneWidget);
      expect(find.text('Rp 150.000'), findsWidgets);
    });

    testWidgets('partial points show discount and rupiah still due', (
      tester,
    ) async {
      await open(tester, points: 5000);
      expect(due(tester), 'Rp 150.000');

      await tester.tap(usePoints);
      await tester.pumpAndSettle();

      expect(find.text('-Rp 50.000'), findsOneWidget);
      expect(due(tester), 'Rp 100.000');
      expect(find.text('QRIS'), findsOneWidget);
    });

    testWidgets('dragging the slider updates the rupiah due', (tester) async {
      await open(tester, points: 5000);
      await tester.tap(usePoints);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slider), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      expect(due(tester), 'Rp 150.000');
    });

    testWidgets('a large balance defaults to points and may switch to cash', (
      tester,
    ) async {
      await open(tester, points: 20000);

      expect(due(tester), 'Rp 0');
      expect(find.text('QRIS'), findsNothing);

      await tester.tap(usePoints);
      await tester.pumpAndSettle();

      expect(due(tester), 'Rp 150.000');
      expect(find.text('QRIS'), findsOneWidget);
    });

    testWidgets('product detail never locks buying on a low balance', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(ProductDetailPage(product: MockStore.products.first)),
      );
      await tester.pumpAndSettle();

      final button = find.widgetWithText(FilledButton, 'Beli Sekarang');
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    });
  });

  testWidgets('SingleFlight ignores taps while the action runs', (
    tester,
  ) async {
    final gate = Completer<void>();
    var runs = 0;
    await tester.pumpWidget(
      testApp(
        SingleFlight(
          action: () {
            runs++;
            return gate.future;
          },
          builder: (context, run) => TextButton(
            onPressed: run,
            child: Text(run == null ? 'busy' : 'go'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    expect(runs, 1);
    expect(find.text('busy'), findsOneWidget);

    gate.complete();
    await tester.pump();
    expect(find.text('go'), findsOneWidget);
  });
}
