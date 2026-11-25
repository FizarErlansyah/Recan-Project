import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/features/voucher/data/voucher_service.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/my_vouchers_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/owned_voucher_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_catalog_view.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_detail_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/swipe_to_confirm.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/widgets/voucher_ticket_card.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/services/api_client.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'support/screen.dart';

final _now = DateTime(2026, 11, 25, 12);

OwnedVoucher _owned(
  String reference, {
  VoucherStatus status = VoucherStatus.active,
  DateTime? expiresAt,
  DateTime? usedAt,
}) => OwnedVoucher(
  voucher: MockStore.vouchers.first,
  reference: reference,
  redeemedAt: DateTime.now().subtract(const Duration(days: 1)),
  status: status,
  usedAt: usedAt,
  expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 29)),
);

void main() {
  tearDown(() {
    MockStore.resetDemoState();
    MockStore.isEnglish.value = false;
  });

  group('voucher rows', () {
    final row = <String, dynamic>{
      'id': 102,
      'name': 'Gratis Parkir',
      'name_en': 'Free Parking',
      'description': 'd',
      'description_en': 'd',
      'price_points': 800,
      'icon_key': 'parking',
      'terms': ['Satu motor.'],
      'terms_en': ['One motorbike.'],
      'validity_days': 14,
      'voucher_partners': [
        {
          'name': 'Parkir Dua',
          'address': 'Jl. B',
          'lat': -6.2,
          'lng': 106.7,
          'opens_at': null,
          'closes_at': null,
          'open_24h': true,
          'is_sample': false,
          'sort_order': 20,
        },
        {
          'name': 'Parkir Satu',
          'address': 'Jl. A',
          'lat': -6.27,
          'lng': 106.74,
          'opens_at': '05:00:00',
          'closes_at': '23:00:00',
          'open_24h': false,
          'is_sample': true,
          'sort_order': 10,
        },
      ],
    };

    test('carry terms, validity and partners in their sort order', () {
      final voucher = Voucher.fromJson(row);

      expect(voucher.terms, ['Satu motor.']);
      expect(voucher.validityDays, 14);
      expect(voucher.partners.map((p) => p.name), [
        'Parkir Satu',
        'Parkir Dua',
      ]);
      expect(voucher.partners.first.hoursLabel, '05.00-23.00 WIB');
      expect(voucher.partners.first.isSample, isTrue);
      expect(voucher.partners.last.hoursLabel, 'Buka 24 jam');
    });

    test('without the new columns still read, valid for 30 days', () {
      final voucher = Voucher.fromJson({
        ...row,
        'terms': null,
        'terms_en': null,
        'validity_days': null,
        'voucher_partners': null,
      });

      expect(voucher.terms, isEmpty);
      expect(voucher.partners, isEmpty);
      expect(voucher.validityDays, 30);
    });

    test('an owned row reads its status and dates', () {
      final owned = OwnedVoucher.fromJson({
        'reference': 'REC-1',
        'redeemed_at': '2026-11-01T03:00:00+00:00',
        'status': 'used',
        'used_at': '2026-11-02T03:00:00+00:00',
        'expires_at': '2026-12-01T03:00:00+00:00',
        'catalog_items': row,
      });

      expect(owned.status, VoucherStatus.used);
      expect(owned.usedAt, isNotNull);
      expect(owned.expiresAt, isNotNull);
    });
  });

  group('voucher status', () {
    test('turns expired once the date has passed', () {
      final owned = _owned('REC-1', expiresAt: _now);

      expect(
        owned.statusAt(_now.subtract(const Duration(seconds: 1))),
        VoucherStatus.active,
      );
      expect(owned.statusAt(_now), VoucherStatus.expired);
    });

    test('stays used even after the date has passed', () {
      final owned = _owned(
        'REC-1',
        status: VoucherStatus.used,
        expiresAt: _now,
      );

      expect(
        owned.statusAt(_now.add(const Duration(days: 1))),
        VoucherStatus.used,
      );
    });

    test('counts a started day as a day left', () {
      final owned = _owned(
        'REC-1',
        expiresAt: _now.add(const Duration(days: 2, hours: 1)),
      );

      expect(owned.daysLeft(_now), 3);
    });
  });

  group('wallet', () {
    Future<String> redeem() {
      final voucher = MockStore.vouchers.first;
      MockStore.points = voucher.pointsCost;
      return TransactionService.redeemVoucher(voucher);
    }

    test('a redeemed voucher expires after its validity', () async {
      await redeem();

      final owned = (await VoucherService.owned()).single;

      expect(owned.expiresAt!.difference(owned.redeemedAt).inDays, 30);
    });

    test('using a voucher works once and drops the active count', () async {
      final reference = await redeem();

      await VoucherService.use(reference);

      final owned = (await VoucherService.owned()).single;
      expect(owned.status, VoucherStatus.used);
      expect(owned.usedAt, isNotNull);
      expect(MockStore.profile.activeVouchers, 0);
      await expectLater(
        VoucherService.use(reference),
        throwsA(isA<ApiException>()),
      );
    });

    test('an expired voucher cannot be used and is not active', () async {
      MockStore.ownedVouchers.add(
        _owned(
          'REC-OLD',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      expect(MockStore.profile.activeVouchers, 0);
      await expectLater(
        VoucherService.use('REC-OLD'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('catalog and detail', () {
    Future<void> openCatalog(WidgetTester tester, {int balance = 800}) async {
      MockStore.points = balance;
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(Scaffold(body: VoucherCatalogView(onLogout: () {}))),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a ticket says how many places and how long', (tester) async {
      await openCatalog(tester);

      expect(find.byType(VoucherTicketCard), findsNWidgets(3));
      expect(find.text('3 lokasi mitra · berlaku 30 hari'), findsNWidgets(3));
    });

    testWidgets('tapping a ticket shows where, when and how', (tester) async {
      await openCatalog(tester);

      await tester.tap(find.text('Gratis Parkir'));
      await tester.pumpAndSettle();

      expect(find.byType(VoucherDetailPage), findsOneWidget);
      final parking = MockStore.vouchers[1];
      for (final partner in parking.partners) {
        expect(find.text(partner.name), findsOneWidget);
        expect(find.text(partner.address), findsOneWidget);
      }
      expect(find.text(parking.terms.first), findsOneWidget);
      expect(find.textContaining('30 hari sejak ditukar'), findsOneWidget);
      expect(find.text('Cara menukar'), findsOneWidget);
      expect(find.text('Data contoh'), findsWidgets);
    });

    testWidgets('redeeming leads to how to use the voucher', (tester) async {
      await openCatalog(tester);
      await tester.tap(find.text('Gratis Parkir'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Tukar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('redeem-confirm')));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutSuccessPage), findsOneWidget);

      await tester.tap(find.text('Cara Pakai'));
      await tester.pumpAndSettle();

      expect(find.byType(OwnedVoucherPage), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(
        find.text(MockStore.ownedVouchers.single.reference),
        findsOneWidget,
      );
    });
  });

  group('owned voucher', () {
    Future<void> open(WidgetTester tester, OwnedVoucher owned) async {
      MockStore.ownedVouchers.add(owned);
      useTallPhone(tester);
      await tester.pumpWidget(testApp(OwnedVoucherPage(owned: owned)));
      await tester.pumpAndSettle();
    }

    final thumb = find.byKey(const ValueKey('swipe-thumb'));

    testWidgets('a short swipe springs back and uses nothing', (tester) async {
      await open(tester, _owned('REC-A'));

      await tester.drag(thumb, const Offset(80, 0));
      await tester.pumpAndSettle();

      expect(MockStore.ownedVouchers.single.status, VoucherStatus.active);
      expect(find.byType(SwipeToConfirm), findsOneWidget);
    });

    testWidgets('a full swipe marks it used and stamps it', (tester) async {
      await open(tester, _owned('REC-A'));

      await tester.drag(thumb, const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(MockStore.ownedVouchers.single.status, VoucherStatus.used);
      expect(find.byKey(const ValueKey('voucher-stamp')), findsOneWidget);
      expect(find.byType(SwipeToConfirm), findsNothing);
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('a refusal explains itself and keeps the slider', (
      tester,
    ) async {
      useTallPhone(tester);
      // Not in the wallet, so the backend refuses it.
      await tester.pumpWidget(
        testApp(OwnedVoucherPage(owned: _owned('REC-GONE'))),
      );
      await tester.pumpAndSettle();

      await tester.drag(thumb, const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(SwipeToConfirm), findsOneWidget);
    });

    testWidgets('an expired voucher offers no code to use', (tester) async {
      await open(
        tester,
        _owned(
          'REC-OLD',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      expect(find.byType(QrImageView), findsNothing);
      expect(find.byType(SwipeToConfirm), findsNothing);
      expect(find.text('Kedaluwarsa'), findsWidgets);
    });
  });

  group('my vouchers', () {
    testWidgets('splits active, used and expired', (tester) async {
      MockStore.ownedVouchers.addAll([
        _owned('REC-ACT'),
        _owned('REC-USE', status: VoucherStatus.used, usedAt: DateTime.now()),
        _owned(
          'REC-EXP',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      useTallPhone(tester);
      await tester.pumpWidget(testApp(MyVouchersPage(onLogout: () {})));
      await tester.pumpAndSettle();

      expect(find.textContaining('REC-ACT'), findsOneWidget);
      expect(find.textContaining('REC-USE'), findsNothing);

      await tester.tap(find.text('Terpakai'));
      await tester.pumpAndSettle();
      expect(find.textContaining('REC-USE'), findsOneWidget);

      await tester.tap(find.text('Kedaluwarsa'));
      await tester.pumpAndSettle();
      expect(find.textContaining('REC-EXP'), findsOneWidget);
    });

    testWidgets('an empty tab says what to do', (tester) async {
      await tester.pumpWidget(testApp(MyVouchersPage(onLogout: () {})));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada voucher aktif'), findsOneWidget);
    });
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final scale in [1.3, 2.0]) {
      testWidgets(
        'voucher screens fit at ${scale}x (${theme.brightness.name})',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(360, 780);
          addTearDown(tester.view.reset);
          final voucher = MockStore.vouchers[2];

          for (final page in <Widget>[
            Scaffold(body: VoucherCatalogView(onLogout: () {})),
            VoucherDetailPage(voucher: voucher, balance: 10, onLogout: () {}),
            OwnedVoucherPage(owned: _owned('REC-SCALE')),
          ]) {
            await tester.pumpWidget(
              MaterialApp(
                key: ObjectKey(page),
                theme: theme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: page,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
}
