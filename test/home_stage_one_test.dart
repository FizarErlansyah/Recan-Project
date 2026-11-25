import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/features/home/domain/weekly_deposits.dart';
import 'package:mobile_apps_recan/features/home/presentation/mission_ring_card.dart';
import 'package:mobile_apps_recan/features/home/presentation/recent_activity_card.dart';
import 'package:mobile_apps_recan/features/home/presentation/weekly_deposit_chart.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';
import 'package:mobile_apps_recan/models/gamification_data.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/pages/scan_qr_page.dart';
import 'package:mobile_apps_recan/services/mock_store.dart';
import 'package:mobile_apps_recan/widgets/category_menu.dart';
import 'package:mobile_apps_recan/widgets/home_hero_header.dart';
import 'package:mobile_apps_recan/widgets/main_nav_bar.dart';
import 'package:mobile_apps_recan/widgets/motion/animated_count_up.dart';
import 'package:mobile_apps_recan/widgets/motion/bouncy_tap.dart';
import 'package:mobile_apps_recan/widgets/motion/rolling_number.dart';

import 'support/screen.dart';

// 25 November 2026, 12:00 WIB, a Wednesday.
final _now = DateTime.utc(2026, 11, 25, 5);

ActivityTransaction _entry(
  DateTime at, {
  int cans = 0,
  ActivityType type = ActivityType.deposit,
}) => ActivityTransaction(
  transactionId: 'REC-${at.millisecondsSinceEpoch}',
  type: type,
  title: 't',
  titleEn: 't',
  timestamp: at,
  points: cans * 25,
  weightKg: 0,
  cans: cans,
);

DailyQuest _quest(int id, int progress, int target, {bool claimed = false}) =>
    DailyQuest(
      id: id,
      title: 'Misi $id',
      progress: progress,
      target: target,
      unit: 'Kaleng',
      rewardPoints: 10,
      isClaimed: claimed,
    );

