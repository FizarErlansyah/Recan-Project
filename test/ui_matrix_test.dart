import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/features/catalog/domain/payment_quote.dart';
import 'package:mobile_apps_recan/features/tour/data/tour_store.dart';
import 'package:mobile_apps_recan/features/tour/presentation/coach_mark_overlay.dart';
import 'package:mobile_apps_recan/features/tutorial/presentation/can_tutorial_page.dart';
import 'package:mobile_apps_recan/features/voucher/domain/voucher.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/my_vouchers_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/owned_voucher_page.dart';
import 'package:mobile_apps_recan/features/voucher/presentation/voucher_detail_page.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/models/drop_session_summary.dart';
import 'package:mobile_apps_recan/pages/about_recan_page.dart';
import 'package:mobile_apps_recan/pages/article_detail_page.dart';
import 'package:mobile_apps_recan/pages/checkout_page.dart';
import 'package:mobile_apps_recan/pages/checkout_success_page.dart';
import 'package:mobile_apps_recan/pages/drop_success_page.dart';
import 'package:mobile_apps_recan/pages/edit_profil_page.dart';
import 'package:mobile_apps_recan/pages/edukasi_page.dart';
import 'package:mobile_apps_recan/pages/help_center_page.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/pages/legal_policies_page.dart';
import 'package:mobile_apps_recan/pages/onboarding_page.dart';
import 'package:mobile_apps_recan/pages/product_detail_page.dart';
import 'package:mobile_apps_recan/pages/quest_page.dart';
import 'package:mobile_apps_recan/pages/tier_info_page.dart';
import 'package:mobile_apps_recan/services/api_config.dart';
import 'package:mobile_apps_recan/services/education_service.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/screen.dart';
import 'support/tour_stores.dart';

/// Every main screen against light/dark, ID/EN and motion on/off, on a narrow
/// phone with 1.3x text. Nothing may overflow, and under reduced motion every
/// screen must come to rest.
const Size _phone = Size(360, 740);
const double _scale = 1.3;

Map<String, Widget Function()> _screens(Voucher voucher, OwnedVoucher owned) =>
    {
      'onboarding': () => const OnboardingPage(),
      'login': () => const LoginPage(),
      'quests': () => QuestPage(onLogout: () {}),
      'education': () => const EdukasiPage(),
      'article': () =>
          ArticleDetailPage(article: EducationService.featured.first),
      'tutorial': () => const CanTutorialPage(),
      'product': () => ProductDetailPage(product: MockStore.products.first),
      'checkout': () => CheckoutPage(product: MockStore.products.first),
      'receipt': () => const CheckoutSuccessPage(
        productName: 'Miniatur Mobil Klasik',
        receipt: PurchaseReceipt(
          reference: 'REC-MTRX1',
          pointsUsed: 12000,
          cashPaid: 0,
        ),
      ),
      'voucher detail': () =>
          VoucherDetailPage(voucher: voucher, balance: 100, onLogout: () {}),
      'owned voucher': () => OwnedVoucherPage(owned: owned),
      'my vouchers': () => MyVouchersPage(onLogout: () {}),
      'edit profile': () => EditProfilPage(profile: MockStore.profile),
      'tiers': () => const TierInfoPage(points: 2700),
      'help': () => const HelpCenterPage(),
      'about': () => const AboutRecanPage(),
      'legal': () => const LegalPoliciesPage(),
      'drop success': () => const DropSuccessPage(
        stationName: 'Drop Station Stasiun Jurang Mangu',
        summary: DropSessionSummary(cans: 140),
      ),
    };

void _apply(
  WidgetTester tester, {
  required bool dark,
  required bool english,
  required bool still,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _phone;
  final platform = tester.platformDispatcher
    ..textScaleFactorTestValue = _scale
    ..platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light
    ..accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: still,
    );
  MockStore.isEnglish.value = english;
  addTearDown(() {
    tester.view.reset();
    platform.clearAllTestValues();
  });
}

/// Under reduced motion the screen must settle; with motion on, a few screens
/// keep a status dot pulsing, so it is advanced by frames instead.
Future<void> _rest(WidgetTester tester, {required bool still}) async {
  if (still) {
    await tester.pumpAndSettle();
  } else {
    await pumpFrames(tester);
  }
}

/// Walks the vertical lists to the end so lazy rows get laid out too.
Future<void> _scrollThrough(WidgetTester tester, {required bool still}) async {
  for (var i = 0; i < 12; i++) {
    final lists = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    if (lists.evaluate().isEmpty) return;
    await tester.drag(lists.first, const Offset(0, -500), warnIfMissed: false);
    await _rest(tester, still: still);
    expect(tester.takeException(), isNull);
  }
}

void main() {
  late Voucher voucher;
  late OwnedVoucher owned;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    MockStore.resetDemoState();
    voucher = MockStore.vouchers.first;
    MockStore.points = voucher.pointsCost;
    await TransactionService.redeemVoucher(voucher);
    owned = MockStore.ownedVouchers.single;
    MockStore.recordDeposit(140);
  });
  tearDown(() {
    TourStore.current = const FinishedTourStore();
    MockStore.resetDemoState();
    MockStore.isEnglish.value = false;
  });

  for (final dark in [false, true]) {
    for (final english in [false, true]) {
      for (final still in [false, true]) {
        final mode =
            '${dark ? 'dark' : 'light'} ${english ? 'EN' : 'ID'} '
            '${still ? 'still' : 'motion'}';

        for (final name in _screens(
          MockStore.vouchers.first,
          OwnedVoucher(
            voucher: MockStore.vouchers.first,
            reference: 'REC-NAME',
            redeemedAt: DateTime(2026, 11, 26),
          ),
        ).keys) {
          testWidgets('$name: $mode', (tester) async {
            _apply(tester, dark: dark, english: english, still: still);
            await tester.pumpWidget(
              MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                home: _screens(voucher, owned)[name]!(),
              ),
            );
            await _rest(tester, still: still);
            expect(tester.takeException(), isNull);

            await _scrollThrough(tester, still: still);
          });
        }

        testWidgets('home tabs: $mode', (tester) async {
          _apply(tester, dark: dark, english: english, still: still);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: const HomePage(),
            ),
          );
          await pumpFrames(tester);
          for (final tab in [
            if (english) ...['Home', 'Catalog', 'Activity', 'Profile'],
            if (!english) ...['Beranda', 'Katalog', 'Aktivitas', 'Profil'],
          ]) {
            await tester.tap(find.text(tab).last);
            await pumpFrames(tester, 8);
            expect(tester.takeException(), isNull, reason: tab);
            await _scrollThrough(tester, still: false);
          }
        });

        testWidgets('app tour: $mode', (tester) async {
          TourStore.current = MemoryTourStore();
          _apply(tester, dark: dark, english: english, still: still);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: const HomePage(),
            ),
          );
          await pumpFrames(tester);

          expect(find.byType(CoachMarkOverlay), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        for (final signedIn in [false, true]) {
          testWidgets('splash handover (signed in: $signedIn): $mode', (
            tester,
          ) async {
            SharedPreferences.setMockInitialValues({
              'onboarding_completed': true,
              if (signedIn) ApiConfig.tokenKey: 'mock-session',
            });
            _apply(tester, dark: dark, english: english, still: still);
            await tester.pumpWidget(const ReCanApp());
            for (var i = 0; i < 40; i++) {
              await tester.pump(const Duration(milliseconds: 60));
              expect(tester.takeException(), isNull);
            }
            expect(
              find.byType(signedIn ? HomePage : LoginPage),
              findsOneWidget,
            );
          });
        }
      }
    }
  }
}
