import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/activity/domain/activity_filter.dart';
import 'package:mobile_apps_recan/features/activity/domain/month_summary.dart';
import 'package:mobile_apps_recan/features/activity/presentation/activity_day_card.dart';
import 'package:mobile_apps_recan/features/activity/presentation/activity_history_list.dart';
import 'package:mobile_apps_recan/features/activity/presentation/month_summary_card.dart';
import 'package:mobile_apps_recan/models/activity_transaction.dart';

import 'support/screen.dart';

final _now = DateTime(2026, 11, 25, 12);

ActivityTransaction _row(
  String reference,
  DateTime at, {
  required int points,
  ActivityType type = ActivityType.deposit,
  int cans = 0,
}) => ActivityTransaction(
  transactionId: reference,
  type: type,
  title: reference,
  titleEn: reference,
  timestamp: at,
  points: points,
  weightKg: 0,
  cans: cans,
);

final List<ActivityTransaction> _history = [
  _row('REC-IN', _now, points: 3500, cans: 140),
  _row('REC-OUT', _now, points: -300, type: ActivityType.redeem),
  _row(
    'REC-QUEST',
    _now.subtract(const Duration(days: 1)),
    points: 20,
    type: ActivityType.quest,
  ),
  _row('REC-OLD', DateTime(2026, 10, 30), points: 999, cans: 5),
];

void main() {
  group('month summary', () {
    test('adds up this month only', () {
      final summary = MonthSummary.of(_history, _now);

      expect(summary.pointsIn, 3520);
      expect(summary.pointsOut, 300);
      expect(summary.cans, 140);
    });

    test('is all zero for a month without entries', () {
      final summary = MonthSummary.of(_history, DateTime(2027));

      expect(summary.pointsIn, 0);
      expect(summary.pointsOut, 0);
      expect(summary.cans, 0);
    });
  });

  group('type filter', () {
    List<String> kept(ActivityFilter filter) => [
      for (final row in _history)
        if (filter.keeps(row)) row.transactionId,
    ];

    test('splits deposits, spending and rewards', () {
      expect(kept(ActivityFilter.all), hasLength(4));
      expect(kept(ActivityFilter.deposit), ['REC-IN', 'REC-OLD']);
      expect(kept(ActivityFilter.redeem), ['REC-OUT']);
      expect(kept(ActivityFilter.reward), ['REC-QUEST']);
    });
  });

  group('history', () {
    Future<void> show(WidgetTester tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: ActivityHistoryList(transactions: _history, now: _now),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('leads with the month, then one card per day', (tester) async {
      await show(tester);

      expect(find.byType(MonthSummaryCard), findsOneWidget);
      expect(find.byType(ActivityDayCard), findsNWidgets(3));
      expect(find.text('Ringkasan November'), findsOneWidget);
    });

    testWidgets('income is green and spending red', (tester) async {
      await show(tester);
      Color? painted(String text) =>
          tester.widget<Text>(find.text(text)).style?.color;

      expect(painted('+20 Poin'), AppPalette.light.success);
      expect(painted('-300 Poin'), AppPalette.light.danger);
    });

    testWidgets('filtering keeps only that kind', (tester) async {
      await show(tester);

      await tester.tap(find.text('Tukar'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityDayCard), findsOneWidget);
      expect(find.text('REC-IN'), findsNothing);
      expect(find.text('REC-OUT'), findsWidgets);
    });

    testWidgets('an empty filter says so', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(
        testApp(
          Scaffold(
            body: ActivityHistoryList(
              transactions: [_history.first],
              now: _now,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hadiah'));
      await tester.pumpAndSettle();

      expect(
        find.text('Belum ada aktivitas untuk filter ini.'),
        findsOneWidget,
      );
    });

    testWidgets('fits large text on a narrow phone', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 1600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.6)),
              child: Scaffold(
                body: ActivityHistoryList(transactions: _history, now: _now),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