void main() {
  tearDown(MockStore.resetDemoState);

  group('seven day deposits', () {
    test('covers today and the six days before, oldest first', () {
      final week = WeeklyDeposits.from(const [], _now);

      expect(week.days, hasLength(7));
      expect(week.days.first.date, DateTime.utc(2026, 11, 19));
      expect(week.days.last.date, DateTime.utc(2026, 11, 25));
      expect(week.total, 0);
    });

    test('adds only deposits, on their Jakarta day', () {
      final week = WeeklyDeposits.from([
        // 23:30 WIB on the 24th and 00:30 WIB on the 25th.
        _entry(DateTime.utc(2026, 11, 24, 16, 30), cans: 4),
        _entry(DateTime.utc(2026, 11, 24, 17, 30), cans: 6),
        _entry(DateTime.utc(2026, 11, 25, 3), cans: 1),
        _entry(DateTime.utc(2026, 11, 25, 3), type: ActivityType.quest),
        _entry(DateTime.utc(2026, 11, 18, 3), cans: 99),
      ], _now);

      expect(week.days[5].cans, 4);
      expect(week.days[6].cans, 7);
      expect(week.total, 11);
      expect(week.peak, 7);
    });

    test('a server row carries its can count', () {
      final row = ActivityTransaction.fromJson(const {
        'reference': 'REC-1',
        'type': 'deposit',
        'title': 't',
        'title_en': 't',
        'created_at': '2026-11-25T03:00:00+00:00',
        'points_delta': 125,
        'weight_kg': 0.07,
        'cans_delta': 5,
      });

      expect(row.cans, 5);
    });
  });

  group('weekly chart', () {
    final week = WeeklyDeposits.from([
      _entry(DateTime.utc(2026, 11, 23, 3), cans: 3),
      _entry(DateTime.utc(2026, 11, 25, 3), cans: 12),
    ], _now);

    Finder bar(int index) => find.byKey(ValueKey('week-bar-$index'));
    Finder fill(int index) => find.byKey(ValueKey('week-fill-$index'));
    final tooltip = find.byKey(const ValueKey('week-tooltip'));

    Future<void> show(WidgetTester tester, WeeklyDeposits data) async {
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: WeeklyDepositChart(week: data, onScan: () {}),
          ),
        ),
      );
    }

    testWidgets('bars rise to their share of the busiest day', (tester) async {
      await show(tester, week);
      await tester.pump(const Duration(milliseconds: 60));
      final early = tester.getSize(fill(6)).height;
      await tester.pumpAndSettle();
      final full = tester.getSize(fill(6)).height;

      expect(early, lessThan(full));
      expect(tester.getSize(fill(4)).height / full, closeTo(3 / 12, 0.05));
    });

    testWidgets('touching a day shows its cans and moves with the next', (
      tester,
    ) async {
      await show(tester, week);
      await tester.pumpAndSettle();
      expect(tooltip, findsNothing);

      await tester.tap(bar(4));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: tooltip, matching: find.textContaining('3 kaleng')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('week-active-4')), findsOneWidget);
      final left = tester.getCenter(tooltip).dx;

      await tester.tap(bar(6));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: tooltip,
          matching: find.textContaining('12 kaleng'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('week-active-4')), findsNothing);
      expect(tester.getCenter(tooltip).dx, greaterThan(left));

      await tester.tap(bar(6));
      await tester.pumpAndSettle();
      expect(tooltip, findsNothing);
    });

    testWidgets('an empty week explains itself and offers a scan', (
      tester,
    ) async {
      var scans = 0;
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: WeeklyDepositChart(
              week: WeeklyDeposits.from(const [], _now),
              onScan: () => scans++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Belum ada setoran'), findsOneWidget);
      await tester.tap(find.text('Pindai QR untuk setor'));
      expect(scans, 1);
      await tester.tap(bar(0));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: tooltip, matching: find.textContaining('0 kaleng')),
        findsOneWidget,
      );
    });

    testWidgets('an empty week does not leave a tall blank plot', (
      tester,
    ) async {
      await show(tester, week);
      await tester.pumpAndSettle();
      final busy = tester.getSize(bar(0)).height;

      await show(tester, WeeklyDeposits.from(const [], _now));
      await tester.pumpAndSettle();

      expect(tester.getSize(bar(0)).height, lessThan(busy * 0.6));
      expect(tester.getSize(bar(0)).height, greaterThanOrEqualTo(48));
    });

    testWidgets('fits large text without overflow', (tester) async {
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.6)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: WeeklyDepositChart(week: week, onScan: () {}),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(bar(6));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('mission ring', () {
    Future<void> show(WidgetTester tester, List<DailyQuest> quests) async {
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: MissionRingCard(quests: quests, onTap: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('counts finished missions and names the closest one', (
      tester,
    ) async {
      await show(tester, [
        _quest(1, 5, 5, claimed: true),
        _quest(2, 1, 10),
        _quest(3, 8, 10),
        _quest(4, 15, 15),
      ]);

      expect(find.text('2/4'), findsOneWidget);
      expect(find.textContaining('1 hadiah siap diklaim'), findsOneWidget);
      expect(find.textContaining('Misi 3'), findsOneWidget);
    });

    testWidgets('says so when there is no mission', (tester) async {
      await show(tester, const []);

      expect(find.textContaining('Belum ada misi'), findsOneWidget);
    });
  });

  group('recent activity', () {
    testWidgets('shows only the three newest', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: RecentActivityCard(
              activities: [
                for (var day = 25; day > 20; day--)
                  _entry(DateTime.utc(2026, 11, day, 3), cans: day),
              ],
              onSeeAll: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('+625'), findsOneWidget);
      expect(find.textContaining('+575'), findsOneWidget);
      expect(find.textContaining('+550'), findsNothing);
    });

    testWidgets('has a quiet empty state', (tester) async {
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: RecentActivityCard(activities: const [], onSeeAll: () {}),
          ),
        ),
      );

      expect(find.textContaining('Belum ada aktivitas'), findsOneWidget);
    });
  });

  group('home screen', () {
    Future<void> open(WidgetTester tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(testApp(const HomePage()));
      await pumpFrames(tester);
    }

    testWidgets('stacks the stage one sections in order', (tester) async {
      await open(tester);

      final tops = [
        find.textContaining('Hai '),
        find.text('Saldo Tersedia'),
        find.byType(CategoryMenu),
        find.byType(MissionRingCard),
        find.byType(WeeklyDepositChart),
        find.byType(RecentActivityCard),
      ].map((finder) => tester.getTopLeft(finder).dy).toList();

      expect(tops, orderedEquals([...tops]..sort()));
    });

    testWidgets('counts points and cans up, from real deposits', (
      tester,
    ) async {
      MockStore.recordDeposit(60);
      await open(tester);

      expect(
        tester.widget<RollingNumber>(find.byType(RollingNumber)).value,
        1500,
      );
      final counters = tester
          .widgetList<AnimatedCountUp>(find.byType(AnimatedCountUp))
          .map((w) => w.value)
          .toList();
      expect(counters, contains(60));
      expect(find.textContaining('60 kaleng'), findsWidgets);
    });

    testWidgets('quick actions bounce under the finger', (tester) async {
      await open(tester);

      expect(
        find.descendant(
          of: find.byType(CategoryMenu),
          matching: find.byType(BouncyTap),
        ),
        findsNWidgets(4),
      );
    });

    testWidgets('the balance card scan button opens the scanner once', (
      tester,
    ) async {
      await open(tester);
      final scan = find.byKey(const ValueKey('hero-scan'));
      expect(
        find.ancestor(of: scan, matching: find.byType(HomeHeroHeader)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: scan, matching: find.byType(BouncyTap)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: scan, matching: find.text('Pindai')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MainNavBar),
          matching: find.text('Pindai'),
        ),
        findsNothing,
      );

      // Compact beside the balance, yet still a full touch target.
      final size = tester.getSize(scan);
      // The test font is far wider than the real one, which gives about 60.
      expect(size.width, inInclusiveRange(48, 90));
      expect(size.height, inInclusiveRange(48, 60));

      await tester.tap(scan);
      await tester.tap(scan, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ScanQrPage), findsOneWidget);
    });
  });
}
