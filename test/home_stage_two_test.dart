import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_theme.dart';
import 'package:mobile_apps_recan/features/auth/presentation/login_page.dart';
import 'package:mobile_apps_recan/features/home/domain/weekly_deposits.dart';
import 'package:mobile_apps_recan/features/home/presentation/mission_ring_card.dart';
import 'package:mobile_apps_recan/features/home/presentation/recent_activity_card.dart';
import 'package:mobile_apps_recan/features/home/presentation/weekly_deposit_chart.dart';
import 'package:mobile_apps_recan/main.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/dashboard_data.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/category_menu.dart';
import 'package:mobile_apps_recan/widgets/home_hero_header.dart';
import 'package:mobile_apps_recan/widgets/motion/brand_rings.dart';
import 'package:mobile_apps_recan/widgets/motion/rolling_number.dart';
import 'package:mobile_apps_recan/widgets/station_tracking_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/screen.dart';

Widget _still(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

void main() {
  tearDown(MockStore.resetDemoState);

  group('rolling number', () {
    Future<void> show(WidgetTester tester, int value) =>
        tester.pumpWidget(testApp(Scaffold(body: RollingNumber(value: value))));

    testWidgets('reads as one grouped number and settles on it', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await show(tester, 1500);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('1.500'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('rolls from the old value to the new one', (tester) async {
      await show(tester, 1);
      await tester.pumpAndSettle();
      await show(tester, 9);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('9'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('keeps the display shapes of the large digits', (tester) async {
      // The tabular digits of the bundled font have slab feet, which reads as
      // a different typeface at balance size.
      await show(tester, 114);
      await tester.pumpAndSettle();

      for (final digit in tester.widgetList<Text>(find.text('1'))) {
        expect(digit.style!.fontFeatures, isNull);
      }
    });

    testWidgets('is plain text under reduced motion', (tester) async {
      await tester.pumpWidget(
        testApp(_still(const Scaffold(body: RollingNumber(value: 1500)))),
      );

      expect(find.text('1.500'), findsOneWidget);
    });
  });

  testWidgets('dragging across the chart follows the finger', (tester) async {
    final now = DateTime.utc(2026, 11, 25, 5);
    final week = WeeklyDeposits.from([
      ActivityTransaction(
        transactionId: 'REC-1',
        type: ActivityType.deposit,
        title: 't',
        titleEn: 't',
        timestamp: now,
        points: 300,
        weightKg: 0,
        cans: 12,
      ),
    ], now);
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: WeeklyDepositChart(week: week, onScan: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final first = tester.getCenter(find.byKey(const ValueKey('week-bar-0')));
    final last = tester.getCenter(find.byKey(const ValueKey('week-bar-6')));

    final finger = await tester.startGesture(first);
    await finger.moveBy(const Offset(40, 0));
    await finger.moveTo(last);
    await finger.up();
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('week-tooltip')),
        matching: find.textContaining('12 kaleng'),
      ),
      findsOneWidget,
    );
  });

  group('home screen', () {
    Future<void> open(WidgetTester tester, {double height = 2400}) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(411, height);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(testApp(const HomePage()));
      await pumpFrames(tester);
    }

    testWidgets('leads with progress, then content', (tester) async {
      await open(tester);

      final tops = [
        find.text('Saldo Tersedia'),
        find.byType(CategoryMenu),
        find.byType(MissionRingCard),
        find.byType(WeeklyDepositChart),
        find.byType(RecentActivityCard),
        find.byType(StationTrackingSection),
      ].map((finder) => tester.getTopLeft(finder).dy).toList();

      expect(tops, orderedEquals([...tops]..sort()));
    });

    testWidgets('keeps the balance in reach once the header scrolls away', (
      tester,
    ) async {
      final bar = find.byKey(const ValueKey('home-compact-bar'));
      await open(tester, height: 800);
      expect(bar, findsNothing);

      final list = find.byType(ListView).first;
      await tester.drag(list, const Offset(0, -600));
      await pumpFrames(tester, 8);
      expect(bar, findsOneWidget);

      await tester.drag(list, const Offset(0, 900));
      await pumpFrames(tester, 8);
      expect(bar, findsNothing);
    });
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final scale in [1.3, 2.0]) {
      testWidgets(
        'the balance header fits at ${scale}x (${theme.brightness.name})',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(360, 1200);
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: ListView(
                  children: [
                    HomeHeroHeader(
                      user: const UserProfile(
                        id: 'u',
                        name: 'Budi Santoso Wijaya',
                        email: 'budi@recan.id',
                        pointsBalance: 12345678,
                      ),
                      cansDeposited: 98765,
                      onAskAi: () {},
                      onScan: () {},
                      onOpenProfile: () {},
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('every quick action label sits on one line', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(const HomePage()));
    await pumpFrames(tester);

    final labels = find.descendant(
      of: find.byType(CategoryMenu),
      matching: find.byType(Text),
    );
    final heights = {
      for (var i = 0; i < 4; i++) tester.getSize(labels.at(i)).height,
    };

    expect(
      find.descendant(
        of: find.byType(CategoryMenu),
        matching: find.text('Misi'),
      ),
      findsOneWidget,
    );
    expect(heights, hasLength(1));
    expect(heights.single, lessThan(24));
  });

  testWidgets('the splash draws the brand rings around the mark', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await tester.pumpWidget(const ReCanApp());
    await tester.pump(const Duration(milliseconds: 200));
    final early = tester.widget<BrandRings>(find.byType(BrandRings)).progress;
    await tester.pump(const Duration(milliseconds: 500));
    final later = tester.widget<BrandRings>(find.byType(BrandRings)).progress;

    expect(later, greaterThan(early));
    await tester.pumpAndSettle();
  });

  testWidgets('the sign-in panel rises into place', (tester) async {
    useTallPhone(tester);
    await tester.pumpWidget(testApp(const LoginPage()));
    final toggle = find.byKey(const ValueKey('auth-tab-login'));
    final start = tester.getTopLeft(toggle).dy;
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(toggle).dy, lessThan(start));
  });
}
